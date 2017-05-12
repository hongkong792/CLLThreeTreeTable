//
//  ViewController.m
//  CLLThreeTreeTable
//
//  Created by wln100-IOS1 on 15/12/23.
//  Copyright © 2015年 TianXing. All rights reserved.
//

#import "CLLThreeTreeViewController.h"
#import "CLLThreeTreeModel.h"
#import "ChapterHeader.h"
#import "CLLThreeTreeTableViewCell.h"
#import "Common.h"
#import "ChapterTableViewCell.h"

@interface CLLThreeTreeViewController () <UITableViewDelegate, UITableViewDataSource>

{
    NSInteger currentSection;
    NSInteger currentRow;
}

//tableView 显示的数据
@property (nonatomic, strong) NSArray *dataSource;
//标记section的打开状态
@property (nonatomic, strong) NSMutableArray *sectionOpen;

@property (nonatomic, strong) NSMutableDictionary *cellOpen;

//标记section内标题的情况
@property (nonatomic, strong) NSArray *sectionArray;


@end

@implementation CLLThreeTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    currentRow = -1;
    self.cellOpen = [NSMutableDictionary dictionary];
    
    //去掉tableView的横线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"json" ofType:nil];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    self.dataSource = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    self.sectionOpen = [NSMutableArray array];
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        [self.sectionOpen addObject:@0];
    }

    for (NSDictionary *dic1 in self.dataSource) {
        NSArray *arr2 = dic1[@"sub"];
        for (NSDictionary *dic2 in arr2) {
            NSString *key = [NSString stringWithFormat:@"%@", dic2[@"chapterID"]];
            CLLThreeTreeModel *model = [[CLLThreeTreeModel alloc] initWithDic:dic2];
            model.isShow = NO;
            [self.cellOpen setValue:model forKey:key];
        }
    }
    
    [self.tableView reloadData];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    NSLog(@"%@", self.dataSource);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sectionAction:(UIButton *)button{
    currentSection = button.tag;
    //tableview收起，局部刷新
    NSNumber *sectionStatus = self.sectionOpen[[button tag]];
    BOOL newSection = ![sectionStatus boolValue];
    [self.sectionOpen replaceObjectAtIndex:[button tag] withObject:[NSNumber numberWithBool:newSection]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[button tag]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - datasource,delegata

/**
 *  section返回个数
 *
 *  @param tableView 科目内容标题
 *
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL sectionStatus = [self.sectionOpen[section] boolValue];
    if (sectionStatus) {
        //数据决定显示多少行cell
        NSDictionary *sectionDic =self.dataSource[section];
        //section决定cell的数据
        NSArray *cellArray = sectionDic[@"sub"];
        return cellArray.count;
    }else{
        //section是收起状态时候
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //调用header的Xib,设置frame
    ChapterHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"ChapterHeader" owner:self options:nil]lastObject];
    header.frame = CGRectMake(0, 0, kScreen_Width, 60);
    NSDictionary *sectionData = self.dataSource[section];
    header.chapterName.text = sectionData[@"chapterName"];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.25)];
    view.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    [header addSubview:view];
    
    BOOL sectionStatus = [self.sectionOpen[section] boolValue];
    //点击标题变换图片
    if (sectionStatus) {
        //章节添加横线，选中加阴影
        //直接取出datasource的section,检查返回数据中是否有ksub
        NSDictionary *dic=_dataSource[section];
        if ([dic.allKeys indexOfObject:@"sub"] != NSNotFound) {
            header.imageView.image = [UIImage imageNamed:@"一级减号"];
            [header.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            header.imageView.image = [UIImage imageNamed:@"一级圆"];
            [header.imageView setContentMode:UIViewContentModeTop];
        }
    }else{
        NSDictionary *dic=_dataSource[section];
        if ([dic.allKeys indexOfObject:@"sub"] != NSNotFound) {
            header.imageView.image = [UIImage imageNamed:@"一级圆环加号"];
            [header.imageView setContentMode:UIViewContentModeTop];
        } else {
            header.imageView.image = [UIImage imageNamed:@"一级圆"];
            [header.imageView setContentMode:UIViewContentModeTop];
        }
        
    }
    
    
    [header.openButton addTarget:self action:@selector(sectionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加TAG
    header.openButton.tag = section;
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChapterTableViewCell *cell = [[ChapterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.contentView.backgroundColor=[UIColor whiteColor];
    NSDictionary *sectionDic = self.dataSource[indexPath.section];
    NSArray *cellArray = sectionDic[@"sub"];
    
    //cell当前的数据
    NSDictionary *cellData = cellArray[indexPath.row];
    
    NSString *key = [NSString stringWithFormat:@"%@", cellData[@"chapterID"]];
    
    CLLThreeTreeModel *chapterModel = [self.cellOpen valueForKey:key];
    [cell configureCellWithModel:chapterModel];
    
    //判断cell的位置选择折叠图片
    if (indexPath.row == cellArray.count - 1) {
        if (chapterModel.pois.count == 0) {
            cell.imageView2.image = [UIImage imageNamed:@"二级圆尾"];
        } else {
            
            if (!chapterModel.isShow) {
                cell.imageView2.image = [UIImage imageNamed:@"二级圆环-尾加"];
            } else {
                cell.imageView2.image = [UIImage imageNamed:@"三级圆环减"];
            }
            
        }
        
        [cell.imageView2 setContentMode:UIViewContentModeScaleAspectFit];
    }else{
        
        if (chapterModel.pois.count == 0) {
            cell.imageView2.image = [UIImage imageNamed:@"zhongjian"];
        } else {
            
            if (!chapterModel.isShow) {
                cell.imageView2.image = [UIImage imageNamed:@"二级加号"];
            } else {
                cell.imageView2.image = [UIImage imageNamed:@"三级圆环减"];
            }
            
        }
        [cell.imageView2 setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    cell.chapterName2.text = cellData[@"chapterName"];
    
    if (chapterModel.isShow == YES) {
        [cell showTableView];
    } else {
        
        [cell hiddenTableView];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionDic = self.dataSource[indexPath.section];
    NSArray *cellArray = sectionDic[@"sub"];
    //cell当前的数据
    NSDictionary *cellData = cellArray[indexPath.row];
    
    NSString *key = [NSString stringWithFormat:@"%@", cellData[@"chapterID"]];
    CLLThreeTreeModel *model = [self.cellOpen valueForKey:key];
    if (model.isShow) {
        return (model.pois.count+1)*60;
    } else {
        return 60;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    currentRow = indexPath.row;
    
    NSDictionary *sectionDic = self.dataSource[indexPath.section];
    NSArray *cellArray = sectionDic[@"sub"];
    
    //cell当前的数据
    NSDictionary *cellData = cellArray[indexPath.row];
    
    NSString *key = [NSString stringWithFormat:@"%@", cellData[@"chapterID"]];
    CLLThreeTreeModel *chapterModel = [self.cellOpen valueForKey:key];
    
    chapterModel.isShow = !chapterModel.isShow;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

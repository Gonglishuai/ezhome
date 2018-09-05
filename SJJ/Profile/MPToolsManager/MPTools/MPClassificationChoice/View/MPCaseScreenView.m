//
//  MPCaseScreenView.m
//  MarketPlace
//
//  Created by xuezy on 16/2/23.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import "MPCaseScreenView.h"
#import "MPCaseScreenTableViewCell.h"

#define Start_X 20.0f           // 第一个按钮的X坐标
#define Start_Y 10.0f           // 第一个按钮的Y坐标
#define Width_Space 30.0f        // 2个按钮之间的横间距
#define Height_Space 20.0f      // 竖间距
#define Button_Height 30.0f    // 高
#define Button_Width ([UIScreen mainScreen].bounds.size.width - 100)/3      // 宽

@interface MPCaseScreenView ()<UITableViewDataSource,UITableViewDelegate, caseScreenTableViewCellDelegate>
{
    UITableView *_caseScreenTableView;
    NSMutableDictionary *allTypeDict;
    NSMutableArray *allArray;
    NSMutableArray *allValueArray;
    NSMutableDictionary *selectDic;
}

@end

@implementation MPCaseScreenView

- (instancetype)initWithFrame:(CGRect)frame withSelectDict:(NSMutableDictionary *)selectCellDict withSelectionType:(NSString *)typ{
    
    self = [super initWithFrame:frame];
    if (self) {
        if ([typ isEqualToString:@"10"]) {
            [self init2DData];
        }else if ([typ isEqualToString:@"20"]){
            [self init3DData];
        }else
        {
            [self init2DData];
        }
        SHLog(@"传过来的数据是什么呢：%@",selectCellDict);
        selectDic = [selectCellDict mutableCopy];
        
        SHLog(@"传过来的：%@",selectDic);

        [self createCaseScreenView];
    }
    
    return self;
}
- (void)init2DData {

    allArray = [NSMutableArray array];
    allValueArray = [NSMutableArray array];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"caseClassSelection" ofType:@"plist"];
    NSMutableDictionary *dict  = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    allTypeDict = [dict objectForKey:@"data"];
    allArray = [NSMutableArray arrayWithArray:[allTypeDict allKeys]];
    allValueArray = [NSMutableArray arrayWithArray:[allTypeDict allValues]];
    selectDic = [NSMutableDictionary dictionary];
}

- (void)init3DData{

    allArray = [NSMutableArray array];
    allValueArray = [NSMutableArray array];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CaseClassCation" ofType:@"plist"];
    NSMutableDictionary *dict  = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    allTypeDict = [dict objectForKey:@"data"];
    allArray = [NSMutableArray arrayWithArray:[allTypeDict allKeys]];
    allValueArray = [NSMutableArray arrayWithArray:[allTypeDict allValues]];
    selectDic = [NSMutableDictionary dictionary];
}
- (void)createCaseScreenView {
    _caseScreenTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height) style:UITableViewStyleGrouped];
    _caseScreenTableView.delegate = self;
    _caseScreenTableView.dataSource = self;
    [_caseScreenTableView registerNib:[UINib nibWithNibName:@"MPCaseScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPCaseScreenTableViewCell"];
    _caseScreenTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _caseScreenTableView.showsVerticalScrollIndicator = NO;
    [self addSubview:_caseScreenTableView];

}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return allArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *string = [allArray objectAtIndex:section];
//    
//    return string;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 10, 40)];
    label.text = [allArray objectAtIndex:section];
    [view addSubview:label];

    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MPCaseScreenTableViewCell * _cell = [tableView dequeueReusableCellWithIdentifier:@"MPCaseScreenTableViewCell" forIndexPath:indexPath];
    //_cell.delegate = (id)self.delegate;
    _cell.delegate = self;
    _cell.cellSection = indexPath.section;
    NSInteger selectIndex = [[selectDic objectForKey:@(indexPath.section)] integerValue];
    [_cell updateCellForIndex:[allTypeDict objectForKey:[allArray objectAtIndex:indexPath.section]] withTitle:[allArray objectAtIndex:indexPath.section] andSelectIndes:selectIndex];
   
    return _cell;
}

- (void)cellWithSelectedIndex:(NSInteger)selectIndex andCellSection:(NSInteger)cellSection {
    
    [selectDic setObject:@(selectIndex) forKey:@(cellSection)];
}

- (void)selectType:(NSString *)buttonTitle type:(NSString *)type {
    if ([self.delegate respondsToSelector:@selector(didSelectType:type:withSelectCellSection:)]) {
        [self.delegate didSelectType:buttonTitle type:type withSelectCellSection:selectDic];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *array =[allTypeDict objectForKey:[allArray objectAtIndex:indexPath.section]];
    NSInteger count = array.count%4;
    NSInteger page = array.count/4;
    float height;
    if (count==0) {
        height = 20+page*30+(page-1)*20;
    }else {
        height = 30+page*30+(page+1)*20;

    }
    
    return height;
    //return 100.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)refreshTableViewWithSelect:(NSMutableDictionary *)selectionDict {
    selectDic = selectionDict;
    [_caseScreenTableView reloadData];
}
@end

 //
//  ESFilterController.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilterController.h"
#import "ESAppConfigManager.h"
#import "ESFilterView.h"
#import <Masonry.h>
#import "ESFilterData.h"

@interface ESFilterController ()<ESFilterViewDelegate>

@property (nonatomic, strong) NSArray *originalTags;    // 初始化已选择的标签
@property (nonatomic, strong) NSMutableArray <ESFilter *> *filterList;
@property (nonatomic, weak) id<ESFilterControllerDelegate> delegate;
@property (nonatomic, strong) ESFilterView *mainView;
@property (nonatomic, strong) NSMutableSet <ESFilterItem *> *selectItems;
@end

@implementation ESFilterController

- (NSMutableArray <ESFilter *> *)filterList {
    if (_filterList == nil) {
        _filterList = [NSMutableArray array];
    }
    return _filterList;
}

- (NSMutableSet <ESFilterItem *> *)selectItems {
    if (_selectItems == nil) {
        _selectItems = [NSMutableSet set];
    }
    return _selectItems;
}

- (instancetype)initWithSelected:(NSArray *)tags
                withOriginalTags:(NSArray *)allTags
                    withDelegate:(id <ESFilterControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.originalTags = tags;
        [ESFilterData initFilterData:tags withAllTags:allTags withList:self.filterList withSelected:self.selectItems andRefresh:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self setupNav];
    self.mainView = [[ESFilterView alloc] initWithDelegate:self];
    [self.view addSubview:self.mainView];
    [self setUpBottomView];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ESFilterViewDelegate
- (NSInteger)getSectionNums {
    return self.filterList.count;
}

- (NSInteger)getItemNums:(NSInteger)section {
    return [ESFilterData getTagsNum:section andList:self.filterList];
}

- (void)selectTagItem:(NSInteger)section andIndex:(NSInteger)index {
    [ESFilterData selectTagWithSection:section
                                    withIndex:index
                                     withList:self.filterList
                                  andSelected:self.selectItems];
    [self.mainView refreshMainView];
}

#pragma mark - ESDesignFilterHeaderViewDelegate
- (NSString *)getSectionHeader:(NSInteger)section {
    return [ESFilterData getTagsHeader:section
                                     andList:self.filterList];
}

#pragma mark - ESDesignFilterCellDelegate
- (NSString *)getFilterItemText:(NSInteger)section andIndex:(NSInteger)index {
    return [ESFilterData getTagTitle:section
                                 withIndex:index
                                   andList:self.filterList];
}

- (BOOL)filterItemIsSelected:(NSInteger)section andIndex:(NSInteger)index {
    return [ESFilterData tagIsSelected:section
                                   withIndex:index
                                    withList:self.filterList
                                 andSelected:self.selectItems];
}

#pragma mark - Private
- (void)setupNav {
    self.titleLabel.text = @"筛选";
    self.rightButton.hidden = YES;
}

- (void)setUpBottomView {
    UIButton * resetBtn  = [[UIButton alloc]init];
    resetBtn.backgroundColor = [UIColor redColor];
    [resetBtn setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    resetBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:resetBtn];
    [resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton * doneBtn  = [[UIButton alloc]init];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.backgroundColor = [UIColor stec_ableButtonBackColor];
    [self.view addSubview:doneBtn];
    [doneBtn addTarget:self action:@selector(doneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * colView = [[UIView alloc]init];
    colView.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self.view addSubview:colView];
    
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.bottom.equalTo(self.view.mas_bottom);
        make.trailing.equalTo(doneBtn.mas_leading);
        make.height.equalTo(@(TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT));
        make.width.equalTo(doneBtn.mas_width);
    }];
    
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT));
        make.width.equalTo(resetBtn.mas_width);
    }];
    
    [colView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(resetBtn.mas_top);
        make.height.equalTo(@(1));
    }];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(NAVBAR_HEIGHT);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(colView.mas_top);
    }];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        resetBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        doneBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

- (void)resetBtnClick:(UIButton *)sender {
    [ESFilterData resetFilter:self.filterList andSelected:self.selectItems];
    [self.mainView refreshMainView];
}

- (void)doneBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.selectItems && [self.delegate respondsToSelector:@selector(selectedCaseTags:)]) {
        NSArray *result = [ESFilterData getFilterResult:self.selectItems];
        [self.delegate selectedCaseTags:result];
    }
}
@end

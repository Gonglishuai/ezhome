//
//  MPCaseScreenView.h
//  MarketPlace
//
//  Created by xuezy on 16/2/23.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol caseScreenViewDelegate <NSObject>
- (void)didSelectType:(NSString *)buttonTitle type:(NSString *)type withSelectCellSection:(NSMutableDictionary *)cellSectionDict;
@end

@interface MPCaseScreenView : UIView
@property (weak, nonatomic)id<caseScreenViewDelegate>delegate;
@property (copy, nonatomic)NSMutableDictionary *cellDict;
- (instancetype)initWithFrame:(CGRect)frame withSelectDict:(NSMutableDictionary *)selectCellDict withSelectionType:(NSString *)type;
- (void)refreshTableViewWithSelect:(NSMutableDictionary *)selectionDict;

@end

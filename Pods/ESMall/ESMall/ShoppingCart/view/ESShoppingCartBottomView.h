//
//  ESShoppingCartBottomView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESCartConfirmButtonType) {
    ESCartConfirmButtonTypeNone,
    ESCartConfirmButtonTypeSettleValid,     //结算状态
    ESCartConfirmButtonTypeSettleInvalid,   //结算不可用状态（有商品处于编辑状态）
    ESCartConfirmButtonTypeDelete,          //处于删除状态（处于编辑全部状态）
};

@class ESCartInfo;
@protocol ESShoppingCartBottomViewDelegate <NSObject>

/**
 是否全选了

 @return YES:全选了
 */
- (BOOL)isSelected;

/**
 点击了全选
 */
- (void)selectAllItems:(BOOL)selectAll callBack:(void(^)(BOOL successStatus))callback;

/**
 获取合计金额数

 @return 合计金额
 */
- (ESCartInfo *)getTotalPrice;

/**
 点击了按钮

 @param type 按钮类型
 */
- (void)cartConfirmBtnClick:(ESCartConfirmButtonType)type;

/**
 是否有正在编辑状态的商品

 @return YES:有
 */
- (BOOL)hasEditingBrand;
@end

@interface ESShoppingCartBottomView : UIView

@property (nonatomic, weak) id<ESShoppingCartBottomViewDelegate> delegate;

- (void)updateBottomView;

- (void)setRightBtn:(ESCartConfirmButtonType)type;
@end

//
//  MPBaseViewController.h
//  MarketPlace
//
//  Created by xuezy on 15/12/16.
//  Copyright © 2015年 xuezy. All rights reserved.
//

#import "SHAppGlobal.h"
#import <UIKit/UIKit.h>

@interface MPBaseViewController : UIViewController

@property (strong,nonatomic) IBOutlet UIView *navgationImageview;
@property (strong,nonatomic) IBOutlet UILabel     *menuLabel ;
@property (strong,nonatomic) IBOutlet UIButton    *leftButton;
@property (strong,nonatomic) IBOutlet UIButton    *rightButton;
@property (strong,nonatomic) IBOutlet UILabel     *titleLabel ;
@property (strong,nonatomic) IBOutlet UIButton    *supplementaryButton; // on the right
@property (strong,nonatomic) IBOutlet UIButton    *secondarySupplementaryButton;
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet UIView *navigationBarBottomLine;
//@property (unsafe_unretained, nonatomic) IBOutlet UIView *designerView;
//@property (unsafe_unretained, nonatomic) IBOutlet UILabel *designerName;
//@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *designerAvatar;
@property (nonatomic, copy)  void (^refreshForLoadNew)(void); /// the block for load new data.
@property (nonatomic, copy)  void (^refreshForLoadMore)(void); /// the block for load more data.


@property (weak, nonatomic) IBOutlet UIView *msgCenterUnReadView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;

- (void)setupNavigationBar;
- (void)updateNavigationBar;
- (void)tapOnLeftButton:(id)sender;
- (void)tapOnRightButton:(id)sender;
- (void)tapOnSupplementaryButton:(id)sender;
- (void)tapOnSecondarySupplementaryButton:(id)sender;
- (void)setRightButtonBadgeValue:(NSUInteger)count;

- (void)endRefreshView:(BOOL)isLoadMore;
- (void)followScrollView:(UIView*)scrollableView;

- (void)customPushViewController:(UIViewController *)controller animated:(BOOL)animated;
- (NSString *)stringTypeChineseToEnglishWithString:(NSString *)string;

-(void)setTitleCenterAligned;

/**
 展示空白页
 
 @param superView 添加空白页的view
 @param imgName 图片名
 @param frame 空白页frame
 @param title 描述
 @param buttonTitle button名字  无按钮传@""
 @param block button点击回调
 */
- (void)showNoDataIn:(UIView *)superView imgName:(NSString *)imgName frame:(CGRect)frame Title:(NSString *)title buttonTitle:(NSString *)buttonTitle Block:(void(^)(void))block;

/**
 移除空白页
 */
- (void)removeNoDataView;


/**
 未开启定位弹窗
 */
- (void)showLocationAlertView;

@end

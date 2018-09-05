//
//  CoCaseBottomBarView.h
//  Consumer
//
//  Created by Jiao on 16/7/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ES2DCaseDetail;
@protocol CoCaseBottomBarViewDelegate <NSObject>

- (ES2DCaseDetail *)getDesignerInfo;

- (void)tapHeadIcon;

- (void)chatBtnClick;

- (void)focusBtnClickWithFocus:(BOOL)focus withSuccess:(void(^)(void))success;

- (BOOL)getLoginStatus;
@end
@interface CoCaseBottomBarView : UIView

@property (nonatomic, weak) id<CoCaseBottomBarViewDelegate> delegate;
- (void)getData;
@end

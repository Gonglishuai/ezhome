//
//  CoCaseDetailFooterView.h
//  Consumer
//
//  Created by Jiao on 16/7/20.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoCaseDetailFooterViewDelegate <NSObject>

- (BOOL)getCaseZan;

- (NSInteger)getCaseZanNumber;

- (void)caseShare;

- (void)caseZanWithSuccess:(void(^)(BOOL selected))success andFailure:(void(^)(void))failure;

@end
@interface CoCaseDetailFooterView : UIView

@property (nonatomic, weak) id<CoCaseDetailFooterViewDelegate> delegate;

- (void)updateCaseDetailFooterView;
@end

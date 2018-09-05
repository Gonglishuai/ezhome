//
//  CoCaseDetailView.h
//  Consumer
//
//  Created by Jiao on 16/7/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoCaseDetailViewDelegate <NSObject>

- (NSInteger)getCaseImages;

@end

@interface CoCaseDetailView : UIView
@property (nonatomic, weak) id<CoCaseDetailViewDelegate> delegate;

- (void)showBottomView;
- (void)refreshMiddleView;

@end

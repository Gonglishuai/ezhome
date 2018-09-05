//
//  ESReturnBrandHeaderView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnBrandHeaderViewDelegate <NSObject>

- (NSString *)getBrandName;

@end

@interface ESReturnBrandHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<ESReturnBrandHeaderViewDelegate> delegate;

- (void)updateBrandHeaderView;
@end

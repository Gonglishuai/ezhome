//
//  ESCase16to9ImageView.h
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCaseSpaceDetails.h"
#import "ESCaseDetailViewController.h"
#import "ESCase2DImageModel.h"

@protocol ESCase16to9ImageViewDelegate <NSObject>
- (void)openPhoto360Url:(NSString *)url;
@optional

@end
@interface ESCase16to9ImageView : UITableViewCell
@property (strong,nonatomic) ESCaseSpaceDetails *model;
@property (strong,nonatomic) ESCase2DImageModel *model2d;
@property (nonatomic,weak) id<ESCase16to9ImageViewDelegate>delegate;
+ (CGFloat)currentImageViewHeight:(NSString*)String;
@property (assign, nonatomic) CaseStyleType myStyleType;
@end

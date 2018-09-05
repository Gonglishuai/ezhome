//
//  ESCaseHeaderImageView.h
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCaseDetailModel.h"
#import "ESCaseDetailViewController.h"

@protocol ESCaseHeaderImageViewDelegate <NSObject>
@optional
- (void)openPhoto360Url:(NSString *)url;
@end

@interface ESCaseHeaderImageView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn;
@property (strong,nonatomic) ESCaseDetailModel*model;
@property (nonatomic,weak) id<ESCaseHeaderImageViewDelegate>delegate;
@property (assign, nonatomic) CaseStyleType myStyleType;
@end

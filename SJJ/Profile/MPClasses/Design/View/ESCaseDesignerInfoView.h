//
//  ESCaseDesignerInfoView.h
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCaseDetailModel.h"
#import "ESCaseDetailViewController.h"

@protocol ESCaseDesignerInfoViewDelegate <NSObject>
-(void) pushToDesignerPage:(NSString *)designid;
@optional

@end

@interface ESCaseDesignerInfoView : UITableViewCell
@property (strong,nonatomic) ESCaseDetailModel *model;
@property (strong,nonatomic) ESCaseDetailModel *desginModel;
@property (nonatomic,weak) id<ESCaseDesignerInfoViewDelegate>delegate;
@property (assign, nonatomic) CaseStyleType myStyleType;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconH;
@end

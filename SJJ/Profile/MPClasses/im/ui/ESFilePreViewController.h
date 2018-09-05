//
//  ESFilePreViewController.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIMSDK/NIMSDK.h>

@interface ESFilePreViewController : UIViewController
@property(nonatomic,strong) IBOutlet UIButton *actionBtn;

@property(nonatomic,strong) IBOutlet UIProgressView *progressView;

@property(nonatomic,strong) IBOutlet UILabel *fileNameLabel;

- (instancetype)initWithFileObject:(NIMFileObject*)object;

@end

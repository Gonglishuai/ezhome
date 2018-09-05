//
//  ESSubscribeManager.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESNavigationHandler : NSObject<UINavigationControllerDelegate>

@property (nonatomic,strong,readonly) UIPanGestureRecognizer *recognizer;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end

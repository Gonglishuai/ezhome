//
//  ESDesignCaseFilterController.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  筛选页面

#import "MPBaseViewController.h"

@protocol ESFilterControllerDelegate <NSObject>

- (void)selectedCaseTags:(NSArray *)items;

@end

@interface ESFilterController : MPBaseViewController

- (instancetype)initWithSelected:(NSArray *)tags
                withOriginalTags:(NSArray *)allTags
                    withDelegate:(id <ESFilterControllerDelegate>)delegate;
@end

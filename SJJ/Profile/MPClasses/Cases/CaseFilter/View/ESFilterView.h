//
//  ESFilterView.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESFilterViewDelegate <NSObject>

- (NSInteger)getSectionNums;

- (NSInteger)getItemNums:(NSInteger)section;

- (void)selectTagItem:(NSInteger)section andIndex:(NSInteger)index;
@end

@interface ESFilterView : UIView

- (instancetype)initWithDelegate:(id <ESFilterViewDelegate>)delegate;

- (void)refreshMainView;

@end

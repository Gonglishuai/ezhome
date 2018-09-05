//
//  ESLiWuMarketView.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESLiWuMarketViewDelegate <NSObject>

- (NSInteger)getItemsNumsWithSection:(NSInteger)section;

- (void)selectItemWithSection:(NSInteger)section andIndex:(NSInteger)index;
@end

@interface ESLiWuMarketView : UIView

- (instancetype)initWithDelegate:(id<ESLiWuMarketViewDelegate>)delegate;

- (void)refreshMainView;

@end

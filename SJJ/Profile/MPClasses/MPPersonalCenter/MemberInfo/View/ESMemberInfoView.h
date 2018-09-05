//
//  ESMemberInfoView.h
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESMemberInfoViewDelegate <NSObject>

- (NSInteger)getItemNum;

- (NSString *)getHeaderUrl;

- (void)uploadButtonClick;

- (void)selectItem:(NSInteger)index;

@end

@interface ESMemberInfoView : UIView

- (instancetype)initWithDelegate:(id<ESMemberInfoViewDelegate>)delegate;

- (void)refreshMainView;
@end

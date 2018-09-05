//
//  ESDesignFilterHeaderView.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESFilterHeaderViewDelegate <NSObject>

- (NSString *)getSectionHeader:(NSInteger)section;

@end

@interface ESFilterHeaderView : UICollectionViewCell

@property (nonatomic, weak) id<ESFilterHeaderViewDelegate> delegate;

- (void)updateHeader:(NSInteger)section;

@end

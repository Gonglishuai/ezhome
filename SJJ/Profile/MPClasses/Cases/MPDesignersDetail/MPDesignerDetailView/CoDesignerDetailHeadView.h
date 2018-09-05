//
//  CoDesignerDetailHeadView.h
//  Consumer
//
//  Created by xuezy on 16/7/25.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CoDesignerDetailHeadViewDelegate <NSObject>

- (NSInteger)getDesignerCommentsCount;
- (void)selectSegBtnClickWithTitleIndex:(NSInteger)index;
@end

@interface CoDesignerDetailHeadView : UIView
@property (nonatomic,weak)id<CoDesignerDetailHeadViewDelegate> delegate;
@property (nonatomic,assign)NSInteger index;
//- (void)createSegmentedView;
- (void)updateDesignerDetailHeadView;
@end

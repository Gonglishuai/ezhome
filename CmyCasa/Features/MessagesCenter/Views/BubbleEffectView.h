//
//  BubbleEffectView.h
//  Homestyler
//
//  Created by liuyufei on 5/4/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BubbleViewType)
{
    BubbleView_Community = 0,
    BubbleView_Profile = 1,
    BubbleView_DesignDetail = 2
};

@interface BubbleEffectView : UIView

@property (nonatomic, assign) BubbleViewType bubbleViewType;

- (instancetype)initWithFrame:(CGRect)frame sourceView:(UIView *)sourceView;
- (void)setupBubbleEffectWithItems:(NSArray *)items;

@end

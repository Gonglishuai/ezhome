//
//  BubbleEffectView.m
//  Homestyler
//
//  Created by liuyufei on 5/4/18.
//

#import "BubbleEffectView.h"
#import "MessagesCountDO.h"

static const CGFloat Bubble_View_MinWidth = 60;
static const CGFloat Bubble_View_Height = 43;
static const CGFloat Bubble_View_Arrow_Height = 7;

static const CGFloat Bubble_Icon_Width = 22;
static const CGFloat Bubble_Icon_Height = 18;
static const CGFloat Bubble_Item_Margin = 10;
static const CGFloat Bubble_Item_Flexible_Width = 8;
static const CGFloat Bubble_Item_Y_Margin = 18;

static NSString *const Bubble_Follow_Icon = @"notification_follow";
static NSString *const Bubble_Like_Icon = @"notification_like";
static NSString *const Bubble_Comment_Icon = @"notification_comment";
static NSString *const Bubble_Feature_Icon = @"notification_featured";
static NSString *const Bubble_Other_Icon = @"notification_other";

@interface BubbleEffectView()

@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, strong) UIImageView *bubbleBackgroundImg;
@property (nonatomic, strong) UIImage *bubbleBgImg;
@property (nonatomic, assign) CGRect sourceFrame;

@end

@implementation BubbleEffectView

- (instancetype)initWithFrame:(CGRect)frame sourceView:(UIView *)sourceView
{
    if (self = [super initWithFrame:frame])
    {
        _sourceFrame = frame;
        _sourceView = sourceView;
        [self loadView];
    }
    return self;
}

- (void)loadView
{
    self.bubbleBackgroundImg = [[UIImageView alloc] init];
    self.bubbleBackgroundImg.frame = self.bounds;
    self.bubbleBackgroundImg.contentMode = UIViewContentModeScaleToFill;
    self.bubbleBackgroundImg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.bubbleBackgroundImg];
}

- (void)setBubbleViewType:(BubbleViewType)bubbleViewType
{
    _bubbleViewType = bubbleViewType;
    switch (self.bubbleViewType) {
        case BubbleView_Community:
        case BubbleView_DesignDetail:
            self.bubbleBgImg = [UIImage imageNamed:@"bubble_community"];
            break;
        case BubbleView_Profile:
            self.bubbleBgImg = [UIImage imageNamed:@"bubble_profile"];
            break;
    }
}

- (void)setupBubbleEffectWithItems:(NSArray *)items;
{
    __block CGFloat itemViewX = Bubble_Item_Margin;
    [items enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *count = [[UILabel alloc] init];
        if ([[dict objectForKey:@"count"] integerValue] > 99)
        {
            count.text = @"99+";
        }
        else
        {
            count.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"count"]];
        }
        [count setValue:@"MessageCenter_Bubble_label" forKey:@"nuiClass"];
        count.textAlignment = NSTextAlignmentLeft;
        CGSize newSize = [count sizeThatFits:CGSizeZero];

        UIImageView *icon = [[UIImageView alloc] init];
        CGFloat iconY = Bubble_View_Arrow_Height + (Bubble_View_Height - Bubble_View_Arrow_Height - Bubble_Icon_Height) / 2;
        icon.frame = CGRectMake(itemViewX, iconY, Bubble_Icon_Width, Bubble_Icon_Height);
        icon.image = [UIImage imageNamed:[dict objectForKey:@"icon"]];
        icon.contentMode = UIViewContentModeCenter;
        [self addSubview:icon];

        CGFloat countX = icon.frame.origin.x + icon.frame.size.width;
        count.frame = CGRectMake(countX, Bubble_View_Arrow_Height, newSize.width, Bubble_View_Height - Bubble_View_Arrow_Height);
        [self addSubview:count];

        itemViewX += Bubble_Icon_Width + newSize.width;
    }];

    CGFloat width = itemViewX + Bubble_Item_Margin;
    if (width < Bubble_View_MinWidth)
    {
        width = Bubble_View_MinWidth;
    }

    CGFloat arrowToRightMargin = 0;
    if (self.bubbleViewType == BubbleView_Profile)
    {
        arrowToRightMargin = 38;
    }
    else if (self.bubbleViewType == BubbleView_Community || self.bubbleViewType == BubbleView_DesignDetail)
    {
        arrowToRightMargin = 24;
    }

    CGFloat x = self.sourceFrame.origin.x + self.sourceFrame.size.width / 2 + arrowToRightMargin - width;
    CGFloat y = self.sourceFrame.origin.y + self.sourceFrame.size.height;
    self.frame = CGRectMake(x, y, width, Bubble_View_Height);
    self.bubbleBackgroundImg.frame = self.bounds;
    UIImage *newImage = [self.bubbleBgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, Bubble_Item_Flexible_Width,
                                                                                       Bubble_Icon_Height,
                                                                                       width - 2 * Bubble_Item_Flexible_Width)
                                                         resizingMode:UIImageResizingModeStretch];
    self.bubbleBackgroundImg.image = newImage;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end

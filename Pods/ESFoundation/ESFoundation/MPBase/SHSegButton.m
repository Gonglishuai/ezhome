
#import "SHSegButton.h"

@implementation SHSegButton

+ (instancetype)createSegButtonWithTitle:(NSString *)title
                              titleColor:(UIColor *)titleColor
                         titlePlaceColor:(UIColor *)titlePlaceColor
                                    font:(CGFloat)fontNum
                                   frame:(CGRect)frame
                                  target:(id)target
                                  action:(SEL)action
                               buttonTag:(NSInteger)tag {
    
    SHSegButton *button = [SHSegButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateSelected];
    [button setTitleColor:titlePlaceColor forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:fontNum];
    button.frame = frame;
    button.buttonTag = tag;
    return button;
}

@end


#import <UIKit/UIKit.h>

@interface SHSegButton : UIButton

/// button tag.
@property (nonatomic, assign) NSInteger buttonTag;

/**
 *  @brief create seg button.
 *
 *  @param title button title.
 *
 *  @param titleColor button title color.
 *
 *  @param titlePlaceColor button title place color.
 *
 *  @param frame button frame.
 *
 *  @param target the button target.
 *
 *  @param action the target action.
 *
 *  @param tag the button tag.
 *
 *  @return instancetype button.
 */
+ (instancetype)createSegButtonWithTitle:(NSString *)title
                              titleColor:(UIColor *)titleColor
                         titlePlaceColor:(UIColor *)titlePlaceColor
                                    font:(CGFloat)font
                                   frame:(CGRect)frame
                                  target:(id)target
                                  action:(SEL)action
                               buttonTag:(NSInteger)tag;

@end

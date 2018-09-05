
#import <UIKit/UIKit.h>

@interface ESProductAddressLabel : UILabel

// 长按出复制按钮时label的背景颜色, 默认为#EBECED
@property (nonatomic, retain) UIColor *addressLabelTappedBackgroundColor;

// 取消复制或者复制结束后label的背景颜色, 默认为白色
@property (nonatomic, retain) UIColor *addressLabelBackgroundColor;

@end

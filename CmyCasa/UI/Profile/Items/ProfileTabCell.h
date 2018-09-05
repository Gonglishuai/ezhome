//
//  ProfileTabCell-iPad.h
//  Homestyler
//
//  Created by Ma'ayan on 12/16/13.
//
//

#import <UIKit/UIKit.h>

@interface ProfileTabCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnIcon;

- (void)setWithTitle:(NSString *)title counter:(NSString *)counter andSelected:(BOOL)isSelected iconString:(NSString *)iconString;
- (void)setWithTitle:(NSString *)title counter:(NSString *)counter andSelected:(BOOL)isSelected icon:(UIImage *)iconImage;

@end

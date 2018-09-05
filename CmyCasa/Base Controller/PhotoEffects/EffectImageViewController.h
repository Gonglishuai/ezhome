//
//  EffectImageViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/10/13.
//
//

#import <UIKit/UIKit.h>
#import "ImageEffectsBaseViewController.h"

@interface EffectImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *effectImage;
@property (weak, nonatomic) IBOutlet UIButton *effectActionButtoh;
- (IBAction)effectApplyAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *effectTitle;

@property (weak, nonatomic) IBOutlet UIImageView *frameImage;
@property(nonatomic) NSInteger effectIndex;
@property (strong, nonatomic)id<ImageEffectsCellDelegate> delegate;
@end

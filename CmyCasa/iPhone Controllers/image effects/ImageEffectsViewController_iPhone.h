//
//  ImageEffectsViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/13/13.
//
//

#import "ImageEffectsBaseViewController.h"

@interface ImageEffectsViewController_iPhone : ImageEffectsBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *btnLeftButton;

- (IBAction)toggleEffectsPresentation:(id)sender;

@end

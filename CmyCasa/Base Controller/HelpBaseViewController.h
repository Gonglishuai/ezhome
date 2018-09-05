//
//  HelpBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import <UIKit/UIKit.h>

@interface HelpBaseViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *helpImageUI;
@property (weak, nonatomic) IBOutlet UIButton *closeHelpButton;
@property (nonatomic) NSString * pageKey;
@property (nonatomic) NSMutableArray* extraKeys;

-(IBAction)closeHelpAction:(id)sender;
-(void)setBtnState:(BOOL) bIsEnabled;
-(void)loadHelpImage;
-(void)loadHelpLabels:(CGSize)imageSize;

@end

//
//  ProfProjectItemViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/13/13.
//
//

#import <UIKit/UIKit.h>

@interface ProfProjectItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *projectImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UIButton *clickProjectButton;

-(void)loadImageForURL:(NSString*)imageUrl;
@end

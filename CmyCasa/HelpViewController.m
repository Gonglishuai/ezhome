//
//  HelpViewController.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/3/13.
//
//

#import "HelpViewController.h"
#import "HelpManager.h"
#import "UILabel+Size.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
@synthesize pageKey,extraKeys;

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self loadHelpImage];
}

-(void)HelpImageLoaded:(NSNotification*)notification{
    NSString* path = [[notification userInfo] objectForKey:@"path"];
    
    UIImage * img=[UIImage safeImageWithContentsOfFile:path];
    if(img!=NULL)
    {
        [self.helpImageUI setImage:img];
        [self loadHelpLabels:img.size];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)closeHelpAction:(id)sender {
    if (self.closeHelpButton) self.closeHelpButton.enabled = NO;
    NSString* strKey = pageKey;
    
    if (extraKeys==nil || [extraKeys count]==0) {
        [[HelpManager sharedInstance] helpClosedForKey:strKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:HelpViewClosedNotification object:strKey];
        
    }else{
        if([extraKeys count]>0)
        {
            
            NSString * nextKey=[extraKeys objectAtIndex:0];
            [extraKeys removeObjectAtIndex:0];
            self.pageKey=nextKey;
            
            [self loadHelpImage];
        }
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}
@end

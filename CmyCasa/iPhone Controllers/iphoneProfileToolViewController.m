//
//  iphoneProfileToolViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/5/13.
//
//

#import "iphoneProfileToolViewController.h"

@interface iphoneProfileToolViewController ()

@end

@implementation iphoneProfileToolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)navigateBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signoutUser:(id)sender {
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        return;
    }else{
#ifdef USE_FLURRY
        if([(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"SendFlurryInfo"] boolValue]){
           
                [HSFlurry logEvent: FLURRY_SIGNOUT];
            
        }
#endif
        
        
        self.userFirstName.text=@"";
        self.userLastName.text=@"";
        
        self.profileImage.image=nil;
        
        
        [[AppCore sharedInstance] logoutUser];
        
        
        [self navigateBack:nil];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"myArticles"])
	{
        
    }

    if ([segue.identifier isEqualToString:@"editProfileID"])
	{
        
    }

    
    if ([segue.identifier isEqualToString:@"followedProfessionalsID"])
	{
        
    }

    if ([segue.identifier isEqualToString:@"savedDesignsID"])
	{
        
    }
}

@end

//
//  ProfProjGalleryViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/31/13.
//
//

#import "ProfProjGalleryViewController.h"
#import "ProfProjectItemViewController.h"
#import "ControllersFactory.h"

@interface ProfProjGalleryViewController ()


@property(nonatomic)NSMutableDictionary * projectAssetsDictionary;
@end

@implementation ProfProjGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.projectAssetsDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    [self setScrollView:nil];
    [self setNameLabel:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateImages {

    for(int idx = 0; idx < [self.mproject.projectAssets count]; idx++) {
        ProfProjectAssetDO * asset=[self.mproject.projectAssets objectAtIndex:idx];
        NSString* imageUrl  = asset.url;
        ProfProjectItemViewController * ppc= [self.projectAssetsDictionary objectForKey:asset._id];
        [ppc loadImageForURL:imageUrl];
    }
}

- (void)imagePressed:(id)sender {
    UIButton* button = (UIButton*) sender;
    
    if (self.delegate != nil) {
        [self.delegate designSelected:[self.mproject projectAssets] :(int)button.tag];
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (void) setProject:(ProfProjects*) project {
    
    self.mproject=project;
    for (UIView *v in [self.scrollView subviews]) {
        [v removeFromSuperview];
    }
    
    self.nameLabel.text = project.projectName;//[project objectForKey:@"name"];
    
    NSArray* assets =project.projectAssets;// [project objectForKey:@"assets"];
    
    int x = 0;
    for(ProfProjectAssetDO * design in assets) {
        
        
        ProfProjectItemViewController * ppc= [ControllersFactory instantiateViewControllerWithIdentifier:@"profProjectItemViewController" inStoryboard:kProfessionalsStoryboard];
              
        ppc.view.frame = CGRectMake(20 + x * 240, 0, 220, 220);
        [self.scrollView addSubview:ppc.view];
  
  
        [self.projectAssetsDictionary setObject:ppc forKey:design._id];
        
        
        
        [ppc.clickProjectButton addTarget:self action:@selector(imagePressed:) forControlEvents:UIControlEventTouchUpInside];
        ppc.clickProjectButton.tag = x; //TODO: check how +1 effects the images
    
        x++;
    }
    
    self.scrollView.contentSize = CGSizeMake(20 + x*240, self.scrollView.frame.size.height);
    [self updateImages];
}


@end

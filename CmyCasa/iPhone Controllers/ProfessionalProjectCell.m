//
//  ProfessionalProjectCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/1/13.
//
//

#import "ProfessionalProjectCell.h"
#import "iphoneProfProjectAssetController.h"
#import "ControllersFactory.h"

#define ASSET_PROJECT_WIDTH 300
#define ASSET_PROJECT_MARGIN 20
@implementation ProfessionalProjectCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithProject:( ProfProjects *)project{
    self.projects=project;
    
    if (self.scrolledItems==nil) {
        self.scrolledItems=[NSMutableArray arrayWithCapacity:0];
    }
    
    //clean already existing objects before new refill
    for (int i=0; i<[self.scrolledItems count]; i++) {
        iphoneProfProjectAssetController * iph=[self.scrolledItems objectAtIndex:i];
        iph.assetImage.image=[UIImage imageNamed:@"place_holder"];
        iph.asset=nil;
        iph.isAssetLoaded=NO;
        [iph.activity stopAnimating];
        [iph.view removeFromSuperview];
    }
  
    int totalWidth=0;
    for(int i=0;i<[[project projectAssets] count];i++)
    {
        iphoneProfProjectAssetController * iph=nil;
        if (i<[self.scrolledItems count]){
            iph=[self.scrolledItems objectAtIndex:i];
        }else{
            
            iph= [ControllersFactory instantiateViewControllerWithIdentifier:@"profProjectAssetController" inStoryboard:kProfessionalsStoryboard];
            
            iph.view=iph.view;
            [self.scrolledItems addObject:iph];
        }
        
        CGRect frame=iph.view.frame;
  
        frame.origin.x=i*ASSET_PROJECT_WIDTH;
        
          iph.delegate=self;
        //load only first 2
        if (i<2) {
            [iph initWithAssset:[self.projects.projectAssets objectAtIndex:i]];   
        }
        
        [self.assetsScroller addSubview:iph.view];
       iph.view.frame=CGRectMake(i*ASSET_PROJECT_WIDTH, 0, 320, 296);
    }
    totalWidth = (int)([[project projectAssets] count]*ASSET_PROJECT_WIDTH);
    
    [self.assetsScroller setContentOffset:CGPointMake(0, 0)];
    [self.assetsScroller setContentSize:CGSizeMake(totalWidth, 296)];
}

-(void)designSelected:(ProfProjectAssetDO*)selectedDesign{
    
    //self.projects
    int index = (int)([[self.projects projectAssets] indexOfObject:selectedDesign]);
    
    FullScreenViewController_iPhone * fullScreen = [[UIManager sharedInstance] createIphoneFullScreenGallery:[self.projects projectAssets] withSelectedIndex:index eventOrigin:nil ];
    fullScreen.isFullScreenFromProfessionals=YES;
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:fullScreen animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  int tempItemIndex=self.assetsScroller.contentOffset.x/self.assetsScroller.frame.size.width;
  
    if (tempItemIndex<[self.scrolledItems count]&& tempItemIndex>-1) {
        iphoneProfProjectAssetController * iph=[self.scrolledItems objectAtIndex:tempItemIndex];
        if (iph.isAssetLoaded==NO && tempItemIndex<[self.projects.projectAssets count]) {
             [iph initWithAssset:[self.projects.projectAssets objectAtIndex:tempItemIndex]]; 
            
        }
    }
}

@end









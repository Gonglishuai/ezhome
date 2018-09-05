//
//  ProfileProfessionalsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileProfessionalsViewController.h"
#import "ProfessionalsResponse.h"
#import "ProfessionalCell.h"
#import "ControllersFactory.h"
#import "UserProfileBaseTableViewController.h"

@interface ProfileProfessionalsViewController ()
@property (strong, nonatomic) NSMutableArray* professionals;
@end

@implementation ProfileProfessionalsViewController

//Forces Table/Collection to reload Data
-(void)refreshContent{
    [self.contentViewer refreshContent];
}

-(void)initContent {
    
    if (self.isLoggedInUserProfile) {
        self.professionals = [[AppCore sharedInstance] getProfsManager].followedProfessionals;
    }else{
        self.professionals = [NSMutableArray array];
    }
    
    [self loadFollowedProfessionals];
    [self.contentViewer initDisplay:self.professionals];
    [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
}

#pragma mark- Super class overrides
-(void)initContentViewer{
    
    if(self.contentViewer== nil)
    {
        self.contentViewer = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileTableViewVC" inStoryboard:kProfileStoryboard];
                
        [self.contentViewer startLoadingIndicator];
        
        self.contentViewer.dataDelegate=self;
        [self addChildViewController:self.contentViewer];
        [self.view addSubview:self.contentViewer.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadFollowedProfessionals{
    if (self.isLoggedInUserProfile) {
        
        // New way to get professionals with caching system
        [[[AppCore sharedInstance] getProfsManager] getUserFollowedProfessionalsWithFinishBlock:^(BOOL status) {
            self.professionals = [[AppCore sharedInstance] getProfsManager].followedProfessionals;
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self.contentViewer stopLoadingIndicator];
                           });
            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            
            if(self.rootProfsDelegate && [self.rootProfsDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
                
                [self.rootProfsDelegate updateProfileCounter:(int)self.professionals.count ForTab:ProfileTabProfessionals];
            }
        }];
        
    }else{
        
        NSString * userId;
        
        if (self.rootProfsDelegate && [self.rootProfsDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)])
        {
            userId= [self.rootProfsDelegate getUserIDForCurrentProfile];
        }
        
        if (!userId){
            [self.contentViewer stopLoadingIndicator];
            return;
        }
        
        [[[AppCore sharedInstance]getProfsManager] getFollowedProfessionalsByUserId:userId startingAt:0 withLimit:300 completionBlock:^(id serverResponse, id error) {
            if (!error) {
                ProfessionalsResponse * resp=(ProfessionalsResponse*)serverResponse;
                
                [((NSMutableArray*)self.professionals) removeAllObjects];
                [((NSMutableArray*)self.professionals) addObjectsFromArray:resp.professionals];
            }
            
            [self.contentViewer stopLoadingIndicator];
            
            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            
            if(self.rootProfsDelegate && [self.rootProfsDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
                
                [self.rootProfsDelegate updateProfileCounter:(int)self.professionals.count ForTab:ProfileTabProfessionals];
            }
        } queue:dispatch_get_main_queue()];
    }
}

#pragma mark - ProfessionalCellDelegate
-(void)rowSelectedAtIndex:(NSIndexPath*)indexPath{
    
    if (indexPath.row < self.professionals.count)
    {
        [self professionalPressed:[self.professionals[indexPath.row] _id]];
        
    }
}

- (void)professionalPressed:(NSString*)professionalId{
    
    if(self.rootProfsDelegate && [self.rootProfsDelegate respondsToSelector:@selector(professionalPressed:)])
    {
        [self.rootProfsDelegate professionalPressed:professionalId];
    }
    
}

-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path{
    
    return @"Professionals Cell";
}


-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath*)indexPath{
    
    return [[ProfessionalCell alloc] init];
}

- (NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path{
    
    return 165;
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{
    
    if (isCurrentUser)
        return NSLocalizedString(@"myhome_no_profs_copy", "");
    else
        return NSLocalizedString(@"myhome_no_profs_copy_other", "");
}

@end

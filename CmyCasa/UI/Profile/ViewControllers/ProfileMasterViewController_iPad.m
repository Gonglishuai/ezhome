//
//  ProfileMasterViewController_iPad.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/22/13.
//
//

#import "ProfileMasterViewController_iPad.h"
#import "ControllersFactory.h"
#import "ProfileTabCell.h"
#import "UIImageView+ViewMasking.h"
#import "NewBaseProfileViewController.h"

@interface ProfileMasterViewController_iPad ()

@property (weak, nonatomic) IBOutlet UITableView *tableInfo;

@end

@implementation ProfileMasterViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
    [self.profileImage setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[self refreshTableMenu];
}

#pragma mark - Update UI

-(void)refreshTableMenu{
    [self.tableInfo reloadData];
}

- (void)updateMasterMenuDisplay {
    [super updateMasterMenuDisplay];

     CGRect frame = self.editProfileButton.frame;
    if (!self.isLoggedInUserProfile) {
        frame.size.width=208;
        frame.origin.x=28;
    }
    
    self.editProfileButton.frame=frame;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.tableInfo reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
    BOOL isMagazineActive = [ConfigManager isMagazineActive];
    BOOL isProfessionalIndexActive = [ConfigManager isProfessionalIndexActive];

    if (!isMagazineActive && !isProfessionalIndexActive) {
        return 2;
    }else if((!isMagazineActive && isProfessionalIndexActive) || (isMagazineActive && !isProfessionalIndexActive)){
        return 3;
    }else{
        return TABS_NUMBER_OF_TABS;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    static NSString* identifierInfo = @"ProfileTabCell";
    cell = [tableView dequeueReusableCellWithIdentifier:identifierInfo forIndexPath:indexPath];
    
    [(ProfileTabCell *) cell setWithTitle:[self getTitleForTabCellNum:ProfileTabDesign]
                                  counter:[self getCounterForTabCellNum:ProfileTabDesign]
                              andSelected:[self isTabSelectedAtIndex:ProfileTabDesign]
                               iconString:[self getIconStringFotMenuOptionAtIndex:ProfileTabDesign]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewBaseProfileViewController *currentVc = (NewBaseProfileViewController *)self.parentViewController;
    if (self.selectedTab==indexPath.row || currentVc.isShowSystemIcon) {
        return;
    }
    
    //remember the new selected tab
    self.selectedTab = ProfileTabDesign;
    
    [tableView reloadData];
    [self activatePageSelection:self.selectedTab ];
}

#pragma mark - Profile Tab Cells Helpers
- (NSString*)getIconStringFotMenuOptionAtIndex:(NSInteger)row {
 
    ProfileTabs tab=(ProfileTabs)row;
    
    NSString *iconString=@"";
    
    switch (tab) {
        case ProfileEditProfileViewer:
            break;
        case ProfileTaUnvisibleProfileViewer:break;
        case ProfileTabUnknown:break;
        case ProfileTabActivities:
            iconString=@"";
            break;
        case ProfileTabDesign:
            iconString=@"";
            break;
        case ProfileTabProfessionals:
            iconString=@"";
            break;
        case ProfileTabArticles:
            iconString=@"";
            break;
        case ProfileTabFollowers:break;
        case ProfileTabFollowing:break;
        default:
            break;
    }
    
    return iconString;
}


- (NSString *)getTitleForTabCellNum:(ProfileTabs)num
{
    NSString *strTitle = @"";

    switch (num)
    {
        case ProfileTabDesign:
            if (self.isLoggedInUserProfile)
                strTitle = TABS_TITLE_MY_DESIGNS;
            else
                strTitle = TABS_TITLE_OTHER_DESIGNS;
            break;
        case ProfileTabFollowers:
            strTitle = TABS_TITLE_FOLLOWERS;
            break;
        case ProfileTabFollowing:
            strTitle = TABS_TITLE_FOLLOWING;
            break;
        case ProfileTabArticles:
            strTitle = TABS_TITLE_HEARTED_ARTICLES;
            break;
        case ProfileTabProfessionals:
            strTitle = TABS_TITLE_FOLLOWED_PROFFESIONALS;
            break;
        case ProfileTabActivities:
            strTitle= TABS_TITLE_ACTIVITY;
            break;
        default:
            break;
    }
    return strTitle;
}

- (NSString *)getCounterForTabCellNum:(int)num
{

    if(self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(getProfileCounterValueFor:)])
    {
       return  [self.ownerDelegate getProfileCounterValueFor:num];
    }
    return @"";
}

- (BOOL)isTabSelectedAtIndex:(int)index
{
    return (self.selectedTab == index);
}

#pragma mark- Overrifes
- (IBAction)editProfileAction:(id)sender{
    [super editProfileAction:sender];
    [self.tableInfo reloadData];
}

- (IBAction)opendUserProfileReadOnlyAction:(id)sender{
    [super opendUserProfileReadOnlyAction:sender];
    [self.tableInfo reloadData];
}

-(void)openDesignsTab{
    
    [self activatePageSelection:ProfileTabDesign];
    [self.tableInfo reloadData];
}

-(void)openActivityTab{
    
    [self activatePageSelection:ProfileTabActivities];
    [self.tableInfo reloadData];
}
@end

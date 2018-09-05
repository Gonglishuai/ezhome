//
//  ProfilePagesMenuViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/25/13.
//
//

#import "ProfilePagesMenuViewController_iPhone.h"
#import "ProfileTabCell.h"


@interface ProfilePagesMenuViewController_iPhone ()
@property (weak, nonatomic) IBOutlet UITableView *menuTable;

-(void)closeMenuAfterSelection;
@end

@implementation ProfilePagesMenuViewController_iPhone

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)refreshTableMenu{
    [self.menuTable reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    [(ProfileTabCell *) cell setWithTitle:[self getTitleForTabCellNum:(int)indexPath.row]
                                       counter:[self getCounterForTabCellNum:(int)indexPath.row]
                                   andSelected:[self isTabSelectedAtIndex:(int)indexPath.row]
                                          iconString:[self getIconStringFotMenuOptionAtIndex:indexPath.row]];


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0f;
}

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


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //remember the new selected tab
    self.selectedTab = (int)indexPath.row;

    [tableView reloadData];

    //log flurry
    NSString* event;
    switch (self.selectedTab) {
        case ProfileTabDesign:
            event = FLURRY_PROFILE_DESIGNS_MENU_CLICK;
            break;
        case ProfileTabFollowers:
            event = FLURRY_PROFILE_FOLLOWERS_MENU_CLICK;
            break;
        case ProfileTabFollowing:
            event = FLURRY_PROFILE_FOLLOWINGS_MENU_CLICK;
            break;
        case ProfileTabArticles:
            event = FLURRY_PROFILE_ARTICLES_MENU_CLICK;
            break;
        case ProfileTabProfessionals:
            event = FLURRY_PROFILE_PROFESSIONALS_MENU_CLICK;
            break;
        case ProfileTabActivities:
            event = FLURRY_PROFILE_ACTIVITY_MENU_CLICK;
            break;
        default:
            event = nil;
            break;
    }

    // Add "My" so we'll know it's the user's profile
    if ((self.isLoggedInUserProfile) && (event != nil))
    {
        event = [NSString stringWithFormat:@"My %@", event];
    }

//   if(event!= nil) [HSFlurry logAnalyticEvent:event];

    [self closeMenuAfterSelection];
}

#pragma mark - Profile Tab Cells Helpers

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

-(void)closeMenuAfterSelection{

    [self closeMenuUI];
}

- (IBAction)cancelMenuSelection:(id)sender {
    
    [self closeMenuUI];
}

- (void)selectRowForTab:(ProfileTabs)tabs {
    
    self.selectedTab=tabs;
    [self.menuTable reloadData];
}

- (void)presentForContainer:(UIViewController *)controller {

    CGRect frame=self.view.frame;

    frame.origin.y=controller.view.frame.origin.y+controller.view.frame.size.height;
    self.view.frame=frame;

    [controller.view addSubview:self.view];

    frame.origin.y=0;
    [UIView animateWithDuration:0.2 animations:^{

       self.view.frame=frame;

    } completion:^(BOOL finished) {

    }];
}

- (void)closeMenuUI{
    CGRect frame=self.view.frame;

    frame.origin.y=self.view.superview.frame.origin.y+self.view.superview.frame.size.height;

    [UIView animateWithDuration:0.2 animations:^{

        self.view.frame=frame;

    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(profileTabSelectionChange:)]) {
            [self.ownerDelegate profileTabSelectionChange:self.selectedTab];
        }
    }];
}
@end

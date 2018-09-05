//
//  ProfessionalPageViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/1/13.
//
//

#import "ProfessionalPageViewController_iPhone.h"
#import "ProfessionalProjectCell.h"
#import "ProfProjectAssetDO.h"
#import "UILabel+Size.h"
#import "ProfessionalInfoCell.h"
#import "ProfessionalDetailsViewController_iPhone.h"
#import "ProfessionalsResponse.h"
#import "ControllersFactory.h"
#import "ProgressPopupViewController.h"

@interface ProfessionalPageViewController_iPhone ()

@property (nonatomic, assign) NSInteger firstRowHeight;
@end


@implementation ProfessionalPageViewController_iPhone


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    self.screenName = GA_PROFESSIONAL_SCREEN;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstRowHeight=300;
   
    if ([self.professional isExtraInfoLoaded]) {
        [self fillProfessionalInfo];
    }else{
        [self startLoading];
        [self updateData];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"ProfessionalPageViewController_iPhone deallocated");
}

#pragma mark - Class Function
-(void)startLoading{
      [[ProgressPopupBaseViewController sharedInstance] startLoading :self];
}

-(void)stopLoading{
      [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

- (void) updateData {
    
    [[[AppCore sharedInstance] getProfsManager] getProffesionalByID:self.professional._id completionBlock:^(id serverResponse, id error) {
        
        if (error){
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"proffesional_load_failed_msg", @"There was a problem loading this protfolio.\nPlease try again") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
            [alert show];
        }else{
            ProfessionalsResponse * profData = (ProfessionalsResponse*)serverResponse;
            self.professional = profData.currentProfessional;
            
            [self fillProfessionalInfo];
            [self stopLoading];
        }
        
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
}

-(void)fillProfessionalInfo{
    [self.tableView reloadData];
}

-(void)changeFirstCellHeight:(NSNumber*)newHeight{
    
    self.firstRowHeight = [newHeight floatValue];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return self.firstRowHeight;
    }
    
	return 297; //returns floating point which will be used for a cell row height at specified row index
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([self.professional isExtraInfoLoaded]) {
        return [[self.professional projects] count]+1;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"";
    }
    return  [[self.professional.projects objectAtIndex:section-1] projectName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    return 36.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return nil;
    }
    
    UIView * vw=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    
    vw.backgroundColor=[UIColor whiteColor];
    
    UILabel * lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 8, 300, 30)];
    lbl.textColor=[UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    lbl.text= [[self.professional.projects objectAtIndex:section-1] projectName];
    lbl.backgroundColor=[UIColor clearColor];
    [lbl setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [vw addSubview:lbl];
    return vw;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierInfo = @"CellInfo";
    
    if (indexPath.section==0) {
        ProfessionalInfoCell * cell=(ProfessionalInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifierInfo];
        cell.delegate=self;
        [cell initWithProf:self.professional];
        
        
        return  cell;
    }else{
        //create project cells
        ProfessionalProjectCell * cell=(ProfessionalProjectCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        ProfProjects * project = nil;
        NSArray * projects = [self.professional projects];
        if (projects && indexPath.section-1 < [projects count]) {
            project = [projects objectAtIndex:indexPath.section-1];
        }
        
        [cell initWithProject:project];
        
        return  cell;
    }
}

-(void)openProfessionalDetails{
   
    ProfessionalDetailsViewController_iPhone * iph= [ControllersFactory instantiateViewControllerWithIdentifier:@"professionalDetailsViewController" inStoryboard:kProfessionalsStoryboard];
        
    iph.professional = self.professional;
    [self.navigationController pushViewController:iph animated:YES];
}

- (IBAction)navBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changeFollowStatusForProfessional{
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_FOLLOW_PROFESSIONAL, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE}];
        
        [[UIMenuManager sharedInstance] loginRequestedIphone:self.parentViewController loadOrigin:EVENT_PARAM_LOAD_ORIGIN_LIKE ];
        NSIndexPath * path=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
         return;
    }
    
    BOOL isCurrentlyFollowed = [[[AppCore sharedInstance] getProfsManager] isProfessionalFollowed:self.professional._id];
    
    [[[AppCore sharedInstance] getProfsManager] followProfessional:self.professional._id followStatus:!isCurrentlyFollowed completionBlock:^(id serverResponse, id error) {
        
        NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:0];
        ProfessionalInfoCell * cell = (ProfessionalInfoCell*)[self.tableView cellForRowAtIndexPath:path];

        if (error) {
            //on response failure we do reverse action of what we did before and assign backup Count
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                           message:NSLocalizedString(@"prof_follow_error", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles: nil];
            [alert show];
            [cell toggleLikeBtn];
        }
        
        [self.tableView reloadData];
        
        //work around
        [cell.likeButtonLiked setEnabled:YES];
        [cell.likeButton setEnabled:YES];
        
    } queue:dispatch_get_main_queue()];
}


#pragma mark - Login delegate
- (void) loginRequestEndedwithState:(BOOL) state{
   state ? [self changeFollowStatusForProfessional] : [[self tableView] reloadData];
}

@end

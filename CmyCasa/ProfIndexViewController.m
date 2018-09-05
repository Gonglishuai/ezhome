//
//  ProfIndexViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import "ProfIndexViewController.h"
#import "ProfessionalIndexCell.h"
#import "ControllersFactory.h"

@implementation ProfIndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //QA Compatibility Labels:
    self.view.accessibilityLabel = @"Professional's Index";
    
    [self.loadingView setHidden:NO];
    
    [self.professionBtn setTitle:NSLocalizedString(@"profession_filter_button_name", @"Profession") forState:UIControlStateNormal];
    [self.locationBtn setTitle:NSLocalizedString(@"location_filter_button_name", @"Area of Service") forState:UIControlStateNormal];
    
    [self updateProfessionBtnPosition];
    
    [self updateLocationBtnPosition];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"dealloc - ProfIndexViewController");
}

#pragma mark -
- (void)updateLocationBtnPosition {
    
    self.locationBtn.frame = CGRectMake(self.professionBtn.frame.origin.x + self.professionBtn.frame.size.width + 62, self.locationBtn.frame.origin.y, self.locationBtn.frame.size.width, self.locationBtn.frame.size.height);
    [self.locationBtn sizeToFit];
    self.lblLocationDropDown.frame = CGRectMake(self.locationBtn.frame.origin.x + self.locationBtn.frame.size.width + 5, self.lblLocationDropDown.frame.origin.y, self.lblLocationDropDown.frame.size.width, self.lblLocationDropDown.frame.size.height);
    self.locationBtn.frame = CGRectMake(self.locationBtn.frame.origin.x, self.locationBtn.frame.origin.y, self.locationBtn.frame.size.width + 30, self.locationBtn.frame.size.height);
}

- (void)updateProfessionBtnPosition {
    
    [self.professionBtn sizeToFit];
    self.lbProfessionDropDown.frame = CGRectMake(self.professionBtn.frame.origin.x + self.professionBtn.frame.size.width + 5, self.lbProfessionDropDown.frame.origin.y, self.lbProfessionDropDown.frame.size.width, self.lbProfessionDropDown.frame.size.height);
    self.professionBtn.frame = CGRectMake(self.professionBtn.frame.origin.x, self.professionBtn.frame.origin.y, self.professionBtn.frame.size.width + 30, self.professionBtn.frame.size.height);
}

- (void)professionSelected:(NSString*) key :(NSString*) value {
    [super professionSelected:key :value];
    
    [_professionsPopover dismissPopoverAnimated:YES];
    
    
    if (self.selectedProfessionKey != nil) {
        [self.professionBtn setTitle:value forState:UIControlStateNormal];
    }
    else {
        [self.professionBtn setTitle:NSLocalizedString(@"profession_filter_button_name", @"Profession") forState:UIControlStateNormal];
    }
    
    [self updateProfessionBtnPosition];
    [self updateLocationBtnPosition];
}

- (void)locationSelected:(NSString*) key :(NSString*) value {
    [super locationSelected:key :value];
    [_locationsPopover dismissPopoverAnimated:YES];
    
    if (self.selectedLocationKey != nil) {
        [self.locationBtn setTitle:value forState:UIControlStateNormal];
    }
    else {
        [self.locationBtn setTitle:NSLocalizedString(@"location_filter_button_name", @"Area of Service") forState:UIControlStateNormal];
    }
    
    [self updateLocationBtnPosition];
}

- (void) populateProfessionals:(NSMutableArray*) professionals {
    [super populateProfessionals:professionals];
    
    if ([self.currentProfessionals count]==0) {
        [self.tableview setHidden:YES];
        [self.noResultsView setHidden:NO];
    }else{
        [self.noResultsView setHidden:YES];
        [self.tableview setHidden:NO];
    }
    
    [self.tableview reloadData];
    [self.loadingView setHidden:YES];
}

- (void) updateProfessionals {
    [self.loadingView setHidden:NO];
    [super updateProfessionals];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"professionsSague"])
	{
		ProfessionsPopupViewController* professionsPopup = [segue destinationViewController];
        _professionsPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [professionsPopup setProfessions:self.filterNames.professions];
        professionsPopup.delegate = self;
	}
    else if ([segue.identifier isEqualToString:@"locationsSague"])
	{
		LocationsPopupViewController* locationsPopup = [segue destinationViewController];
        _locationsPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [locationsPopup setLocations:self.filterNames.locations];
        locationsPopup.delegate = self;
	}
}

- (void) professionalSelected:(NSString*)profId {
    ProfPageViewController* profPageViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
    [profPageViewController setProfId:profId];
    [self.navigationController pushViewController:profPageViewController animated:YES];
}

- (IBAction)addPortfolioPressed:(id)sender {
    
    [self openProfSignupPage];
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 142; //returns floating point which will be used for a cell row height at specified row index
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result = [self.currentProfessionals count];
	return result;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ProfCell";
    
    ProfessionalIndexCell * cell = (ProfessionalIndexCell*)[self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ProfessionalDO * prof = [self.currentProfessionals objectAtIndex:indexPath.row];
    
    cell.profileImage.image = nil;
    
    cell.delegate = self;
    
    [cell setProfessional:prof];
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfessionalDO * prof=[self.currentProfessionals objectAtIndex:indexPath.row];
    
    [self professionalSelected:prof._id];
}

- (IBAction)backPressed:(id)sender
{
    [super backPressed:sender];
    
    [[UIMenuManager sharedInstance] backPressed:sender];
}

@end

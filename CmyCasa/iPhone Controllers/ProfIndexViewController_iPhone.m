//
//  iphoneProfIndexViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import "ProfIndexViewController_iPhone.h"
#import "ProffesionalCell.h"
#import "ProgressViewController_iPhone.h"
#import "ProfessionalPageViewController_iPhone.h"
#import "NSString+ImageResizer.h"
#import "ControllersFactory.h"

@interface ProfIndexViewController_iPhone ()

@property (nonatomic) NSMutableArray * professionals;
@property (nonatomic) NSInteger tempProfSelectedIndex;
@property (nonatomic) NSInteger tempLocationSelectedIndex;
@property (nonatomic) ProfFilterNameItemDO * locationSelectedItem;
@property (nonatomic) ProfFilterNameItemDO * profSelectedItem;

@end

@implementation ProfIndexViewController_iPhone


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:YES];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(void)dealloc{
    NSLog(@"dealloc - ProfIndexViewController_iPhone");
}

#pragma mark - Class Function
-(void)updateProfessionals{
    [[ProgressPopupBaseViewController sharedInstance] startLoading :self];
    [super updateProfessionals];
}

-(void)populateProfessionals:(NSMutableArray *)professionals{
    self.professionals = [NSMutableArray arrayWithArray:professionals];
    
    if ([self.professionals count]==0) {
        self.noProfsTitle.text=NSLocalizedString(@"no_profs_for_selected_filter", @"");
        self.noProfsTitle.hidden=NO;
        self.messageLabel.hidden = NO;
    }else{
        self.noProfsTitle.text=@"";
        self.noProfsTitle.hidden=YES;
        self.messageLabel.hidden = YES;
    }
    [self.tableView reloadData];
   [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

-(IBAction)openMenu:(id)sender{
    [[UIMenuManager sharedInstance] openMenu:self];
}

- (IBAction)addPortfolioPressed:(id)sender {
    [self openProfSignupPage];
}

- (IBAction)closeFilterPicker:(id)sender {
    
    self.tempProfSelectedIndex=-1;
    self.tempLocationSelectedIndex=-1;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.filterPickerView.frame=CGRectMake(0, self.view.frame.size.height, self.filterPickerView.frame.size.width, self.filterPickerView.frame.size.height);
    } completion:^(BOOL finished) {
        self.filterPickerView.hidden = YES;
        
        self.profButton.enabled = YES;
        self.locationButton.enabled = YES;
    }];
}

- (IBAction)closeFilterAndPerformAction:(id)sender {
    
    if (self.tempLocationSelectedIndex>-1 && self.tempLocationSelectedIndex<[self.currentFilterValues count]) {
        
        self.locationSelectedItem =  [self.currentFilterValues objectAtIndex:self.tempLocationSelectedIndex];
        [self locationSelected:self.locationSelectedItem.key :self.locationSelectedItem.name];
        
        [self.locationButton setTitle:self.locationSelectedItem.name forState:UIControlStateNormal];
        self.tempLocationSelectedIndex = -1;
    }
    
    if (self.tempProfSelectedIndex>-1 && self.tempProfSelectedIndex<[self.currentFilterValues count]) {
        
        self.profSelectedItem = [self.currentFilterValues objectAtIndex:self.tempProfSelectedIndex];
        
        [self professionSelected:self.profSelectedItem.key :self.profSelectedItem.name];
        [self.profButton setTitle:self.profSelectedItem.name forState:UIControlStateNormal];
        self.tempProfSelectedIndex=-1;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.filterPickerView.frame=CGRectMake(0, self.view.frame.size.height, self.filterPickerView.frame.size.width, self.filterPickerView.frame.size.height);
    } completion:^(BOOL finished) {
        self.filterPickerView.hidden=YES;
        self.locationButton.enabled = YES;
        self.profButton.enabled = YES;
    }];
}

- (IBAction)openProfFilterOptions:(id)sender {
    self.locationButton.enabled = NO;
    
    if (self.filterNames) {
        
        self.currentFilterValues=self.filterNames.professions;
        [self.itemsPicker reloadAllComponents];
        
        if (self.profSelectedItem) {
            self.tempProfSelectedIndex=[self.filterNames.professions indexOfObject:self.profSelectedItem];

            if (self.tempProfSelectedIndex < [self.currentFilterValues count]) {
                [self.itemsPicker selectRow:self.tempProfSelectedIndex inComponent:0 animated:NO];
            }
        }
        
        if (self.filterPickerView.hidden) {
            [self openSelectedFilterUI];
        }
    }
}

-(void)openSelectedFilterUI{
    if(self.filterPickerView.hidden){
        self.filterPickerView.hidden=NO;
        self.filterPickerView.frame=CGRectMake(0, self.view.frame.size.height, self.filterPickerView.frame.size.width, self.filterPickerView.frame.size.height);
        self.filterPickerView.backgroundColor=[UIColor whiteColor];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.filterPickerView.frame=CGRectMake(0, self.view.frame.size.height-267, self.filterPickerView.frame.size.width, self.filterPickerView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
        [self closeFilterPicker:nil];
    }
}

- (IBAction)openLocationFilterOptions:(id)sender {
    self.profButton.enabled = NO;
    
    if (self.filterNames) {
        self.currentFilterValues=self.filterNames.locations;
        [self.itemsPicker reloadAllComponents];
        if (self.locationSelectedItem) {
            self.tempLocationSelectedIndex=[self.filterNames.locations indexOfObject:self.locationSelectedItem];
            if (self.tempLocationSelectedIndex!=NSNotFound) {
                [self.itemsPicker selectRow:self.tempLocationSelectedIndex inComponent:0 animated:NO];
            }
        }
        
        if (self.filterPickerView.hidden) {
            [self openSelectedFilterUI];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result = [self.professionals count];
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
	
    static NSString *CellIdentifier = @"Cell";
     
    ProffesionalCell * cell = (ProffesionalCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     
    ProfessionalDO * prof = nil;
    if (self.professionals && indexPath.row < [self.professionals count]) {
        prof = [self.professionals objectAtIndex:indexPath.row];
    }
    
    [cell initWithProf:prof];

    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    ProfessionalPageViewController_iPhone * ipv= [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
    
    ProfessionalDO * prof = [self.professionals objectAtIndex:indexPath.row];
    
    ipv.professional = prof;
    
    [self.navigationController pushViewController:ipv animated:YES];
}

#pragma mark - UIPicker Delegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return  1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [self.currentFilterValues count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"Selected Value");
    
    if ([self.currentFilterValues isEqual:self.filterNames.locations]) {
        self.tempLocationSelectedIndex=row;
    }
    if ([self.currentFilterValues isEqual:self.filterNames.professions]) {
        self.tempProfSelectedIndex=row;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    ProfFilterNameItemDO * item = [self.currentFilterValues objectAtIndex:row];
    return item.name;
}


@end

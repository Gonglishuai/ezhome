//
//  ProfessionalsIndexBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import "ProfessionalsIndexBaseViewController.h"
#import "ProfessionalsResponse.h"
#import "ProfFilterNames.h"
#import "ProgressPopupViewController.h"

@interface ProfessionalsIndexBaseViewController ()

@end

@implementation ProfessionalsIndexBaseViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    self.screenName = GA_PROFESSIONALS_SCREEN;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.messageLabel.text=NSLocalizedString(@"no_profs_for_selected_filter", @"");
    self.messageLabel.hidden = YES;

    self.currentProfessionals=[NSMutableArray arrayWithCapacity:0];
    
    [self.profSignupButton setTitle:NSLocalizedString(@"add_portfolio",@"") forState:UIControlStateNormal];
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    [[[AppCore sharedInstance] getProfsManager] getProffesionalFiltersWithCompletionBlock:^ (ProfFilterNames *names)
     {
         dispatch_async(dispatch_get_main_queue(),^(void)
                        {
                            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                        });
         
         if (names != nil)
         {
             self.filterNames = names;
             
             dispatch_async(dispatch_get_main_queue(),^(void)
                            {
                                if ([self.filterNames isFiltersReady] == NO)
                                {
                                    HSMDebugLog(@"getProfFilters return %lu combo entries", (unsigned long)[self.combos count]);
                                    return;
                                }
                                
                                [self updateProfessionals];
                            });
         }
         else
         {
             //error
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Class Function
- (void)professionSelected:(NSString*) key :(NSString*) value {
    self.selectedProfessionKey = key;
    if ([self.selectedProfessionKey isEqualToString:@""]) {
        self.selectedProfessionKey = nil;
    }
    [self updateProfessionals];
}

- (void)locationSelected:(NSString*) key :(NSString*) value {
    self.selectedLocationKey = key;
    
    if ([self.selectedLocationKey isEqualToString:@""]) {
        self.selectedLocationKey = nil;
    }
    [self updateProfessionals];
}

- (void)openProfSignupPage {
    
    NSString * url = [[ConfigManager sharedInstance] signupProffessionalsLink];
    GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:url];
    [self presentViewController:iWeb animated:YES completion:nil];
}

- (void) populateProfessionals:(NSMutableArray*) professionals {
    // implemented in son's!!! do not delete
}

- (void) updateProfessionals {
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSString * _prof = (self.selectedProfessionKey ==nil)?@"":self.selectedProfessionKey ;
        NSString * _loc = (self.selectedLocationKey==nil)?@"":self.selectedLocationKey;
        NSArray * objs = [NSArray arrayWithObjects:_prof,_loc, nil];
        NSArray * keys = [NSArray arrayWithObjects:@"profession", @"location",nil];
        
//        [HSFlurry logEvent:FLURRY_PROFESIONALS_BY_FILTER withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
    
    [[[AppCore sharedInstance] getProfsManager] getProffessionalListByFilter:self.selectedProfessionKey withLocation:self.selectedLocationKey startingAt:0 withLimit:200 completionBlock:^(id serverResponse, id error) {
        
        if (error) {
            //handler error
            
            [self.currentProfessionals removeAllObjects];
            [self populateProfessionals:self.currentProfessionals];
        }else{
            ProfessionalsResponse * pr=(ProfessionalsResponse*)serverResponse;
            
            [self.currentProfessionals removeAllObjects];
            [self.currentProfessionals addObjectsFromArray:(NSArray*)pr.professionals];
            [self populateProfessionals:self.currentProfessionals];
        }
        
    } queue:dispatch_get_main_queue()];
}

- (IBAction)backPressed:(id)sender
{
    // implemented in son's!!! do not delete
}

- (IBAction)menuPressed:(id)sender{
    // implemented in son's!!! do not delete
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

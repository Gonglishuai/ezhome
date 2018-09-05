//
//  ProductsCatalogViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 2/4/13.
//
//

#import "ProductsCatalogViewController_iPad.h"
#import "CatalogProductCell.h"
#import "ControllersFactory.h"
#import "ProductsCatalogSideMenuViewController_iPad.h"
#import "CatalogMenuLogicManger.h"
#import "ProgressPopupViewController.h"
#import "WishlistHandler.h"

#define CELL_HEIGHT 357
#define CELL_WIDTH 257

@interface ProductsCatalogViewController_iPad ()

@property (nonatomic) BOOL inMiddleOfProductSelectionProcess;
@property (nonatomic, strong) ProductsCatalogSideMenuViewController_iPad *sideMenu;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation ProductsCatalogViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showWishListButton)
                                                 name:@"ShowWishlistButton" object:nil];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mydesigns_back_tile"]];
    
    self.catalogType = PRODUCTS_CATALOG;
    
    [self addSideMenuToView];
    
    self.view.backgroundColor = [UIColor clearColor];
    if (self.isFromAR) {
        [self setShadowView];
        self.searchImage.image = [UIImage imageNamed:@"search"];
        [self.searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        self.searchTextField.textColor = [UIColor whiteColor];
        self.lblMissingText.textColor = [UIColor whiteColor];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.inMiddleOfProductSelectionProcess = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance]updateMenuOptionSelectionIndex:kMenuOptionTypeCatalog];
}

-(void)dealloc{
    NSLog(@"deaaloc - ProductsCatalogViewController_iPad");
}

#pragma mark - Class Function
-(void)showWishListButton{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       NSLog(@"ShowWishlistButton Arrived");
                       [self.cataologButton  setTitle:@"Catalog" forState:UIControlStateNormal];
                    });
}


-(void)addSideMenuToView{
    self.sideMenu = [ControllersFactory instantiateViewControllerWithIdentifier:@"CatalogSideMenu" inStoryboard:kRedesignStoryboard];
    
    [[CatalogMenuLogicManger sharedInstance] setDelegate:self];
    [[CatalogMenuLogicManger sharedInstance] setSideMenu:self.sideMenu];
    [[CatalogMenuLogicManger sharedInstance] setCatalogType:PRODUCTS_CATALOG];
    
    self.sideMenu.dataSource = [CatalogMenuLogicManger sharedInstance];
    self.sideMenu.delegate = self;
    self.sideMenu.catalogType = PRODUCTS_CATALOG;
    
    [self.view addSubview:self.sideMenu.view];
    [self.view sendSubviewToBack:self.sideMenu.view];
    self.sideMenu.view.frame = CGRectMake(0, 50, 205, 720);
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger result = 0;
    
    float ret = (float)[self.products count] / 3;
    
    if (ret - ([self.products count] / 3) > 0) {
        ret++;
    }
    
    result = (int) ret;
    
    return result;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CatalogProductCell *cell = (CatalogProductCell*) [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[CatalogProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = self.isFromAR ? [UIColor clearColor] : [UIColor colorWithWhite:0.95f alpha:1];
        cell.productView1 = [ControllersFactory instantiateViewControllerWithIdentifier:@"SingleProductView" inStoryboard:kRedesignStoryboard];
        cell.productView1.delegate = self;
        cell.productView1.genericWebViewDelegate = self;
        [cell.contentView addSubview:cell.productView1.view];
        cell.productView1.view.frame = CGRectMake(10, 0, CELL_WIDTH, CELL_HEIGHT);
        
        cell.productView2 = [ControllersFactory instantiateViewControllerWithIdentifier:@"SingleProductView" inStoryboard:kRedesignStoryboard];
        cell.productView2.delegate = self;
        cell.productView2.genericWebViewDelegate = self;
        [cell.contentView addSubview:cell.productView2.view];
        cell.productView2.view.frame = CGRectMake(20 + 257, 0, CELL_WIDTH, CELL_HEIGHT);
        
        cell.productView3 = [ControllersFactory instantiateViewControllerWithIdentifier:@"SingleProductView" inStoryboard:kRedesignStoryboard];
        cell.productView3.delegate = self;
        cell.productView3.genericWebViewDelegate = self;
        [cell.contentView addSubview:cell.productView3.view];
        cell.productView3.view.frame = CGRectMake(30 + 514, 0, CELL_WIDTH, CELL_HEIGHT);
    }
    
    [cell.productView1.view setHidden:YES];
    [cell.productView2.view setHidden:YES];
    [cell.productView3.view setHidden:YES];
    
    int idx = (int)indexPath.row * 3;
    
    if(self.products == nil)
    {
        return cell;
    }
    
    if (idx<[self.products count]) {
        [cell.productView1 setProduct:[self.products objectAtIndex:idx]];
        [cell.productView1.view setHidden:NO];
    }
    
    if (idx+1<[self.products count]) {
        [cell.productView2 setProduct:[self.products objectAtIndex:idx+1]];
        [cell.productView2.view setHidden:NO];
    }
    
    if (idx+2<[self.products count]) {
        [cell.productView3 setProduct:[self.products objectAtIndex:idx+2]];
        [cell.productView3.view setHidden:NO];
    }
    
    return cell;
}

- (void) categorySelected:(NSString*)categoryId catalogType:(CatalogType)catalogType
{
    [super categorySelected:categoryId catalogType:catalogType];
}

-(void)willShowWishList:(NSString*)productId{
    
    //fix cell position this code that assamtion that we see only 3 row if ipad or 2 row if iphone
    
    NSArray * visibleCells = [self.tableView visibleCells];
    NSInteger index = 0;
    for(NSInteger i = 0; i < [visibleCells count]; i++ ){
        CatalogProductCell * cell = [visibleCells objectAtIndex:i];
        if ([cell.productView1.productId isEqualToString:productId] ||
            [cell.productView2.productId isEqualToString:productId] ||
            [cell.productView3.productId isEqualToString:productId]) {
            index = i;
        }
    }
    UITableViewCell * visibleCell = [visibleCells objectAtIndex:index];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:visibleCell];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
    [self.tableView setScrollEnabled:NO];
    [self.sideMenu.tableView setScrollEnabled:NO];
    [self.sideMenu.tableView setUserInteractionEnabled:NO];
    [self.cataologButton setUserInteractionEnabled:NO];
    [self.backButton setUserInteractionEnabled:NO];
    [self.searchTextField setUserInteractionEnabled:NO];
}

-(void)willHideWishList{
    
    [self.tableView setScrollEnabled:YES];
    [self.sideMenu.tableView setScrollEnabled:YES];
    [self.sideMenu.tableView setUserInteractionEnabled:YES];
    [self.cataologButton setUserInteractionEnabled:YES];
    [self.backButton setUserInteractionEnabled:YES];
    [self.searchTextField setUserInteractionEnabled:YES];
    
    [[CatalogMenuLogicManger sharedInstance] setIsTableInEditMode:NO];
}

-(void)refreshTableView:(NSString *)itemId catalogType:(CatalogType)catalogType{
    [self categorySelected:itemId catalogType:catalogType];
}

- (void) productSelected:(NSString*)productId andVariateId:variateId andVersion :(NSString*) timeStamp
{
    if(self.inMiddleOfProductSelectionProcess)
        return;
    
    self.inMiddleOfProductSelectionProcess = YES;
    
    DISPATCH_ASYNC_ON_MAIN_QUEUE([self dismissViewControllerAnimated:NO completion:nil]);
    
    [self flurry3:productId];
    
    if (self.delegate != nil) {
        [self.delegate productSelected:productId andVariateId:variateId andVersion:timeStamp];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMainMenuButtonNotification" object:nil];
}

#pragma mark - CatalogSideMenuDelegate

- (void)catalogSideMenuItemPickedWithId:(NSString *)itemId catalogType:(CatalogType)catalogType
{
    [self categorySelected:itemId catalogType:catalogType];
}

- (IBAction)addBrandPressed:(id)sender {
    
    GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] signupBrandsLink]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:iWeb animated:YES completion:nil];
    });
}

- (IBAction)backPressed:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self dismissViewControllerAnimated:NO completion:nil];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMainMenuButtonNotification" object:nil];
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - GenericWebViewDelegate
-(void)openInteralWebViewWithUrl:(NSString *)url{
    NSString *selectedUrl = [url copy];
    if ([ConfigManager isReDirectToMarketPlaceActive]) {
        selectedUrl = [ConfigManager getMarketPlaceUrl];
    }
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:selectedUrl];
    [self presentViewController:web animated:YES completion:nil];
}

#pragma  mark - WishList
- (IBAction)catalogClicked:(id)sender{
    UIButton * btn = (UIButton*)sender;
    if ([btn.titleLabel.text isEqualToString:@"Catalog"]) {
        //set menu header
        self.sideMenu.titleLabel.text = NSLocalizedString(@"select_category_title", @"");
        
        [[CatalogMenuLogicManger sharedInstance] setCatalogType:PRODUCTS_CATALOG];
        
        //hide buttons
        [self.searchTextField setHidden:NO];
        [self.searchImage setHidden:NO];
        
        //tell the side menu to refresh it self
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCatalogDataRequestedNotification" object:nil];
        
    }else{
        // dismiss the keyboard
        [[self view] endEditing:YES];
        
        //hide buttons
        [self.searchTextField setHidden:YES];
        [self.searchImage setHidden:YES];
        
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
        
        UserDO * user = [[UserManager sharedInstance] currentUser];
        
        [[WishlistHandler sharedInstance] getCompleteWishListsForEmail:user.userEmail
                                                   withCompletionBlock:^(id serverResponse, id error) {
                                                       
                                                       [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                                                       if (error) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                                                               UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"ERROR"
                                                                                                             message:@"Time Out"
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"OK")
                                                                                                   otherButtonTitles:nil];
                                                               [alert show];
                                                           });
                                                           return;
                                                       }
                                                       
                                                       //set menu header
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           
                                                           self.sideMenu.titleLabel.text = NSLocalizedString(@"select_wishlist_title", @"");
                                                           
                                                           [[CatalogMenuLogicManger sharedInstance] setCatalogType:WISHLIST_CATALOG];
                                                           
                                                           //tell the side menu to refresh it self
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCatalogDataRequestedNotification" object:nil];
                                                           
                                                           // bring table view to front (above catalog search meassage label)
                                                           [self.view bringSubviewToFront:self.tableView];
                                                       });
                                                       
                                                   }queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    }
}

-(void)setShadowView {
    self.view.backgroundColor = [UIColor clearColor];
    self.tblHeaderView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
}
@end

//
//  ProductsCatalogViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/20/13.
//
//

#import "ProductsCatalogViewController_iPhone.h"
#import "CatalogCell.h"
#import "CategoryCell_iPhone.h"
#import "CatalogProductCell.h"
#import "UIImage+SafeFileLoading.h"
#import "ControllersFactory.h"
#import "CatalogCategoryDO.h"
#import "ProductsCatalogSideMenuViewController_iPhone.h"
#import "CatalogMenuLogicManger.h"
#import "ProgressPopupViewController.h"
#import "WishlistHandler.h"
#import "ESOrientationManager.h"

#define NUMBER_OF_PRODUCTS_IN_CELL              3
#define MARGIN                                  20
#define NUMBER_OF_EXTRA_CELLS_FOR_ROOT_TABLE    1
#define CATALOG_DARK_BACKGROUND_ALPHA_VALUE     0.6


@interface ProductsCatalogViewController_iPhone () <CatalogSideMenuDelegate>

@property (nonatomic) BOOL isInMiddleAnimation;
@property (nonatomic) BOOL isPeekMode;
@property (nonatomic, strong) ProductsCatalogSideMenuViewController_iPhone *sideMenu;
@property (nonatomic,assign) BOOL isFirst;
@end

@implementation ProductsCatalogViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showWishListButton)
                                                 name:@"ShowWishlistButton" object:nil];
    
    self.sideMenu = [ControllersFactory instantiateViewControllerWithIdentifier:@"CatalogSideMenu" inStoryboard:kRedesignStoryboard];
    self.sideMenu.view.frame = CGRectMake(0, 0, self.rootContainer.frame.size.width, self.rootContainer.frame.size.height);
    [self.rootContainer addSubview:self.sideMenu.view];
    self.vDarkBG.alpha = 0;
    
    [[CatalogMenuLogicManger sharedInstance] setDelegate:self];
    [[CatalogMenuLogicManger sharedInstance] setSideMenu:self.sideMenu];
    [[CatalogMenuLogicManger sharedInstance] setCatalogType:PRODUCTS_CATALOG];
    
    self.sideMenu.dataSource = [CatalogMenuLogicManger sharedInstance];
    self.sideMenu.delegate = self;
    self.isRootCategoryExpanded = NO;
    self.isInMiddleAnimation = NO;
    self.isPeekMode = NO;
    
    self.sideMenu.catalogType = PRODUCTS_CATALOG;
    
    self.catalogType = PRODUCTS_CATALOG;
    
    self.isFirst = YES;

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if (self.isFromAR) {
        [self setShadowView];
        [self.toggleCatlogBtn setImage:[UIImage imageNamed:@"catalog"] forState:UIControlStateNormal];
        [self.toggleCatlogBtn setImage:[UIImage imageNamed:@"catalog_active"] forState:UIControlStateSelected];
        self.searchImage.image = [UIImage imageNamed:@"search"];
        [self.searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        self.searchTextField.textColor = [UIColor whiteColor];
        self.lblMissingText.textColor = [UIColor whiteColor];
        self.vDarkBG.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutSubviews];
}

-(void)dealloc{
    NSLog(@"dealloc - ProductsCatalogViewController_iPhone");
}

-(void)showWishListButton{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       NSLog(@"ShowWishlistButton Arrived");
                       [self.cataologButton setTitle:NSLocalizedString(@"wish_list", @"") forState:UIControlStateNormal];
                    });
}


- (IBAction)toggleCatgoriesTables:(id)sender {
    if (self.isInMiddleAnimation || self.isFirst == NO) {
        self.isFirst = YES;
        return;
    }
    
    self.isInMiddleAnimation=YES;
    
    if (self.isRootCategoryExpanded==NO)
    {
        DISPATCH_ASYNC_ON_MAIN_QUEUE(
                                     if ([self.searchTextField isFirstResponder]) {
                                         [self.searchTextField resignFirstResponder];
                                     }
                                     
                                     [UIView  animateWithDuration:0.3
                                                            delay:0.0
                                                          options:UIViewAnimationOptionCurveEaseOut
                                                       animations:^
                                      {
                                          self.vDarkBG.alpha = self.isFromAR ? 0 : CATALOG_DARK_BACKGROUND_ALPHA_VALUE;
                                          self.sideMenu.view.alpha = 1.0;
                                          self.rootContainer.alpha = 1.0;
                                          [self.view bringSubviewToFront: self.rootContainer];
                                          [self.view bringSubviewToFront: self.controlsContainer];
                                          [UIView animateWithDuration:0.05 animations:^{
                                              self.rootContainer.frame=CGRectMake(self.rootContainer.frame.origin.x + 6, self.rootContainer.frame.origin.y, ROOT_CAT_TABLE_INIT_W, self.rootContainer.frame.size.height);
                                              self.sideMenu.view.frame=CGRectMake(0 + 6, 0, ROOT_CAT_TABLE_INIT_W, self.rootContainer.frame.size.height);
                                          }];
                                          
                                      } completion:^(BOOL finished) {
                                          self.isInMiddleAnimation=NO;
                                      }]
                                     );
    }else{
        DISPATCH_ASYNC_ON_MAIN_QUEUE(
                                     [UIView animateWithDuration:0.3
                                                           delay:0.0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^{
                                                          self.vDarkBG.alpha = 0;
                                                          self.sideMenu.view.alpha = 0;
                                                          self.rootContainer.alpha = 0;
                                                      } completion:^(BOOL finished) {
                                                          self.rootContainer.frame=CGRectMake(self.rootContainer.frame.origin.x, self.rootContainer.frame.origin.y, ROOT_CAT_TABLE_INIT_W, self.rootContainer.frame.size.height);
                                                          self.sideMenu.view.frame=CGRectMake(0, 0, ROOT_CAT_TABLE_INIT_W, self.rootContainer.frame.size.height);
                                                          self.isInMiddleAnimation=NO;
                                                      }]
                                     );
    }
    
    self.isRootCategoryExpanded = !self.isRootCategoryExpanded;
    self.toggleCatlogBtn.selected = !self.isRootCategoryExpanded ? NO : YES;
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView == tableView) {
        CGFloat cardSize = (self.tableView.frame.size.width - MARGIN * 4) / NUMBER_OF_PRODUCTS_IN_CELL;
        return cardSize + MARGIN;
    }
    
    return 40.0; //returns floating point which will be used for a cell row height at specified row index
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (void) updateProductSelection:(SingleProductViewController*)catalogItem{
    
    NSArray * visibleCells = [self.tableView visibleCells];
    
    for (int i=0; i<[visibleCells count]; i++) {
        
        CatalogProductCell * cell = [visibleCells objectAtIndex:i];
        
        if (cell.productView1!=nil && cell.productView1!=catalogItem) {
            [cell.productView1 closeExtraInfo];
        }
        
        if (cell.productView2!=nil && cell.productView2!=catalogItem) {
            [cell.productView2 closeExtraInfo];
        }
        
        if (cell.productView3!=nil && cell.productView3!=catalogItem) {
            [cell.productView3 closeExtraInfo];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int result = 0;
    
    if (self.tableView == tableView) {
        
        float ret = (float)[self.products count] / NUMBER_OF_PRODUCTS_IN_CELL;
        
        if (ret - ([self.products count] / NUMBER_OF_PRODUCTS_IN_CELL) > 0) {
            ret++;
        }
        
        result = (int) ret;
    }
    
    return result;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView==tableView) {
        CatalogProductCell *cell = (CatalogProductCell*) [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        CGFloat cardSize = (self.tableView.frame.size.width - MARGIN * 4) / NUMBER_OF_PRODUCTS_IN_CELL;
        
        if (cell == nil) {
            cell = [[CatalogProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.backgroundColor = self.isFromAR ? [UIColor clearColor] : [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0];
            
            cell.productView1 = [ControllersFactory instantiateViewControllerWithIdentifier:@"SingleProductView" inStoryboard:kRedesignStoryboard];
            cell.productView1.delegate = self;
            cell.productView1.genericWebViewDelegate = self;
            [cell.contentView addSubview:cell.productView1.view];
            cell.productView1.view.frame = CGRectMake(MARGIN, MARGIN, cardSize, cardSize);
            
            cell.productView2 = [ControllersFactory instantiateViewControllerWithIdentifier:@"SingleProductView" inStoryboard:kRedesignStoryboard];
            cell.productView2.delegate = self;
            cell.productView2.genericWebViewDelegate = self;
            [cell.contentView addSubview:cell.productView2.view];
            cell.productView2.view.frame = CGRectMake(MARGIN * 2 + cardSize, MARGIN, cardSize, cardSize);
            
            cell.productView3 = [ControllersFactory instantiateViewControllerWithIdentifier:@"SingleProductView" inStoryboard:kRedesignStoryboard];
            cell.productView3.delegate = self;
            cell.productView3.genericWebViewDelegate = self;
            [cell.contentView addSubview:cell.productView3.view];
            cell.productView3.view.frame = CGRectMake(MARGIN * 3 + cardSize * 2, MARGIN, cardSize, cardSize);
        }
        
        [cell.productView1.view setHidden:YES];
        [cell.productView2.view setHidden:YES];
        [cell.productView3.view setHidden:YES];
        
        int idx = (int)indexPath.row * NUMBER_OF_PRODUCTS_IN_CELL;
        
        if (idx<[self.products count]) {
            [cell.productView1 setProduct:[self.products objectAtIndex:idx]];
            [cell.productView1.view setHidden:NO];
            cell.productView1.view.frame = CGRectMake(MARGIN, MARGIN, cardSize, cardSize);
        }
        
        if (idx+1<[self.products count]) {
            [cell.productView2 setProduct:[self.products objectAtIndex:idx+1]];
            [cell.productView2.view setHidden:NO];
            cell.productView2.view.frame = CGRectMake(MARGIN * 2 + cardSize, MARGIN, cardSize, cardSize);
        }
        
        if (idx+2<[self.products count]) {
            [cell.productView3 setProduct:[self.products objectAtIndex:idx+2]];
            [cell.productView3.view setHidden:NO];
            cell.productView3.view.frame = CGRectMake(MARGIN * 3 + cardSize * 2, MARGIN, cardSize, cardSize);
        }
        
        return cell;
    }
    
    return  nil;
}

- (void) productSelected:(NSString*)productId andVariateId:(NSString*)variateId andVersion :(NSString*) timeStamp{
    [self closeCatalog:nil];
    [self flurry3:productId];
    
    if (self.delegate != nil) {
        [self.delegate productSelected:productId andVariateId:variateId andVersion:timeStamp];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMainMenuButtonNotification" object:nil];
}

- (IBAction)closeCatalog:(id)sender {
    // reset catalog/wishlist table edit mode
    [[CatalogMenuLogicManger sharedInstance] setIsTableInEditMode:NO];
    
    if (![NSThread isMainThread]) {
        DISPATCH_ASYNC_ON_MAIN_QUEUE([self runOnMainThread];);
    } else {
        [self runOnMainThread];
    }
}

-(void)runOnMainThread
{
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMainMenuButtonNotification" object:nil];
        [[UIMenuManager sharedInstance]updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
    }];
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

#pragma mark - ProductsCatalogDelegate
- (void)catalogSideMenuItemPickedWithId:(NSString *)itemId catalogType:(CatalogType)catalogType
{
    if (self.isRootCategoryExpanded) {
        [self toggleCatgoriesTables:nil];
    }
    
    [self categorySelected:itemId catalogType:catalogType];
}

- (void)categorySelected:(NSString*)categoryId catalogType:(CatalogType)catalogType
{
    [super categorySelected:categoryId catalogType:catalogType];
}

- (void)buttonPressedAddYouBrand
{
    GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] signupBrandsLink]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self presentViewController:iWeb animated:YES completion:nil];
    });
}

- (IBAction)catalogClicked:(id)sender{
    UIButton * btn = (UIButton*)sender;
    if ([btn.titleLabel.text isEqualToString:@"Catalog"]) {
        
        //set menu header
        self.sideMenu.titleLabel.text = NSLocalizedString(@"select_category_title", @"");
        
        [[CatalogMenuLogicManger sharedInstance] setCatalogType:PRODUCTS_CATALOG];
        
        //tell the side menu to refresh it self
        [self.cataologButton setTitle:@"Catalog" forState:UIControlStateNormal];
        [self.addBrandButton setHidden:NO];
        [self.searchTextField setHidden:NO];
        [self.searchImage setHidden:NO];
        
        //tell the side menu to refresh it self
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCatalogDataRequestedNotification" object:nil];
    }
    else{
        // dismiss the keyboard
        [[self view] endEditing:YES];
        //hide buttons
        [self.addBrandButton setHidden:YES];
        [self.searchTextField setHidden:YES];
        [self.searchImage setHidden:YES];
        
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
        
        UserDO * user = [[UserManager sharedInstance] currentUser];
        
        [[WishlistHandler sharedInstance] getCompleteWishListsForEmail:user.userEmail
                                                   withCompletionBlock:^(id serverResponse, id error) {
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           // bring table view to front (above catalog search meassage label)
                                                           [self.view bringSubviewToFront:self.tableView];
                                                           
                                                           //set menu header
                                                           self.sideMenu.titleLabel.text = NSLocalizedString(@"select_wishlist_title", @"");
                                                           
                                                           [[CatalogMenuLogicManger sharedInstance] setCatalogType:WISHLIST_CATALOG];
                                                           
                                                           //tell the side menu to refresh it self
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCatalogDataRequestedNotification" object:nil];
                                                       });
                                                   }queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
    }
}

-(void)willShowWishList:(NSString*)productId{
    //fix cell position
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

-(void)refreshTableView{
    [self.tableView reloadData];
}

-(void)setShadowView {
    self.tblHeaderView.backgroundColor = [UIColor clearColor];
    self.controlsContainer.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
//    self.shadowView.frame = self.vDarkBG.frame;
//    [self.vDarkBG addSubview:self.shadowView];
//    [self.view sendSubviewToBack:self.shadowView];
}

@end

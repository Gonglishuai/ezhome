//
//  ProductsCatalogBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/20/13.
//
//

#import "ProductsCatalogBaseViewController.h"
#import "ModelsHandler.h"
#import "WishlistHandler.h"
#import "CatalogCategoryDO.h"
#import "ConfigManager.h"
#import "ProgressPopupBaseViewController.h"
#import "UIView+ReloadUI.h"
#import "CatalogMenuLogicManger.h"

#define ADD_YOUR_BRAND_TAG          1000
#define SEPARATOR_TAG               1010
#define WISHLIST_CATALOG_BTN_TAG    1020

@implementation ProductsCatalogBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_PRODUCT_CATALOG_SCREEN;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshContent)
                                                 name:@"invalidateAllContent" object:nil];
    
    _products = [NSMutableArray array];
    
    //add table header View
    [self.searchTextField setPlaceholder:NSLocalizedString(@"search_product", @"")];
    [self.lblMissingText setText:[NSString stringWithFormat:NSLocalizedString(@"error_missing_result",@""),@""]];

    
    [self.view reloadUI];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_IPAD) {
        [self updateIPadTopbarButtons];
    }else{
        if ([ConfigManager isWishListActive]) {
            [self.cataologButton setHidden:NO];
        }else{
            [self.cataologButton setHidden:YES];
        }
    }
    
    if ([ConfigManager isWishListActive] &&
        [[UserManager sharedInstance] isLoggedIn] &&
        [[WishlistHandler sharedInstance] isReveseMapReady]){
        
        [self.cataologButton setTitle:NSLocalizedString(@"wish_list", @"") forState:UIControlStateNormal];
    }

    [self.missingResualtView setHidden:YES];
    [self.view sendSubviewToBack:self.missingResualtView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // clear search history if no result returned or search text field is empty
    if ([_products count] == 0 || (self.searchTextField != nil && [self.searchTextField.text isEqualToString:@""])) {
        [CatalogMenuLogicManger sharedInstance].searchHistory = nil;
    }
    
    [super viewWillDisappear:animated];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - ProductsCatalogBaseViewController");
}

- (void) categorySelected:(NSString*)categoryId catalogType:(CatalogType)catalogType
{
    if (![ConfigManager isAnyNetworkAvailableOrOffline])
    {
        [ConfigManager showMessageIfDisconnected];
        return ;
    }
    
    if (!categoryId) {
        return; //failsafe
    }
    
    if (catalogType == WISHLIST_CATALOG) {
        
        self.loading = YES;
        
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

        [self.lblHeaderTitle setText:NSLocalizedString(@"wishlists_page_title",@"")];
        [self.cataologButton setTitle:@"Catalog" forState:UIControlStateNormal];

        [[WishlistHandler sharedInstance] getProductsForWishListId:categoryId
                                             withCompletionBlock:^(id serverResponse, id error) {
                                                 self.loading = NO;
                                                 [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                                                 
                                                 if (error == nil) {
                                                     NSArray * wishListProduct = (NSArray*)serverResponse;
                                                     [self.products removeAllObjects];
                                                     [self.products addObjectsFromArray:wishListProduct];
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
                                                         [self.tableView reloadData];
                                                     });
                                                 }else{
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self.products removeAllObjects];
                                                         
                                                         if ([_products count] == 0) {
                                                             [self.missingResualtView setHidden:NO];
                                                             [self.view bringSubviewToFront:self.missingResualtView];
                                                         }else{
                                                             [self.missingResualtView setHidden:YES];
                                                             [self.view sendSubviewToBack:self.missingResualtView];
                                                         }
                                                         
                                                         [self.tableView reloadData];
                                                     });
                                                 }
                                                 
                                             } queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ];
        
    }else if (catalogType == PRODUCTS_CATALOG){
        
        [self.lblHeaderTitle setText:NSLocalizedString(@"product_catalog_title",@"")];
        
        if ([ConfigManager isWishListActive] && [[UserManager sharedInstance] isLoggedIn])
        {
            [self.cataologButton setTitle:NSLocalizedString(@"wish_list", @"") forState:UIControlStateNormal];
        }
        else
        {
            [self.cataologButton setTitle:@"Catalog" forState:UIControlStateNormal];
        }

        _offset = 0;
        _limit = [[[ConfigManager sharedInstance] catalogPaginiationSize] integerValue];
        
        if (self.products)
            [self.products removeAllObjects];
        
        self.originalCategoryId = categoryId;
        
        // Updating the text field can only be done on main queue
        DISPATCH_ASYNC_ON_MAIN_QUEUE([self.searchTextField setText:@""]);
        
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
        
        /*
         *  The following block will update the main table UI to display
         *  immediatly the product list retrieved in the response
         */
        HSCompletionBlock postProductsRetrievalBlock = ^(id serverResponse, id error) {
            
            if (!error) {
                NSArray * productsPerPage = (NSMutableArray*)serverResponse;
                _offset = _offset + (int)[productsPerPage count];
                [self.products addObjectsFromArray:productsPerPage];
                
                if ([productsPerPage count] < [[[ConfigManager sharedInstance] catalogPaginiationSize] integerValue])
                {
                    if ([productsPerPage count] == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self.products count] == 0) {
                                [self.missingResualtView setHidden:NO];
                                [self.view bringSubviewToFront:self.missingResualtView];
                            }else{
                                [self.missingResualtView setHidden:YES];
                                [self.view sendSubviewToBack:self.missingResualtView];
                            }
                            [self.tableView reloadData];
                            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                        });
                        return; // end of list
                    }
                }
            }
            
            self.loading = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
                if ([self.products count] == 0) {
                    [self.missingResualtView setHidden:NO];
                    [self.view bringSubviewToFront:self.missingResualtView];
                }else{
                    [self.missingResualtView setHidden:YES];
                    [self.view sendSubviewToBack:self.missingResualtView];
                }
                [self.tableView reloadData];
                [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            });
        };
        
        self.loading = YES;
        [[ModelsHandler sharedInstance] getModelsForCategory: self.originalCategoryId
                                                      offset:[NSNumber numberWithInt:_offset]
                                                       limit:[NSNumber numberWithInteger:_limit]
                                         withCompletionBlock:postProductsRetrievalBlock
                                                       queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
}


- (void)searchCatalog:(NSString*)searchString
{
    if (![ConfigManager isAnyNetworkAvailable])
    {
        [ConfigManager showMessageIfDisconnected];
        
        return ;
    }
    
    if (self.searchTextField != nil && [self.searchTextField.text isEqualToString:@""]) {
        self.searchTextField.text = [CatalogMenuLogicManger sharedInstance].searchHistory;
    }
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    /*
     *  The following block will update the main table UI to display
     *  immediatly the product list retrieved in the response
     */
    HSCompletionBlock postProductsRetrievalBlock = ^(id serverResponse, id error) {
        
        if (error) {
            [_products removeAllObjects];
        }else{
            _products = [NSMutableArray arrayWithArray:(NSArray*)serverResponse];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_products count] == 0) {
                [self.missingResualtView setHidden:NO];
                [self.view bringSubviewToFront:self.missingResualtView];
            }else{
                [self.missingResualtView setHidden:YES];
                [self.view sendSubviewToBack:self.missingResualtView];
            }
            
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [CatalogMenuLogicManger sharedInstance].searchHistory = searchString;
            [CatalogMenuLogicManger sharedInstance].selectedCategoryId = nil;
            [self.tableView reloadData];
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        });
    };
    
    [[ModelsHandler sharedInstance] getModelsForSearchString:searchString
                                         withCompletionBlock:postProductsRetrievalBlock
                                                       queue:dispatch_get_main_queue()];
}

- (void) flurry1:(CatalogCategoryDO*) category  {
#ifdef USE_FLURRY
    
    NSString * catname= category.categoryName;
    if (catname==nil) {
        return;
    }
    
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_CATALOG_ROOT_CATEGORY_CLICK withParameters:[NSDictionary dictionaryWithObject:catname forKey:EVENT_ACTION_CATALOG_NAME]];
    }
#endif
}

- (void) flurry2:(CatalogCategoryDO*) category {
#ifdef USE_FLURRY
    NSString * catname= category.categoryName;
    
    if (catname==nil) {
        return;
    }
    
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_CATALOG_SUB_CATEGORY_CLICK withParameters:[NSDictionary dictionaryWithObject:catname forKey:EVENT_ACTION_CATALOG_NAME]];
    }
#endif
}

- (void) flurry3:(NSString*)productid{
#ifdef USE_FLURRY
    if (productid==nil) {
        return;
    }
    
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_CATALOG_PRODUCT_SELECT_CLICK withParameters:[NSDictionary dictionaryWithObject:productid forKey:@"product_id"]];
    }
#endif
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (self.isRootCategoryExpanded) {
        [self toggleCatgoriesTables:nil];
    }
    
    if (textField == self.searchTextField) {
        textField.enablesReturnKeyAutomatically = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    // if wishlist category was chosen (no search needed)
//    if (  [[CatalogMenuLogicManger sharedInstance] catalogType] == WISHLIST_CATALOG ||
//        orientation == UIDeviceOrientationPortrait)
//        return;
    
    if (textField == self.searchTextField) {
        NSString* searchWord = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([searchWord length] > 0) {
            [self searchCatalog:searchWord];
            if (IS_IPAD) {
                [self.lblMissingText setText:[NSString stringWithFormat:NSLocalizedString(@"error_missing_result_ipad",@""),searchWord]];
            }else{
                [self.lblMissingText setText:[NSString stringWithFormat:NSLocalizedString(@"error_missing_result",@""),searchWord]];
            }
            
        }
//        else if ([searchWord length] == 0){
//            [self categorySelected:self.originalCategoryId catalogType:PRODUCTS_CATALOG];
//            [self.lblMissingText setText:[NSString stringWithFormat:NSLocalizedString(@"error_missing_result",@""),@""]];
//        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma UserDefined Method for generating data which are show in Table :::
-(void)loadDataDelayed
{
    if (self.loading) {
        return;
    }
    
    self.loading = YES;
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    /*
     *  The following block will update the main table UI to display
     *  immediatly the product list retrieved in the response
     */
    HSCompletionBlock postProductsRetrievalBlock = ^(id serverResponse, id error) {
        
        if (!error) {
            NSArray * productsPerPage = (NSMutableArray*)serverResponse;
            _offset = _offset + (int)[productsPerPage count];
            [_products addObjectsFromArray:productsPerPage];
            
            if ([productsPerPage count]  < [[[ConfigManager sharedInstance] catalogPaginiationSize] integerValue])
            {
                if ([productsPerPage count] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSelector:@selector(hideLoadingView) withObject:nil afterDelay:0.3];
                    });
                    return; // end of list
                }
            }
            
            self.loading = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_products count] == 0) {
                    [self.missingResualtView setHidden:NO];
                    [self.view bringSubviewToFront:self.missingResualtView];
                }else{
                    [self.missingResualtView setHidden:YES];
                    [self.view sendSubviewToBack:self.missingResualtView];
                }
                [self.tableView reloadData];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(hideLoadingView) withObject:nil afterDelay:0.3];
        });
    };
    
    [[ModelsHandler sharedInstance] getModelsForCategory:self.originalCategoryId
                                                  offset:[NSNumber numberWithInt:_offset]
                                                   limit:[NSNumber numberWithUnsignedInteger:_limit]
                                     withCompletionBlock:postProductsRetrievalBlock
                                                   queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)refreshContent
{
    [self.tableView reloadData];
}

-(void)hideLoadingView{
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

- (IBAction)toggleCatgoriesTables:(id)sender{
    //implement in son's
}

#pragma mark - Action

- (IBAction)catalogClicked:(id)sender{
    //implement in son's
}

#pragma mark - Class Function
-(void)updateIPadTopbarButtons{
    
    if ([ConfigManager isAddYourBrandActive] && [ConfigManager isWishListActive]) {
        //add your brand
        UIView * addYourBrand = [self.topBarView viewWithTag:ADD_YOUR_BRAND_TAG];
        if (!addYourBrand) {
            [self.addBrandButton setFrame:CGRectMake(self.topBarView.frame.size.width - 10 - self.addBrandButton.frame.size.width,
                                                     self.topBarView.frame.origin.y,
                                                     self.addBrandButton.frame.size.width,
                                                     self.addBrandButton.frame.size.height)];
            [self.topBarView setTag:ADD_YOUR_BRAND_TAG];
            [self.topBarView addSubview:self.addBrandButton];
        }
        
        //separator
        UIView * separator = [self.topBarView viewWithTag:SEPARATOR_TAG];
        if (!separator) {
            [self.separatorView setFrame:CGRectMake(self.addBrandButton.frame.origin.x - 10 - self.separatorView.frame.size.width,
                                                     self.topBarView.frame.origin.y + 15,
                                                     self.separatorView.frame.size.width,
                                                     self.separatorView.frame.size.height)];
            [self.topBarView setTag:SEPARATOR_TAG];
            [self.topBarView addSubview:self.separatorView];
        }
        
        //wishlist catalog button
        UIView *  wishlistCatalogBtn = [self.topBarView viewWithTag:WISHLIST_CATALOG_BTN_TAG];
        if (!wishlistCatalogBtn) {
            [self.cataologButton setFrame:CGRectMake(self.separatorView.frame.origin.x - 10 - self.cataologButton.frame.size.width,
                                                    self.topBarView.frame.origin.y,
                                                    self.cataologButton.frame.size.width,
                                                    self.cataologButton.frame.size.height)];
            [self.topBarView setTag:WISHLIST_CATALOG_BTN_TAG];
            [self.topBarView addSubview:self.cataologButton];
        }
    }
    
    if ([ConfigManager isAddYourBrandActive] && ![ConfigManager isWishListActive])
    {
        UIView * addYourBrand = [self.topBarView viewWithTag:ADD_YOUR_BRAND_TAG];
        if (!addYourBrand) {
            [self.addBrandButton setFrame:CGRectMake(self.topBarView.frame.size.width - 10 - self.addBrandButton.frame.size.width,
                                                     self.topBarView.frame.origin.y,
                                                     self.addBrandButton.frame.size.width,
                                                     self.addBrandButton.frame.size.height)];
            [self.topBarView setTag:ADD_YOUR_BRAND_TAG];
            [self.topBarView addSubview:self.addBrandButton];
        }
        
        [self.addBrandButton setTitle:NSLocalizedString(@"add_brand", @"") forState:UIControlStateNormal];
    }
    
    if ([ConfigManager isWishListActive] && ![ConfigManager isAddYourBrandActive])
    {
        UIView * wishlistCatalogBtn = [self.topBarView viewWithTag:WISHLIST_CATALOG_BTN_TAG];
        if (!wishlistCatalogBtn) {
            [self.cataologButton setFrame:CGRectMake(self.topBarView.frame.size.width - 10 - self.cataologButton.frame.size.width,
                                                     self.topBarView.frame.origin.y,
                                                     self.cataologButton.frame.size.width,
                                                     self.cataologButton.frame.size.height)];
            [self.topBarView setTag:WISHLIST_CATALOG_BTN_TAG];
            [self.topBarView addSubview:self.cataologButton];
        }
        
        [self.addBrandButton setTitle:NSLocalizedString(@"add_brand", @"") forState:UIControlStateNormal];
    }
}

- (void) noCategoriesWereRetrieved {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                
        [self.cataologButton setTitle:NSLocalizedString(@"wish_list", @"") forState:UIControlStateNormal];
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@""
                                                        message:NSLocalizedString(@"err_msg_failed_retrive_wish_list", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                                              otherButtonTitles: nil];
        [alert show];
        
        
        [ConfigManager showMessageIfDisconnected];
    });
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
//    if (!IS_IPAD) {
//        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//        switch (orientation)
//        {
//            case  UIDeviceOrientationUnknown:
//                [self.searchTextField setEnabled:NO];
//                break;
//                
//            case UIDeviceOrientationPortrait:
//                [self.searchTextField setEnabled:NO];
//                break;
//                
//            case UIDeviceOrientationPortraitUpsideDown:
//                [self.searchTextField setEnabled:NO];
//                break;
//                
//            case UIDeviceOrientationLandscapeLeft:
//                [self.searchTextField setEnabled:YES];
//                break;
//                
//            case UIDeviceOrientationLandscapeRight:
//                [self.searchTextField setEnabled:YES];
//                break;
//                
//            case UIDeviceOrientationFaceUp:
//                [self.searchTextField setEnabled:NO];
//                break;
//                
//            case UIDeviceOrientationFaceDown:
//                [self.searchTextField setEnabled:NO];
//                break;
//                
//            default:
//                break;
//        }
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [self.searchTextField resignFirstResponder];
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        if (!self.loading) {
            [self performSelector:@selector(loadDataDelayed) withObject:nil afterDelay:0.5f];
        }
    }
}

@end

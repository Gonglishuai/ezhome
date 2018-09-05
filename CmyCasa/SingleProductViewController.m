 //
//  SingleProductViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 2/5/13.
//
//

#import "SingleProductViewController.h"
#import "ProductDO.h"
#import "ProductVendorDO.h"
#import "RetailerDO.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"
#import "UIView+Effects.h"
#import "CatalogMenuLogicManger.h"
#import "ModelsHandler.h"
#import "WishlistHandler.h"
#import "UIViewController+Helpers.h"
#import "DataManager.h"

@implementation SingleProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self.roundRibbon setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
    
    [self.view strokeWithWidth:1.0 cornerRadius:0.0 color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];

    self.view.layer.cornerRadius = 8;
    
    [self.vendorImageView strokeWithWidth:1.0 cornerRadius:0.0 color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
    NSLog(@"%f",[UIScreen mainScreen].bounds.size.width);
    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) showImage:(UIImageView*) imageView :(NSString*) path {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        UIImage* image = [UIImage safeImageWithContentsOfFile:path];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                imageView.image = image;
                
            }else{
                //remove local file
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                
                if ([path isEqual:_imagePath]) {
                    [self updateProductImage];
                }
                if ([path isEqual:_vendorImagePath]) {
                    [self updateVendorImage];
                }
            }
        });
        
    });
}

-(void)updateProductImage
{
        if(_imageUrl!=nil)
        {
            CGSize designSize = self.imageView.frame.size;
            NSValue *valSize = [NSValue valueWithCGSize:designSize];
            NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (_imageUrl)?_imageUrl:@"",
                                  IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                  IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS,
                                  IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.imageView};
            
            NSInteger lastUid = -1;
            lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                       {
                           NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.imageView];
                           
                           if (currentUid == uid)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  self.imageView.image = image;
                                              });
                           }
                       }];
        }
}

-(void)updateVendorImage
{
    
    CGSize designSize = self.vendorImageView.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];

    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (_vendorImageUrl)?_vendorImageUrl:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.vendorImageView};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.vendorImageView];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          self.vendorImageView.image = image;
                                      });
                   }
               }];
    
    
}

- (void) updateImages {
    [self updateProductImage];
    [self updateVendorImage];
}

- (void) setProduct:(ProductDO*) product {
    @synchronized(self) {

        [self setStatusForModellers:product];
        _numOfDownloadTries = 0;
        _productId = product.productId;
        _productSku = product.sku;
        _imagePath = [[ModelsHandler sharedInstance] getModelThumbnailFilePath:_productId];
      
        [self addWishListButtonToView];

        if (product.productImages && [product.productImages count]>0) {
            _imageUrl=[product.productImages objectAtIndex:0];
        }
    
        if (product.productVendor.vendorImagePath) {
            _vendorImagePath = product.productVendor.vendorImagePath;
        }
        
        if (product.productVendor.vendorImageUrl) {
            _vendorImageUrl = product.productVendor.vendorImageUrl;
        }
        
        if (product.vendorLogoUrl) {
            _vendorImageUrl = product.vendorLogoUrl;
        }
        
        if ([product respondsToSelector:@selector(productLastUpdateTimestamp)]) {
            _timeStamp  = product.productLastUpdateTimestamp;
        }
        _vendorName = product.productVendor.vendorName;
        
        if (product.vendorName) {
            _vendorName = product.vendorName;
        }
        
        [self.titleLabel setText:product.Name];
        [self.titleLabel setNumberOfLines:3];
      
        Boolean isNewProduct =[product.isNewProduct isEqualToString:@"New"];
        [self.roundRibbon setHidden:!isNewProduct];
        [self.lblNewRibbon setHidden:!isNewProduct];
        
        NSArray* retailers =product.retailers;
        RetailerDO* firstRetailer = (retailers.count > 0) ? [retailers objectAtIndex:0] : nil;
       
        if (product.IsGeneric || [firstRetailer.url isEqualToString:@""] || !firstRetailer.url)
        {
            [self.productDetailsBtn setHidden:YES];
            _retailerWebSiteUrl = nil;
        }
        else
        {
            [self.productDetailsBtn setHidden:YES];
            _retailerWebSiteUrl = (firstRetailer) ? firstRetailer.url : nil;
        }

        self.imageView.image = nil;
        self.vendorImageView.image = nil;

        [self updateImages];
        self.getExtraInfoButton.hidden=NO;
        self.extraInfoView.alpha=0;
        
        //QA Compatibility Labels:
        self.titleLabel.accessibilityLabel = self.titleLabel.text;
        self.imageView.accessibilityLabel = [self.titleLabel.text  stringByAppendingString:@"_img"];
        self.vendorImageView.accessibilityLabel = [self.titleLabel.text stringByAppendingString:@"vendor"];
        self.imagePressButton.accessibilityLabel =  [self.titleLabel.text stringByAppendingString:@"_btn"];
    }
}

-(void)addWishListButtonToView
{
    // Three criteria must be met to show the wish list button
    // You must have this feature on, be logged in and have an SKU
    if ([ConfigManager isWishListActive] &&
        [[UserManager sharedInstance] isLoggedIn] &&
        _productSku &&
        ![_productSku isEqualToString:@""]) {
        
        [self.addToWishListBtn setHidden:NO];
        [self.addToWishListBtn setEnabled:YES];
        
        NSDictionary * reveseDict = [[WishlistHandler sharedInstance] getProductToWishlistsDict];
        NSArray * wishlists = [reveseDict objectForKey:_productId];
        
        if (wishlists) {
             //color red
            [self.addToWishListBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            //color gray
            [self.addToWishListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    } else {
        [self.addToWishListBtn setHidden:YES];
        [self.addToWishListBtn setEnabled:NO];
    }
}

- (IBAction)getExtraInfoAction:(id)sender {
    
    [UIView animateWithDuration:0.1 animations:^{
         self.extraInfoView.alpha=1.0;
        
    } completion:^(BOOL finished) {
        self.getExtraInfoButton.hidden=YES;
        if (self.delegate) {
            [self.delegate updateProductSelection:self];
        }
    }];
}

-(void)closeExtraInfo{
    [UIView animateWithDuration:0.07 animations:^{
        self.extraInfoView.alpha=0.0;
    } completion:^(BOOL finished) {
        self.getExtraInfoButton.hidden=NO;
    }];
}

- (IBAction)webSitePressed:(id)sender {
    if (_retailerWebSiteUrl == nil || ([_retailerWebSiteUrl length] < 5 || ![_retailerWebSiteUrl hasPrefix:@"http"]))
        return;
    
    if (self.delegate) {
//         [HSFlurry logAnalyticEvent:EVENT_NAME_CLICK_BRAND_LINK withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:
//                                                                                    EVENT_PARAM_VAL_LOAD_ORIGIN_CATALOG,
//                                                                                EVENT_PARAM_CONTENT_ID:(_productId)?_productId:@"",
//                                                                                EVENT_PARAM_CONTENT_BRAND:(_vendorName)?_vendorName:@""}];
        
        if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)]) {
            [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:_retailerWebSiteUrl];
        }
    }
}

- (IBAction)imagePressed:(id)sender {
    if (self.delegate != nil) {

        if (![ConfigManager isWishListActive]) {
            if ([self.delegate respondsToSelector:@selector(willHideWishList)]) {
                [self.delegate  willHideWishList];
            }
        }
        
        [self segmentProductPlaced];
        
        [self.delegate productSelected:_productId
                          andVariateId:nil
                            andVersion:_timeStamp];
    }
}

-(IBAction)toggleAddToWishList:(id)sender{
    
    //check if product exist to one of the wishlist
    //if yes (im red) --> need to remove product form wishlist
    NSDictionary * reveseDict = [[WishlistHandler sharedInstance] getProductToWishlistsDict];
    NSArray * allReadyInWishlists = [reveseDict objectForKey:_productId];

    if (allReadyInWishlists) {
         //remove
        [self.addToWishListBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else{
         //add
        [self.addToWishListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    //if not open add product popup to wishlist
        
    if ([[WishlistHandler sharedInstance] getWishlist] && ![[CatalogMenuLogicManger sharedInstance] isTableInEditMode]) {
         [[CatalogMenuLogicManger sharedInstance] setIsTableInEditMode:YES];
        
        self.wishListTypesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WishListTypesViewController"];
        [self.wishListTypesViewController setDataArray:[[WishlistHandler sharedInstance] getWishlist]];
        [self.wishListTypesViewController setAllreadyInWishlist:allReadyInWishlists];
        self.wishListTypesViewController.popOverType = kPopOverWishList;
        self.wishListTypesViewController.delegate = self;
        
        [self.wishListTypesViewController.view setFrame:CGRectMake(0,
                                                                   0,
                                                                   self.wishListTypesViewController.view.frame.size.width,
                                                                   self.wishListTypesViewController.view.frame.size.height)];
        
        self.wishListTypesViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [self.view addSubview:self.wishListTypesViewController.view];
        [self addChildViewController:self.wishListTypesViewController];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.wishListTypesViewController.view.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             if ([self.delegate respondsToSelector:@selector(willShowWishList:)]) {
                                 [self.delegate  willShowWishList:_productId];
                             }
                         }];
        
    }else{
        NSLog(NSLocalizedString(@"wishlist_no_wishlist_msg",@"Missing Wishlist"));
    }
}

#pragma mark - Wishlist Delegate
- (void)wishlistAddProductToWishLists:(NSArray*)wishlistsSelection removeWishList:(NSArray*)wishlistsToRemove;
{
    if ([_productSku isEqualToString:@""]) {
        [self.wishListTypesViewController stopActivityIndicator];
        [self showErrorWithMessage:NSLocalizedString(@"missing_sku_product", @"Missing SKU for Product")];
        return;
    }
    
    self.wishListNotificationView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    if (wishlistsSelection && [wishlistsSelection count] > 0) {
        [[WishlistHandler sharedInstance] updateProductToWishLists:wishlistsSelection
                                                     withProductSku:_productSku
                                                     withProductId:_productId
                                                       operation:OPERATION_TYPE_ADD
                                             withCompletionBlock:^(id serverResponse, id error) {
                                                 
                                                 if (wishlistsToRemove && [wishlistsToRemove count] > 0) {
                                                     return;
                                                 }
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     
                                                     [self.wishListNotificationLabel setTextColor:[UIColor whiteColor]];
                                                     
                                                     if (!error) {
                                                         //need to update the complete list
                                                         [self.wishListNotificationLabel setText:NSLocalizedString(@"wishlist_update_successful_msg",@"Update Wishlist Succsessfully")];
                                                         
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                             [self.addToWishListBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                                             [self.wishListTypesViewController cancelBtnClicked:nil];
                                                             [self showNotificationView];
                                                              });
                                                            
                                                         
                                                     }else{
                                                         
                                                         [self.addToWishListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                                                         [self.wishListNotificationLabel setText:NSLocalizedString(@"wishlist_update_failed_msg",@"Failed to Update Wishlist")];
                                                         [self.wishListTypesViewController cancelBtnClicked:nil];
                                                         [self showNotificationView];
                                                     }
                                                 });
                                                 
                                             } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    
    if (wishlistsToRemove && [wishlistsToRemove count] > 0) {
        [[WishlistHandler sharedInstance] updateProductToWishLists:wishlistsToRemove
                                                    withProductSku:_productSku
                                                     withProductId:_productId
                                                       operation:OPERATION_TYPE_REMOVE
                                             withCompletionBlock:^(id serverResponse, id error) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     
                                                     [self.wishListNotificationLabel setTextColor:[UIColor whiteColor]];
                                                     
                                                     if (!error) {
                                                         //need to update the complete list
                                                         [self.wishListNotificationLabel setText:NSLocalizedString(@"wishlist_update_successful_msg",@"Update Wishlist Succsessfully")];
                                                         
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 NSDictionary * reveseDict = [[WishlistHandler sharedInstance] getProductToWishlistsDict];
                                                                 NSArray * wishlists = [reveseDict objectForKey:_productId];
                                                                 
                                                                 if (wishlists) {
                                                                     //color red
                                                                     [self.addToWishListBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                                                 }else{
                                                                     //color gray
                                                                     [self.addToWishListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                                                                     if ([self.delegate respondsToSelector:@selector(refreshTableView: catalogType:)]) {
//                                                                         [self.delegate refreshTableView:_productId catalogType:WISHLIST_CATALOG];
//                                                                     }
                                                                 }
                                                                 [self.wishListTypesViewController cancelBtnClicked:nil];
                                                                 [self showNotificationView];
                                                             });
                                                         
                                                         
                                                     }else{
                                                         [self.wishListNotificationLabel setText:NSLocalizedString(@"wishlist_update_failed_msg",@"Failed to Update Wishlist")];
                                                         [self.wishListTypesViewController cancelBtnClicked:nil];
                                                         [self showNotificationView];
                                                     }
                                                 });
                                                 
                                             } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    
    if ([wishlistsSelection count] == 0 && [wishlistsToRemove count] == 0) {
         [self.wishListTypesViewController cancelBtnClicked:nil];
    }
 }

- (void)addNewWishList:(NSString*)name{
    
    if ([_productSku isEqualToString:@""]) {
        [self.wishListTypesViewController stopActivityIndicator];
        [self showErrorWithMessage:NSLocalizedString(@"missing_sku_product", @"Missing SKU for Product")];
        return;
    }
    
    /* 
     *   API CALL create new whishlist
     */
    [[WishlistHandler sharedInstance] createNewWishListName:name
                                              withProduct: _productSku
                                       withWishListUserId:[[CatalogMenuLogicManger sharedInstance] getWishListUserId]
                                      withCompletionBlock:^(id serverResponse, id error) {
                                          
                                          if (!error) {
                                              [self.wishListNotificationLabel setText:NSLocalizedString(@"wishlist_create_successfuly_msg",@"Wish List Created")];
                                              
                                              NSString  * createdWishlistID = serverResponse;
                                              //call refresh data to update the wish list next time user click on heart
                                              [self refreshWishListArray:createdWishlistID];
                                          }else{
                                              [self.wishListNotificationLabel setText:NSLocalizedString(@"wishlist_create_failed_msg",@"Wish List Failed to Create")];
                                              
                                              [self.wishListTypesViewController cancelBtnClicked:nil];

                                              DISPATCH_ASYNC_ON_MAIN_QUEUE([self showNotificationView]);
                                          }
                                          
                                      } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)refreshWishListArray:(NSString*)createdWishlistID{
    
    //add the selected Product to the created wishlist
    [[WishlistHandler sharedInstance] updateProductToWishLists:[NSArray arrayWithObject:createdWishlistID]
                                                withProductSku:_productSku
                                                 withProductId:_productId
                                                   operation:OPERATION_TYPE_ADD
                                         withCompletionBlock:^(id serverResponse, id error) {
                                            
                                                 //build reverse map of wishlist
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self.addToWishListBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                                         
                                                         [self.wishListTypesViewController cancelBtnClicked:nil];
                                                         
                                                         [self showNotificationView];
                                                     });
                                            
                                             
                                         } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)showNotificationView{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.wishListNotificationLabel setTextColor:[UIColor whiteColor]];
        
        self.wishListNotificationView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.4 animations:^{
            self.wishListNotificationView.transform = CGAffineTransformIdentity;
            [self.wishListNotificationView setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:1.0];
        }];
    });
}

-(void)hideNotificationView{
    [UIView animateWithDuration:1.5 animations:^{
        [self.wishListNotificationView setAlpha:0.0];
    } completion:^(BOOL finished) {

    }];
}

-(void)wishlistCancelPressed{
    if ([self.delegate respondsToSelector:@selector(willHideWishList)]) {
        [self.delegate  willHideWishList];
    }
}

-(void)setStatusForModellers:(ProductDO*)product {
    DISPATCH_ASYNC_ON_MAIN_QUEUE(
        if ([[UserManager sharedInstance] checkIfModeller] && product.status != nil) {
            [self.status setHidden:NO];
            switch ([product.status intValue]) {
                case 0:
                    [self.status setTextColor:[UIColor whiteColor]];
                    [self.status setBackgroundColor:[UIColor blackColor]];
                    [self.status setText:@"Deleted"];
                    break;
                case 1:
                    [self.status setTextColor:[UIColor whiteColor]];
                    // blue
                    [self.status setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f
                                                                    green:122.0f/255.0f
                                                                     blue:255.0f/255.0f
                                                                    alpha:1.0f]];
                    [self.status setText:@"Active"];
                    break;
                case 2:
                    [self.status setTextColor:[UIColor whiteColor]];
                    [self.status setBackgroundColor:[UIColor colorWithRed:149.0f/255.0f
                                                                    green:149.0f/255.0f
                                                                     blue:149.0f/255.0f
                                                                    alpha:1.0f]];
                    [self.status setText:@"Inactive"];
                    break;
                case 3:
                    [self.status setTextColor:[UIColor whiteColor]];
                    [self.status setBackgroundColor:[UIColor colorWithRed:227.0f/255.0f
                                                                    green:0.0f/255.0f
                                                                     blue:0.0f/255.0f
                                                                    alpha:1.0f]];
                    [self.status setText:@"Private"];
                    break;
                default:
                    break;
            }
        }
    );
}

#pragma mark - SEGMENT
-(void)segmentProductPlaced{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if ([[DataManger sharedInstance] category]) {
        [dict setObject:[[DataManger sharedInstance] category] forKey:@"category"];
    }
         
    if([[DataManger sharedInstance] subCategory]){
        [dict setObject:[[DataManger sharedInstance] subCategory] forKey:@"subcategory"];
    }
    
    if ([[DataManger sharedInstance] brand]) {
        [dict setObject:[[DataManger sharedInstance] brand] forKey:@"brand"];
    }
         
    [dict setObject:_productId forKey:@"product id"];
    [dict setObject:self.titleLabel.text forKey:@"product title"];
    
    if (_vendorName) {
        [dict setObject:_vendorName forKey:@"brand"];
    }
    
    if ([[DataManger sharedInstance] designSource]) {
        [dict setObject:[[DataManger sharedInstance] designSource] forKey:@"design type"];
    }

//    [HSFlurry segmentTrack:@"product placed" withParameters:dict];
}

@end

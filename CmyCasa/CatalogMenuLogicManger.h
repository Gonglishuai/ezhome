//
//  CatalogMenuLogicManger.h
//  Homestyler
//
//  Created by Tomer Har Yoffi
//
//

#import <Foundation/Foundation.h>
#import "CatalogSideMenuProtocols.h"
#import "CatalogSideMenuBaseViewController.h"
#import "ProductsCatalogBaseViewController.h"

@interface CatalogMenuLogicManger : NSObject <CatalogSideMenuDataSourceProtocol>

@property (nonatomic, assign) BOOL showTopLevel;
@property (nonatomic, assign) BOOL isTableInEditMode;
@property (nonatomic, weak) id <ProductsCatalogDelegate> delegate;
@property (nonatomic, assign) CatalogType  catalogType;
@property (nonatomic, strong) NSString* selectedCategoryId;
@property (nonatomic, copy) NSString *searchHistory;

@property (nonatomic, strong) CatalogSideMenuBaseViewController *sideMenu;
@property (nonatomic, strong) ProductsCatalogBaseViewController *catalogView;

+ (CatalogMenuLogicManger*)sharedInstance;
-(void)getWishListIdForEmail:(HSCompletionBlock)completion;

-(NSString*)getWishListUserId;
-(void)backToDefault;
@end

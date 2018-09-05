//
//  ProductTagBaseView.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 4/1/15.
//
//

#import "ProductTagBaseView.h"
#import "ModelsHandler.h"
#import "UILabel+Size.h"
#import "ProductTagImageView.h"
#import "ShoppingListItem.h"
#import "ProductVendorDO.h"
#import "ImageFetcher.h"
#import "ProductInfoBrightnessTableViewCell.h"
#import "ProductInfoRegularTableViewCell.h"
#import "ProductInfoTitleTableViewCell.h"
#import "VariationDO.h"
#import "ProductSwappableAssemblyTableViewCell.h"
#import "ProductInfoGroupTableViewCell.h"
#import "CatalogGroupsDO.h"
#import "ProductInfoGroupSectionAccessory.h"
#import "CategoriesResponse.h"
#import "ProductTagGroupView.h"
#import "ProductTagGroupTitleCell.h"
#import "ProtocolsDef.h"
#import "DataManager.h"

#define CELL_SEPARATOR_VISIBLE UIEdgeInsetsMake(0, -15, 0, 0)
#define CELL_SEPARATOR_NOT_VISIBLE UIEdgeInsetsMake(0, 10000, 0, 0)

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ProductTagBaseView ()
{
    BOOL _closeAnimationRunning;
    NSMutableDictionary * _expandedRows;
    int numOfFamilies;
    NSMutableDictionary * _expendaleCellProducts;
    NSMutableArray * _tableElementsArray;
    UIButton * _btnPin;
    UIButton * _leftBtn;
    UIButton * _rightBtn;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ProductTagBaseView
{
    NSArray *currentEntityGroupsArray;
}

-(void)viewDidLoad{
    [super viewDidLoad];

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    _editMode = NO;
    
    if ([ConfigManager isProductInfoLeftRightActive]) {
        [self.tableView setTableHeaderView:[self getTableHeader]];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Class Function
-(UIView*)getTableHeader{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    
    _leftBtn  = [[UIButton alloc] initWithFrame:CGRectMake(25, 5, 25, 25)];
    [_leftBtn setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(leftPressed:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:_leftBtn];
    
    _rightBtn  = [[UIButton alloc] initWithFrame:CGRectMake(65, 5, 25, 25)];
    [_rightBtn setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(rightPressed:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:_rightBtn];

    return header;
}

-(void)leftPressed:(id)sender{
    [UIView animateWithDuration:1.0f delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSInteger originY = IS_IPAD ? 52 : 0;
        [self.view setFrame:CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height)];

    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.isDockingToLeft = YES;
    }];
}

-(void)rightPressed:(id)sender{
    //right
    
    [UIView animateWithDuration:1.0f delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSInteger originY = IS_IPAD ? 52 : 0;

        [self.view setFrame:CGRectMake([UIScreen currentScreenBoundsDependOnOrientation].size.width - self.view.frame.size.width , originY, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.isDockingToLeft = NO;
    }];
}

-(void)updateCurrentProductInfo:(Entity*)entity
{
    [self.view setAlpha:0.5];
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setHidden:YES];
    
    [self.loadingView setHidden:NO];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.loadingView];
    
    _expandedRows = [NSMutableDictionary dictionary];
    
    if (!_tableElementsArray) {
        _tableElementsArray = [NSMutableArray array];
    }else{
        [_tableElementsArray removeAllObjects];
    }
    
    if (entity == nil) {
        return;
    }
    
    [self clearCurrentProductEntity];
    
    self.currentProductEntity = entity;
    
    HSCompletionBlock postActionBlock = ^(id response, NSError *error)
    {
        self.currentProduct = (ProductInfoDO*)response;
        
        if (error || !response || !self.currentProduct)
            return;
        
        //load asseblies
        if ([self.currentProductEntity.nestedEntities count] > 0) {
            [self loadProductsForAasembly];
        }else{
            NSArray * items = [NSArray arrayWithObject:self.currentProduct.product];
            [self fillTableCells:items];
        }
    }; // end of block
    
    // get families data for the array
    [[ModelsHandler sharedInstance] getProductInfoForEntity:entity
                                            completionBlock:postActionBlock
                                                      queue:dispatch_get_main_queue()];
}

- (void)productSite{
    if (self.currentProduct) {
        NSString *productId=(self.currentProductEntity!=nil && self.currentProductEntity.modelId!=nil)?self.currentProductEntity.modelId:@"";
//        [HSFlurry logAnalyticEvent:EVENT_NAME_CATALOG_REQUEST_TO_BROWSER
//                    withParameters:@{EVENT_PARAM_PRODUCT_ID: productId}];
        
        if (![[UserManager sharedInstance] isLoggedIn])
        {
            NSString *currentUserID= ([UserManager sharedInstance].currentUser!=nil && [UserManager sharedInstance].currentUser.userID!=nil)?[UserManager sharedInstance].currentUser.userID:@"";
//            [HSFlurry logAnalyticEvent:EVENT_NAME_CATALOG_REQUEST_TO_BROWSER withParameters:@{EVENT_PARAM_USER_ID:currentUserID}];
        }
        
        NSString * url =[self.currentProduct.product getVendorSiteAtIndex:0];
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
            if (url) {
//                [HSFlurry logEvent:FLURRY_PROD_TAG_DETAILS_CLICK withParameters:[NSDictionary dictionaryWithObject:[self.currentProduct.product getVendorSiteAtIndex:0] forKey:@"visit_url"]];
            }
        }
#endif
        NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:url];
        
        if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)]) {
            [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:urlWithReferer];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)duplicateProduct:(id)sender {
    if ([self.productDelegate respondsToSelector:@selector(duplicateProduct:)]) {
        [self.productDelegate duplicateProduct:self.currentProductEntity];
        
#ifdef USE_FLURRY
        NSString *productId = (self.currentProductEntity!=nil && self.currentProductEntity.modelId!=nil)?self.currentProductEntity.modelId:@"";
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_DUPLICATE_PRODUCT withParameters:@{EVENT_PARAM_PRODUCT_ID:productId}];
//        [HSFlurry logAnalyticEvent:EVENT_PRODUCT_DETAIL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_NAME_DUPLICATE_PRODUCT}];

#endif
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)restoreProductScale:(id)sender {
    if ([self.productDelegate respondsToSelector:@selector(resetScaleForProduct:)])
    {
        [self.productDelegate resetScaleForProduct:self.currentProductEntity];
        NSString *productId=(self.currentProductEntity!=nil && self.currentProductEntity.modelId!=nil)?self.currentProductEntity.modelId:@"";
//        [HSFlurry logAnalyticEvent:EVENT_NAME_RESTORE_SCALE withParameters:@{EVENT_PARAM_PRODUCT_ID:productId}];
//        [HSFlurry logAnalyticEvent:EVENT_PRODUCT_DETAIL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_NAME_RESTORE_SCALE}];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)removeProduct:(id)sender {
    if (self.productDelegate && self.currentProductEntity) {
        [self.productDelegate removeProduct:self.currentProductEntity];
//        [HSFlurry logAnalyticEvent:EVENT_PRODUCT_DETAIL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_NAME_DELETE_PRODUCT}];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)goToWeb:(id)sender {
    [self openBrandHomePage:sender];
}

- (void)openBrandHomePage:(id)sender {
    
    NSString* url = [self.currentProduct.product getVendorSiteAtIndex:0];
    
    if (self.currentProduct && self.currentProduct.product.vendorLink != nil) {

//        [HSFlurry logAnalyticEvent:EVENT_NAME_CLICK_BRAND_LINK withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:
//                                                                                    EVENT_PARAM_VAL_LOAD_ORIGIN_HIGHLIGHT_PRODUCT,
//                                                                                EVENT_PARAM_CONTENT_ID:(self.currentProduct.product.productId)?self.currentProduct.product.productId:@"",
//                                                                                EVENT_PARAM_CONTENT_BRAND:(self.currentProduct.product.productVendor.vendorName)?self.currentProduct.product.productVendor.vendorName:@""}];
//
//        [HSFlurry logAnalyticEvent:EVENT_PRODUCT_DETAIL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_NAME_DETAIL_PRODUCT}];
//        NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:url];
        
        if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)] && self.currentProduct.product.vendorLink != nil) {
            [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:self.currentProduct.product.vendorLink];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)apiCallFamiliesByIdsFromFamelies:(NSArray *)families
{
    if (families.count == 0)
    {
        return;
    }
    
    NSMutableString *familyIds = [[NSMutableString alloc] init];
    for (int i = 0 ; i < families.count; i++)
    {
        
       CatalogGroupDO * catalogGroupDO = [families objectAtIndex:i];
        NSString * gropId = [catalogGroupDO groupId];
        if (gropId) {
            [familyIds appendString:gropId];
            if (i != families.count -1) {
                [familyIds appendString:@","];
            }
        }
    }
    
    HSCompletionBlock postProductsRetrievalBlock = ^(id serverResponse, id error) {
        
        if (!error) {
            NSArray * catalogGroupsDOArray = (NSArray*)serverResponse;
            if ([catalogGroupsDOArray count] > 0) {
                CatalogGroupsDO * cgsdo = [catalogGroupsDOArray objectAtIndex:0];
                
                if (!_expendaleCellProducts) {
                    _expendaleCellProducts  = [NSMutableDictionary dictionary];
                }
                CatalogGroupDO * cgdo = [families objectAtIndex:0];
                [_expendaleCellProducts setObject: cgsdo.products forKey:[cgdo groupId]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        };
    };
    
    [[ModelsHandler sharedInstance] getFamiliesByIds:familyIds
                                                  offset:[NSNumber numberWithInt:0]
                                                   limit:[NSNumber numberWithInteger:20]
                                     withCompletionBlock:postProductsRetrievalBlock
                                                   queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)loadProductsForAasembly{
    
    HSCompletionBlock postActionBlock = ^(id response, NSError *error)
    {
        if (![response isKindOfClass:[NSArray class]]) {
            return;
        }
        
        //clear all tables cells
        [_tableElementsArray removeAllObjects];
        
        NSArray * assemblies = (NSArray*)response;
        [self fillTableCells:assemblies];
    };
    
    [[ModelsHandler sharedInstance] getProducts:self.currentProductEntity
                                completionBlock:postActionBlock
                                          queue:dispatch_get_main_queue()];
}

-(void)fillTableCells:(NSArray*)items{
    //analytics
    [self segmentProductDetails];
    
    //Add title cell (image cell)
    NSMutableDictionary * dictTitle = [NSMutableDictionary dictionary];
    [dictTitle setObject:[NSNumber numberWithInt:ProductCellTypeTitle] forKey:@"type"];
    [_tableElementsArray addObject:dictTitle];
    
    //Add family title if exist
    if ([[self.currentProduct familySlibings] count] > 0) {
        NSLog(@"we have familySlibings");
        NSMutableDictionary * dictGroupHeader = [NSMutableDictionary dictionary];
        [dictGroupHeader setObject:[NSNumber numberWithInt:ProductcellTypeTagGroupHeaderCell] forKey:@"type"];
        [_tableElementsArray addObject:dictGroupHeader];
    }
    
    SwappableCellVariationData *scv = nil;
    ProductDO * pdo = nil;
    
    //go over all product in entity and for each product attch his relevant assembly
    for(Entity *nestedEntity in [self.currentProductEntity uniqueModels]){
        
        for (NSInteger i = 0; i < [items count]; i++) {
            pdo = [items objectAtIndex:i];
            if ([pdo.productId isEqualToString:nestedEntity.modelId]) {
                scv = [[SwappableCellVariationData alloc] initWithEntity:nestedEntity  shoppingListItem:pdo];
                break;
            }
        }
        
        if (pdo && scv) {
            if ([pdo.variationsArray count] > 0) {
                NSMutableDictionary * dictSwappableAssembly = [NSMutableDictionary dictionary];
                [dictSwappableAssembly setObject:[NSNumber numberWithInt:ProductCellTypeAssemblyWithVariation] forKey:@"type"];
                [dictSwappableAssembly setObject:pdo forKey:@"item"];
                [dictSwappableAssembly setObject:scv forKey:@"swappable_cell_variation_data"];
                [_tableElementsArray addObject:dictSwappableAssembly];
            }else{
                NSMutableDictionary * dictAssemblyInfo = [NSMutableDictionary dictionary];
                [dictAssemblyInfo setObject:[NSNumber numberWithInt:ProductCellTypeAssemblyInfo] forKey:@"type"];
                [dictAssemblyInfo setObject:pdo forKey:@"item"];
                [dictAssemblyInfo setObject:scv forKey:@"swappable_cell_variation_data"];
                [_tableElementsArray addObject:dictAssemblyInfo];
            }
            
        }
    }
    
    //Add product details cell
    //NSMutableDictionary * dictProductDetails = [NSMutableDictionary dictionary];
    //[dictProductDetails setObject:[NSNumber numberWithInt:ProductCellTypeProductDetails] forKey:@"type"];
    //[_tableElementsArray addObject:dictProductDetails];
    
    //Add duplicate cell
    NSMutableDictionary * dictDuplicateProduct = [NSMutableDictionary dictionary];
    [dictDuplicateProduct setObject:[NSNumber numberWithInt:ProductCellTypeDuplicateProduct] forKey:@"type"];
    [_tableElementsArray addObject:dictDuplicateProduct];
    
    //Add restore scale cell
    NSMutableDictionary * dictRestoreScale = [NSMutableDictionary dictionary];
    [dictRestoreScale setObject:[NSNumber numberWithInt:ProductCellTypeRestoreScale] forKey:@"type"];
    [_tableElementsArray addObject:dictRestoreScale];
    
    //Add brightness cell
    NSMutableDictionary * dicteBrightness = [NSMutableDictionary dictionary];
    [dicteBrightness setObject:[NSNumber numberWithInt:ProductCellTypeBrightness] forKey:@"type"];
    [_tableElementsArray addObject:dicteBrightness];
    
    //Add remove product cell
    NSMutableDictionary * dictRemoveItem = [NSMutableDictionary dictionary];
    [dictRemoveItem setObject:[NSNumber numberWithInt:ProductCellTypeRemoveItem] forKey:@"type"];
    [_tableElementsArray addObject:dictRemoveItem];
    
    DISPATCH_ASYNC_ON_MAIN_QUEUE([self.tableView reloadData];
                                 [self.view setAlpha:1.0];
                                 [self.loadingView setHidden:NO];
                                 [self.activityIndicator stopAnimating];
                                 [self.view sendSubviewToBack:self.loadingView];
                                 [self.tableView setHidden:NO];
                                 [self.tableView setUserInteractionEnabled:YES];);
}
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)closeProductInfoView:(id)sender {
    
    self.isProductReplacedFromFamily = NO;
    
    if (_closeAnimationRunning ) {
        return;
    }
    
    _closeAnimationRunning = YES;
    CGRect rerct = self.view.frame;
    if (self.isDockingToLeft) {
        rerct.origin = CGPointMake(rerct.origin.x - self.view.frame.size.width, self.view.frame.origin.y);
    }else{
        rerct.origin = CGPointMake(rerct.origin.x + self.view.frame.size.width, self.view.frame.origin.y);
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = rerct;
    } completion:^(BOOL finished) {
        [self clearCurrentProductEntity];
        _closeAnimationRunning=NO;
        [self.view removeFromSuperview];
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)clearCurrentProductEntity
{
    NSLog(@"################clearCurrentProductEntity#################");
    self.currentProductEntity = nil;
    self.currentProduct = nil;
    self.holdViewWhileSwitchingObjects = NO;
    [self.productImagesArray removeAllObjects];
    self.currentProduct = nil;
    self.currentProductEntity = nil;
    [_tableElementsArray removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)removeProductAfterConfirm
{
    [self clearCurrentProductEntity];
    _holdViewWhileSwitchingObjects = YES;
    NSString *productId = (self.currentProductEntity!=nil && self.currentProductEntity.modelId!=nil)?self.currentProductEntity.modelId:@"";
//    [HSFlurry logAnalyticEvent:EVENT_NAME_DELETE_PRODUCT withParameters:@{EVENT_PARAM_PRODUCT_ID: productId}];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)productBrightnessSliderChanged:(UISlider *)sender
{
    if (!self.currentProductEntity)
        return;
    
    //self.currentProductEntity.brightness = [sender value];
    if ([self.productDelegate respondsToSelector:@selector(adjustBrightnessForProduct:brightness:)])
    {
        [self.productDelegate adjustBrightnessForProduct:self.currentProductEntity brightness:[sender value]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)resetBrightness:(id)sender
{
    if ([self.productDelegate respondsToSelector:@selector(adjustBrightnessForProduct:brightness:)])
    {
        [self.productDelegate adjustBrightnessForProduct:self.currentProductEntity brightness:ENTITY_DEFAULT_BRIGHTNESS];
    }
    // setting the entity brightness (slider resets at cell class IBAction)
    // self.currentProductEntity.brightness = ENTITY_DEFAULT_BRIGHTNESS ;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 40;
    ProductCellType type = -1;
    if (indexPath.row < [_tableElementsArray count]) {
        NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
        type = [[dict objectForKey:@"type"] intValue];
    }

    switch (type)
    {
        case ProductCellTypeTitle:
        {
            height = IS_IPAD ? 380 : 270;
        }
            break;
            
        case ProductCellTypeGroups:
        {
            height = IS_IPAD ? 140 : 85;
        }
            break;

        case ProductCellTypeAssemblyWithVariation:
        {
            height = IS_IPAD ? 263 : 179;
        }
            break;
            
        case ProductCellTypeSwappableVariation:
        {
            height = IS_IPAD ? 146 : 97;
        }
            break;

        case ProductCellTypeProductDetails:
        {
            height = IS_IPAD ? 58 : 43;
        }
            break;
            
        case ProductCellTypeDuplicateProduct:
        {
            height = IS_IPAD ? 58 : 43;
        }
            break;
            
        case ProductCellTypeRestoreScale:
        {
            height = IS_IPAD ? 58 : 43;
        }
            break;
            
        case ProductCellTypeBrightness:
        {
            height = IS_IPAD ? 90 : 80;
        }
            break;
            
        case ProductCellTypeRemoveItem:
        {
            height = IS_IPAD ? 58 : 43;
        }
            break;
            
        case ProductcellTypeTagGroupHeaderCell:
        {
            height = 50;
        }
            break;
            
        case ProductcellTypeTagGroupTitleCell:
        {
            height = 50;
        }
            break;
            
        case ProductCellTypeAssemblyInfo:
        {
            height = IS_IPAD ? 116 : 83;
        }
            break;
            
        default:
            break;
            
    }// end of switch
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (![ConfigManager isFamiliesActive] )
    {
        return;
    }
    
    if (indexPath.row < [_tableElementsArray count]) {
        NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
        if ([[dict objectForKey:@"type"] integerValue] == ProductcellTypeTagGroupTitleCell) {
            [self clickGroupTitleWithTable:tableView selectRowAtIndexPath:indexPath];
        }else if ([[dict objectForKey:@"type"] integerValue] == ProductcellTypeTagGroupHeaderCell){
            [self clickGroupHeaderWithTable:tableView selectRowAtIndexPath:indexPath];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableElementsArray count];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
   
    if (indexPath.row >= [_tableElementsArray count]) {
        static NSString * reuseIdentifier =  @"productTagTitleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        NSLog(@"ProductTagBaseView - Index out of bound");
        return cell;
    }
    
    NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
    ProductCellType type = [[dict objectForKey:@"type"] intValue];
    
    //NSLog(@"type %d", type);
    
    switch (type) {
        case ProductCellTypeTitle:
            cell = [self getCellForRow:ProductCellTypeTitle indexPath:indexPath];
            break;
        case ProductCellTypeProductDetails:
            cell = [self getCellForRow:ProductCellTypeProductDetails indexPath:indexPath];
            break;
        case ProductCellTypeDuplicateProduct:
            cell = [self getCellForRow:ProductCellTypeDuplicateProduct indexPath:indexPath];
            break;
        case ProductCellTypeRestoreScale:
            cell = [self getCellForRow:ProductCellTypeRestoreScale indexPath:indexPath];
            break;
        case ProductCellTypeBrightness:
            cell = [self getCellForRow:ProductCellTypeBrightness indexPath:indexPath];
            break;
        case ProductCellTypeRemoveItem:
            cell = [self getCellForRow:ProductCellTypeRemoveItem indexPath:indexPath];
            break;
        case ProductCellTypeAssemblyInfo:
            cell = [self getCellForRow:ProductCellTypeAssemblyInfo indexPath:indexPath];
            break;
        case ProductCellTypeAssemblyWithVariation:
            cell = [self getCellForRow:ProductCellTypeAssemblyWithVariation indexPath:indexPath];
            break;
        case ProductCellTypeSwappableVariation:
            cell = [self getCellForRow:ProductCellTypeSwappableVariation indexPath:indexPath];
            break;
        case ProductcellTypeTagGroupHeaderCell:
            cell = [self getCellForRow:ProductcellTypeTagGroupHeaderCell indexPath:indexPath];
            break;
        case ProductcellTypeTagGroupTitleCell:
            cell = [self getCellForRow:ProductcellTypeTagGroupTitleCell indexPath:indexPath];
            break;
        case ProductCellTypeGroups:
            cell = [self getCellForRow:ProductCellTypeGroups indexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    return cell;
}


-(NSInteger)getStringLocationForKey:(NSString*)stringForRowKey{
    for (int i = 0 ; i < [_tableElementsArray count]; i++) {
        NSDictionary * elementDict = [_tableElementsArray objectAtIndex:i];
        NSInteger type = [[elementDict objectForKey:@"type"] intValue];
        if (type == ProductcellTypeTagGroupTitleCell) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell isKindOfClass:[ProductTagGroupTitleCell class]]) {
                NSString * stringForRow = ((ProductTagGroupTitleCell*)cell).familyTitle.text;
                
                if ([stringForRow isEqualToString:stringForRowKey]) {
                    return i;
                }
            }
        }
    }
    return -1;
}

#pragma mark - Class Function
-(void)clickGroupHeaderWithTable:(UITableView*)tableView selectRowAtIndexPath:(NSIndexPath *)indexPath{
    //click on group header cell

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * stringForRow = ((ProductTagGroupTitleCell*)cell).familyTitle.text;
    BOOL isExist = [[_expandedRows objectForKey:stringForRow] boolValue];

    if (isExist) {
        //remove group header index
        [_expandedRows removeObjectForKey:NSLocalizedString(@"available_variations", @"")];
        
        //if some cell are open remove them first
        
        NSArray * expendRowsKeys = [_expandedRows allKeys];
        for (NSString * stringForRowKey in expendRowsKeys) {
            NSInteger stringLocation = [self getStringLocationForKey:stringForRowKey];
            if (stringLocation != -1) {
                 NSMutableArray *indexPaths = [NSMutableArray array];
                [indexPaths addObject:[NSIndexPath indexPathForRow:stringLocation+1 inSection:0]];
                if (stringLocation+1 <= [_tableElementsArray count]) {
                    [_tableElementsArray removeObjectAtIndex:stringLocation+1];
                }
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        
        //cleanup indexes
        [_expandedRows removeAllObjects];

        //remove all siblings
        for (int i = 0 ;i <  [[self.currentProduct familySlibings] count]; i++) {
            NSMutableArray *indexPaths = [NSMutableArray array];
            [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
            if (indexPath.row+1 <= [_tableElementsArray count]) {
                [_tableElementsArray removeObjectAtIndex:indexPath.row+1];
            }
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        //animate arrow
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [UIView animateWithDuration:0.3 animations:^{
            cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI * 2);
        } completion:^(BOOL finished) {
        }];
    }else{
        [_expandedRows setValue:[NSNumber numberWithBool:YES] forKey:NSLocalizedString(@"available_variations", @"")];
        
        for (int i = 0; i <  [[self.currentProduct familySlibings] count]; i++) {
            
            CatalogGroupDO * cgdo = [[self.currentProduct familySlibings] objectAtIndex:i];
            NSMutableDictionary * dictFamilyTitle = [NSMutableDictionary dictionary];
            [dictFamilyTitle setObject:[NSNumber numberWithInt:ProductcellTypeTagGroupTitleCell] forKey:@"type"];
            [dictFamilyTitle setObject:cgdo forKey:@"item"];
            [_tableElementsArray insertObject:dictFamilyTitle atIndex:indexPath.row +1];
            
            //add row to table
            NSIndexPath *nextLineIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextLineIndexPath]
                             withRowAnimation:UITableViewRowAnimationBottom];
        }
        
        //update arrow to be open
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [UIView animateWithDuration:0.3 animations:^{
            cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        } completion:^(BOOL finished) {
            [self.tableView reloadData];
        }];
    }
}

-(void)clickGroupTitleWithTable:(UITableView*)tableView selectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * stringForRow = ((ProductTagGroupTitleCell*)cell).familyTitle.text;
   
    if ([_expandedRows count] > 1) {
        BOOL isExist = [[_expandedRows objectForKey:stringForRow] boolValue];
        
        if (isExist) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI * 2);
            } completion:^(BOOL finished) {
            }];
            
            //remove element from table
            [_expandedRows removeObjectForKey:stringForRow];
            
            NSMutableArray *indexPaths = [NSMutableArray new];
            NSInteger stringLocation = [self getStringLocationForKey:stringForRow];
            [indexPaths addObject:[NSIndexPath indexPathForRow:stringLocation+1 inSection:0]];
            
            if (stringLocation+1 < [_tableElementsArray count]) {
                [_tableElementsArray removeObjectAtIndex:stringLocation+1];
            }
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }else{
            //remove all prev keys
            NSArray * allKyes = [_expandedRows allKeys];
            for (int i = 0 ; i < [allKyes count]; i++) {
                NSString * key = [allKyes objectAtIndex:i];
                if (![key isEqualToString:NSLocalizedString(@"available_variations", @"")]) {
                    //remove element from table
                    [_expandedRows removeObjectForKey:key];
                    
                    NSInteger stringLocation = [self getStringLocationForKey:key];
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:stringLocation+1 inSection:0]];
                    
                    if (stringLocation+1 < [_tableElementsArray count]) {
                        [_tableElementsArray removeObjectAtIndex:stringLocation+1];
                    }
                    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            NSInteger newStringLocationAfterDel = [self getStringLocationForKey:stringForRow];
            [self clickGroupTitleWithTable:tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:newStringLocationAfterDel inSection:0]];
        }
    }else{
        //save the expended path
        [_expandedRows setObject:[NSNumber numberWithBool:YES] forKey:stringForRow];
        
        id object = [dict objectForKey:@"item"];
        
        if ([object isKindOfClass:[CatalogGroupDO class]]) {
            
            CatalogGroupDO * catalogGroupDO = (CatalogGroupDO*)object;
            
            NSMutableDictionary * dictGroupProducts = [NSMutableDictionary dictionary];
            [dictGroupProducts setObject:[NSNumber numberWithInt:ProductCellTypeGroups] forKey:@"type"];
            [dictGroupProducts setObject:[catalogGroupDO groupId] forKey:@"item"];
            
            [_tableElementsArray insertObject:dictGroupProducts atIndex:indexPath.row + 1];
            
            NSIndexPath *nextLineIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextLineIndexPath]
                             withRowAnimation:UITableViewRowAnimationBottom];
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI /2);
            } completion:^(BOOL finished) {
                
                NSLog(@"Let Call Api to get family products");
                
                if (catalogGroupDO)
                {
                    NSArray * familyArray = [NSArray arrayWithObject:catalogGroupDO];
                    [self apiCallFamiliesByIdsFromFamelies:familyArray];
                }
            }];
        }
    }
}

// returns a cell according to the table row (type) and variation row of the entity displayed in the info table view
-(UITableViewCell *)getCellForRow:(int)type indexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (type)
    {
        case ProductCellTypeTitle:
        {
            //NSLog(@"ProductCellTypeTitle type = %d", type);
            cell = (ProductInfoTitleTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"productTagTitleCell"];
            if (cell == nil)
            {
                cell = [[ProductInfoTitleTableViewCell alloc] init];
                [(ProductInfoTitleTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            self.currentProduct ? [self setTitleCell:cell] : [self clearTitleCell:cell];
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
        }
            break;
            
        case ProductCellTypeGroups:
        {
            //NSLog(@"ProductCellTypeGroups type = %d", type);
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagGroupCell"];
            if (cell == nil){
                cell = [[ProductInfoGroupTableViewCell alloc] init];
                [(ProductInfoGroupTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }else{
                [(ProductInfoGroupTableViewCell *)cell clearCell];
            }
            
            // set separator inset according to ios version + check if last cell to hide it
            [self handelLayoutMargins:cell];
            
            // set the delegate to self for clicked variation action
            [(ProductInfoGroupTableViewCell*)cell setProductSwappableVariationCellDelegate:self];
            [(ProductInfoGroupTableViewCell *)cell setGenericWebViewDelegate:self.genericWebViewDelegate];

            if (_expendaleCellProducts) {
                NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
                
                NSArray * fameliesProducts = [_expendaleCellProducts objectForKey:[dict objectForKey:@"item"]];
                
                [(ProductInfoGroupTableViewCell*)cell generateGroupViews:fameliesProducts
                                                        currentProductId:[self.currentProduct.product productId]];
            }
        }
            break;

            
        case ProductCellTypeSwappableVariation:
        {
            //NSLog(@"ProductCellTypeSwappableVariation type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagButtonCell4"];
            if (cell == nil)
            {
                cell = [[ProductSwappableVariationCell alloc] init];
                [(ProductSwappableVariationCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
                [(ProductSwappableVariationCell*)cell setProductSwappableVariationCellDelegate:self];
            }
            
            // set separator inset according to ios version + check if last cell to hide it
            [self handelLayoutMargins:cell];
            
            // swappable cell
            NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
            SwappableCellVariationData *cellData = [dict objectForKey:@"swappable_cell_variation_data"];
            
            [(ProductSwappableAssemblyTableViewCell*)cell setSwappableVariationArray:[cellData.productItem variationsArray]];
            [(ProductSwappableVariationCell*)cell setDataForCell:cellData];
            [(ProductSwappableVariationCell *)cell generateSwappableVariationViews:cellData.productItem.variationsArray
                                                             withSelectedVariation:cellData.entity.variationId];
            
            // set the delegate to self for clicked variation action
            [(ProductSwappableVariationCell*)cell setProductSwappableVariationCellDelegate:self];
            [(ProductSwappableVariationCell *)cell setGenericWebViewDelegate:self.genericWebViewDelegate];
        }
            break;
            
        case ProductCellTypeAssemblyWithVariation:
        {
            //NSLog(@"ProductCellTypeSwappableAssembly type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagButtonCell0"];
            if (cell == nil)
            {
                cell = [[ProductSwappableAssemblyTableViewCell alloc] init];
                [(ProductSwappableAssemblyTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
                [(ProductSwappableAssemblyTableViewCell*)cell setProductSwappableVariationCellDelegate:self];
            }
            
            cell = (ProductSwappableAssemblyTableViewCell*)cell;
            // set separator inset according to ios version + check if last cell to hide it
            [self handelLayoutMargins:cell];
            
            NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
            ProductDO * cbpdo = [dict objectForKey:@"item"];
            SwappableCellVariationData *cellData = [dict objectForKey:@"swappable_cell_variation_data"];
            
            [(ProductSwappableAssemblyTableViewCell*)cell setSwappableVariationArray:[cbpdo variationsArray]];
            [(ProductSwappableAssemblyTableViewCell*)cell setDataForCell:cellData];
            [(ProductSwappableAssemblyTableViewCell*)cell setType:ProductCellTypeAssemblyWithVariation];
            
            // generate ImageViews in cell scroll view with selected item
            [(ProductSwappableAssemblyTableViewCell *)cell generateSwappableVariationViews:cbpdo.variationsArray
                                                                     withSelectedVariation:cellData.entity.variationId];
            
            // set the delegate to self for clicked variation action
            [(ProductSwappableAssemblyTableViewCell*)cell setProductSwappableVariationCellDelegate:self];
            [(ProductSwappableAssemblyTableViewCell *)cell setGenericWebViewDelegate:self.genericWebViewDelegate];
        }
            break;
            
        case ProductCellTypeAssemblyInfo:
        {
            //NSLog(@"ProductCellTypeAssemblyInfo type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagButtonCell5"];
            if (cell == nil)
            {
                cell = [[ProductAssemblyInfoTableViewCell alloc] init];
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:(0/255.0f) green:(0/255.0f) blue:(0/255.0f) alpha:1]];
                [(ProductAssemblyInfoTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
                [(ProductAssemblyInfoTableViewCell*)cell setProductSwappableVariationCellDelegate:self];
            }
            
            // set separator inset according to ios version + check if last cell to hide it
            [self handelLayoutMargins:cell];
            
            NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
            ProductDO * cbpdo = [dict objectForKey:@"item"];
            SwappableCellVariationData *cellData = [dict objectForKey:@"swappable_cell_variation_data"];
            [(ProductAssemblyInfoTableViewCell*)cell setDataForCell:cellData];
            
            [self setAssemblyInfoCell:cell andAssemblyPart:cbpdo];
            
            // set the delegate to self for clicked variation action
            [(ProductAssemblyInfoTableViewCell*)cell setProductSwappableVariationCellDelegate:self];
            [(ProductAssemblyInfoTableViewCell *)cell setGenericWebViewDelegate:self.genericWebViewDelegate];
        }
            break;

            
        case ProductCellTypeProductDetails:
        {
            //NSLog(@"ProductCellTypeProductDetails type = %d", type);

            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagButtonCell1"];
            if (cell == nil)
            {
                cell = [[ProductInfoRegularTableViewCell alloc] init];
                [(ProductInfoRegularTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version + check if last cell to hide it
            [self handelLayoutMargins:cell];
            
            [self setCellEnabled:cell];
            //product details
            [[(ProductInfoRegularTableViewCell *)cell optionButton] setTitle:NSLocalizedString(@"prod_action_dimension_btn_title", @"") forState:UIControlStateNormal];
            [[(ProductInfoRegularTableViewCell *)cell optionButton] addTarget:self action:@selector(productSite) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case ProductCellTypeDuplicateProduct:
        {
            //NSLog(@"ProductCellTypeDuplicateProduct type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagButtonCell2"];
            if (cell == nil)
            {
                cell = [[ProductInfoRegularTableViewCell alloc] init];
                [(ProductInfoRegularTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
            
            //duplicate product
            [[(ProductInfoRegularTableViewCell *)cell optionButton] setTitle:NSLocalizedString(@"prod_action_duplicate_btn_title", @"") forState:UIControlStateNormal];
            [[(ProductInfoRegularTableViewCell *)cell optionButton] addTarget:self action:@selector(duplicateProduct:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case ProductCellTypeRestoreScale:
        {
            //NSLog(@"ProductCellTypeRestoreScale type = %d", type);

            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagButtonCell3"];
            if (cell == nil)
            {
                cell = [[ProductInfoRegularTableViewCell alloc] init];
                [(ProductInfoRegularTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
            
            [[(ProductInfoRegularTableViewCell *)cell optionButton] setTitle:NSLocalizedString(@"prod_action_restore_btn_title", @"") forState:UIControlStateNormal];
            [[(ProductInfoRegularTableViewCell *)cell optionButton] addTarget:self action:@selector(restoreProductScale:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case ProductCellTypeBrightness:
        {
            //NSLog(@"ProductCellTypeBrightness type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagSliderCell"];
            if (cell == nil)
            {
                cell = [[ProductInfoBrightnessTableViewCell alloc] init];
                [(ProductInfoBrightnessTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
            
            [[(ProductInfoBrightnessTableViewCell *)cell optionButton] setTitle:NSLocalizedString(@"prod_action_brightness_btn_title", @"") forState:UIControlStateNormal];
            [[(ProductInfoBrightnessTableViewCell *)cell resetBrightnessButton] addTarget:self action:@selector(resetBrightness:) forControlEvents:UIControlEventTouchUpInside];
            [[(ProductInfoBrightnessTableViewCell *)cell brightnessSlider] addTarget:self action:@selector(productBrightnessSliderChanged:) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.currentProductEntity) {
                // Set the minimal and maximal brightness slider values. These values are configurable
                // but must be in the range of [0,1] and obviously min < max
                [[(ProductInfoBrightnessTableViewCell *)cell brightnessSlider]  setMinimumValue:[[ConfigManager sharedInstance] productBrightnessMinValue]];
                [[(ProductInfoBrightnessTableViewCell *)cell brightnessSlider]  setMaximumValue:[[ConfigManager sharedInstance] productBrightnessMaxValue]];
                
                // Set the brightness slider to point to the correct value as the product brightness
                // As both the slider and entity's ranges are [0,1] we can set it directly
                [[(ProductInfoBrightnessTableViewCell *)cell brightnessSlider]  setValue:self.currentProductEntity.brightness];
            }
        }
            break;
        case ProductCellTypeRemoveItem:
        {
            //NSLog(@"ProductCellTypeRemoveItem type = %d", type);

            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagRemoveProductCell"];
            if (cell == nil)
            {
                cell = [[ProductInfoRegularTableViewCell alloc] init];
                [(ProductInfoRegularTableViewCell *)cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
            
            [[(ProductInfoRegularTableViewCell *)cell optionButton] setTitle:NSLocalizedString(@"prod_action_remove_btn_title", @"") forState:UIControlStateNormal];
            [[(ProductInfoRegularTableViewCell *)cell optionButton] addTarget:self action:@selector(removeProduct:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case ProductcellTypeTagGroupTitleCell:
        {
            //NSLog(@"ProductcellTypeTagGroupTitleCell type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagGroupTitleCell"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] init];
                [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
            
            NSDictionary * dict = [_tableElementsArray objectAtIndex:indexPath.row];
            CatalogGroupDO * cgdo = [dict objectForKey:@"item"];
            [((ProductTagGroupTitleCell*)cell) setBackgroundColor:[UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1]];
            [((ProductTagGroupTitleCell*)cell).familyTitle  setText:[cgdo groupName]];
            
            // set sccessory arrow view (open/close)
            ((ProductTagGroupTitleCell*)cell).accessoryView = [ProductInfoGroupSectionAccessory accessoryWithColor:[UIColor colorWithRed:(45/255.0) green:(45/255.0) blue:(45/255.0) alpha:1] type:CustomColoredAccessoryTypeRight];
            
            // rotate arrow
            BOOL isExist = [[_expandedRows objectForKey:[cgdo groupName]] boolValue];
            if (isExist)
            {
                //open
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }
            else
            {
                //close
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI * 2);
            }
            // set border to cell
            [cell.layer setBorderWidth:0.5];
            [cell.layer setBorderColor:[UIColor colorWithRed:(198/255.0) green:(198/255.0) blue:(198/255.0) alpha:1].CGColor];
        }
            break;

          
        case ProductcellTypeTagGroupHeaderCell:
        {
            //NSLog(@"ProductcellTypeTagGroupHeaderCell type = %d", type);
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"productTagGroupTitleCell"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] init];
                [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            }
            
            // set separator inset according to ios version
            [self handelLayoutMargins:cell];
            
            [((ProductTagGroupTitleCell*)cell) setBackgroundColor:[UIColor whiteColor]];
            [((ProductTagGroupTitleCell*)cell).familyTitle  setText:NSLocalizedString(@"available_variations", @"")];
            
            // set sccessory arrow view (open/close)
            ((ProductTagGroupTitleCell*)cell).accessoryView = [ProductInfoGroupSectionAccessory accessoryWithColor:[UIColor colorWithRed:(45/255.0) green:(45/255.0) blue:(45/255.0) alpha:1] type:CustomColoredAccessoryTypeRight];
            
            // rotate arrow
            
            BOOL isExist = [[_expandedRows objectForKey:NSLocalizedString(@"available_variations", @"")] boolValue];
            
            if (isExist)
            {
                //open
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }
            else
            {
                //close
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI * 2);
            }
            // set border to cell
            [cell.layer setBorderWidth:0.5];
            [cell.layer setBorderColor:[UIColor colorWithRed:(198/255.0) green:(198/255.0) blue:(198/255.0) alpha:1].CGColor];
        }
            break;
        default:
            break;
    }// end of switch
    
    return cell;
}

-(void)handelLayoutMargins:(UITableViewCell*)cell{
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [(ProductInfoTitleTableViewCell *)cell setPreservesSuperviewLayoutMargins: NO];
        
        [cell setLayoutMargins:CELL_SEPARATOR_VISIBLE];
    }
    else
    {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:CELL_SEPARATOR_NOT_VISIBLE];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)clearTitleCell:(UITableViewCell *)tempCell
{
    [[[(ProductInfoTitleTableViewCell *)tempCell scrollView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Setting the placeholder when clearing the cell to avoid a glitch in UI
    [[(ProductInfoTitleTableViewCell *)tempCell brandImageView] setImage:[UIImage imageNamed:@"place_holder.png"]];
    [[(ProductInfoTitleTableViewCell *)tempCell brandNameLabel] setText:@""];
    [[(ProductInfoTitleTableViewCell *)tempCell productNameLabel] setText:@""];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTitleCell:(UITableViewCell *)tempCell
{
    //init product information availbale before fetching additional data (images etc.)
    [[(ProductInfoTitleTableViewCell *)tempCell closeProductInfoButton] addTarget:self action:@selector(closeProductInfoView:) forControlEvents:UIControlEventTouchUpInside];
    [[(ProductInfoTitleTableViewCell *)tempCell productNameLabel] setText:self.currentProduct.product.Name];
    if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) {
        [[(ProductInfoTitleTableViewCell *)tempCell brandNameLabel] setText:[( self.currentProduct.product.vendorName)?self.currentProduct.product.vendorName:@"" uppercaseString]];
    }else{
        [[(ProductInfoTitleTableViewCell *)tempCell brandNameLabel] setText:[( self.currentProduct.product.productVendor.vendorName)?self.currentProduct.product.productVendor.vendorName:@"" uppercaseString]];
    }
    
    // get brand image + data
    if (self.currentProduct.product.vendorLogoUrl && [self.currentProduct.product.vendorLogoUrl length]>0) {
        
        CGSize designSize = [(ProductInfoTitleTableViewCell *)tempCell brandImageView].frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: self.currentProduct.product.vendorLogoUrl,
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : [(ProductInfoTitleTableViewCell *)tempCell brandImageView]};
        
        [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta){
            NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:[(ProductInfoTitleTableViewCell *)tempCell brandImageView]];
            
            if (currentUid == uid){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        [[(ProductInfoTitleTableViewCell *)tempCell brandImageView] setHidden:NO];
                        [[(ProductInfoTitleTableViewCell *)tempCell brandImageView] setImage:image];
                    }else{
                        [[(ProductInfoTitleTableViewCell *)tempCell brandImageView] setHidden:YES];
                    }
                });
            }
        }];
    }else {
        //no url
        [[(ProductInfoTitleTableViewCell *)tempCell brandImageView] setHidden:YES];
    }
    
    int width = IS_IPAD ? IPAD_PRODUCT_PROJECT_WIDTH : IPHONE_PRODUCT_PROJECT_WIDTH;
    __block int height = 0;
    
    // Load Main product image:
    // checking: if product is not assembly and has more than 1 variation part - we change the title cell data to the chosen variation
    if (![self.currentProduct.product isAssembly] && self.currentProduct.product.variationsArray.count > 1)
    {
        VariationDO *variation;
        // get current selected variation
        for (VariationDO *var in self.currentProduct.product.variationsArray)
        {
            if ([var.variationId isEqualToString:_currentProductEntity.variationId])
            {
                variation = var;
                break;
            }
        }
        
        // set product name label
        [[(ProductInfoTitleTableViewCell *)tempCell productNameLabel] setText:variation.variationName];

        // Add an imageView to the scrollView before setting the selected variation image
        ProductTagImageView *imv = [ProductTagImageView getProductTagImageView];
        imv.genericWebViewDelegate = self.genericWebViewDelegate;
        imv.frame = [(ProductInfoTitleTableViewCell *)tempCell scrollView].frame;
        NSString* newStr = self.currentProduct.product.isNewProduct;
        Boolean isNewProduct = [newStr isEqualToString:@"New"];
        [imv.ribonImage setHidden:!isNewProduct];
        [imv.ribonLabel setHidden:!isNewProduct];
        [imv setupProductImage:[variation.files objectForKey:@"iso"]
                        andUrl:@""
                        prodID:_currentProductEntity.variationId
                    vendorName:@""];

        
        [[(ProductInfoTitleTableViewCell *)tempCell scrollView] addSubview:imv];
    }
    else
    {
        //get and set the product image
        for (int i = 0; i<[self.currentProduct.product.productImages count]; i++)
        {
            ProductTagImageView *imv = [ProductTagImageView getProductTagImageView];
            
            imv.genericWebViewDelegate = self.genericWebViewDelegate;
            
            [imv setupProductImage:[self.currentProduct.product.productImages objectAtIndex:i]
                            andUrl:[self.currentProduct.product getVendorSiteAtIndex:0]
                            prodID:self.currentProduct.product.productId
                        vendorName:self.currentProduct.product.productVendor.vendorName];
            
            NSString* newStr = self.currentProduct.product.isNewProduct;
            Boolean isNewProduct = [newStr isEqualToString:@"New"];
            [imv.ribonImage setHidden:!isNewProduct];
            [imv.ribonLabel setHidden:!isNewProduct];
            
            if (!self.productImagesArray) {
                self.productImagesArray = [NSMutableArray array];
            }
            
            [self.productImagesArray addObject:imv];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[(ProductInfoTitleTableViewCell *)tempCell scrollView] addSubview:imv];
                height = imv.frame.size.height;
                imv.frame=CGRectMake(i*width, 0, [[(ProductInfoTitleTableViewCell *)tempCell scrollView] frame].size.width, [[(ProductInfoTitleTableViewCell *)tempCell scrollView] frame].size.height);
                
            });
        }
    }
    
    int totalWidth = (int)self.currentProduct.product.productImages.count * width;
    [[(ProductInfoTitleTableViewCell *)tempCell scrollView] setContentOffset:CGPointMake(0, 0)];
    [[(ProductInfoTitleTableViewCell *)tempCell scrollView] setContentSize:CGSizeMake(totalWidth, height)];
    
    if (IS_IPHONE) {
        [[(ProductInfoTitleTableViewCell *)tempCell goToWebBtn] setHidden:([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) ? YES : NO];
        [[(ProductInfoTitleTableViewCell *)tempCell goToWebBtn] setEnabled:(self.currentProduct.product.vendorLink) ? YES : NO];
    }else{
        [[(ProductInfoTitleTableViewCell *)tempCell goToWebBtnForIpad] setHidden:([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) ? YES : NO];
        [[(ProductInfoTitleTableViewCell *)tempCell goToWebBtnForIpad] setEnabled:(self.currentProduct.product.vendorLink) ? YES : NO];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setAssemblyInfoCell:(UITableViewCell *)tempCell andAssemblyPart:(ProductDO *)assemblyPart
{
    //init product information availbale before fetching additional data (images etc.)
    [[(ProductAssemblyInfoTableViewCell *)tempCell assemblyProductNameLabel] setText:assemblyPart.Name];
    
    int width = IS_IPAD ? IPAD_PRODUCT_PROJECT_WIDTH : IPHONE_PRODUCT_PROJECT_WIDTH;
    __block int height = 0;
    
    //get and set the product image
    for (int i = 0; i<[assemblyPart.productImages count]; i++)
    {
        ProductTagImageView *imv = [ProductTagImageView getProductTagImageView];
        
        imv.genericWebViewDelegate = self.genericWebViewDelegate;
        [imv setupProductImage:[assemblyPart.productImages objectAtIndex:i] andUrl:
         [assemblyPart getVendorSiteAtIndex:0]prodID:assemblyPart.productId vendorName:assemblyPart.productVendor.vendorName];
        NSString* newStr = assemblyPart.isNewProduct;
        Boolean isNewProduct = [newStr isEqualToString:@"New"];
        [imv.ribonImage setHidden:!isNewProduct];
        [imv.ribonLabel setHidden:!isNewProduct];
        
        if (!self.productImagesArray) {
            self.productImagesArray = [NSMutableArray array];
        }
        
        [self.productImagesArray addObject:imv];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[(ProductAssemblyInfoTableViewCell *)tempCell scrollView] addSubview:imv];
            height = imv.frame.size.height;
            imv.frame=CGRectMake(i*width, 0, [[(ProductAssemblyInfoTableViewCell *)tempCell scrollView] frame].size.width, [[(ProductAssemblyInfoTableViewCell *)tempCell scrollView] frame].size.height);
        });
    }
    
    int totalWidth = (int)assemblyPart.productImages.count * width;
    [[(ProductInfoTitleTableViewCell *)tempCell scrollView] setContentOffset:CGPointMake(0, 0)];
    [[(ProductInfoTitleTableViewCell *)tempCell scrollView] setContentSize:CGSizeMake(totalWidth, height)];
}


////////////////////////////////////////////////////////////////////////////////////////////////////

/* 
 set Enabled state to 'rescale' option buttun
 */
-(void)setScaleCellEnabled:(UITableViewCell*)tempCell
{
    SavedDesign * design = [[DesignsManager sharedInstance] workingDesign];

    if ([design isEntityScaled:self.currentProductEntity] && self.currentProductEntity)
        [[(ProductInfoRegularTableViewCell *)tempCell optionButton] setEnabled:YES];
    else
        [[(ProductInfoRegularTableViewCell *)tempCell optionButton] setEnabled:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

/*
set Enabled state to given cell option buttun
*/
-(void)setCellEnabled:(UITableViewCell*)tempCell
{
    if(self.currentProduct.product.IsGeneric)
        [[(ProductInfoRegularTableViewCell *)tempCell optionButton] setEnabled:NO];
    else
        [[(ProductInfoRegularTableViewCell *)tempCell optionButton] setEnabled:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)getCellLocationInTable:(ProductCellType)cell
{
    for (NSUInteger i = 0; i < [self.cellsArray count]; ++i)
    {
        NSNumber *valueAtIndex = [self.cellsArray objectAtIndex:i];
        if ([valueAtIndex integerValue] == cell)
            return i;
    }
    
    return -1;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - ProductSwappableVariationCellDelegate
- (void)swapEntity:(Entity*)entity withVariation:(VariationDO*)variation 
{
    RETURN_VOID_ON_NIL(entity);
    RETURN_VOID_ON_NIL(variation);
    
    // Do not switch variation if it is already selected
    if ([variation.variationId isEqual:[entity variationId]])
        return;
    
    if (self.productDelegate &&
        [self.productDelegate respondsToSelector:@selector(variateEntity:withVariationId:)])
    {
        [self.productDelegate variateEntity:entity
                            withVariationId:variation.variationId];
    }
    
    // check: if product is not assembly we change the title cell data (image) to the chosen variation
    if (![self.currentProduct.product isAssembly])
    {
        ProductInfoTitleTableViewCell *cellTitle = (ProductInfoTitleTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ]];
        [(ProductTagImageView *)[cellTitle.scrollView.subviews objectAtIndex:0] setupProductImage:[variation.files objectForKey:@"iso"]
                                                                                           andUrl:@""
                                                                                           prodID:variation.variationId
                                                                                       vendorName:@""];
        [cellTitle.productNameLabel setText:variation.variationName];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)swapEntityWithProduct:(ProductDO*)product{
    
    RETURN_VOID_ON_NIL(product);

    if (self.productDelegate &&
        [self.productDelegate respondsToSelector:@selector(productEntityWithProductId:)])
    {
        [self.productDelegate productEntityWithProductId:[product productId]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SEGMENT
-(void)segmentProductDetails{
    
    if (self.currentProduct.product.productId == nil ||
        self.currentProduct.product.Name == nil ||
        self.currentProduct.product.vendorName == nil) {
        return;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:self.currentProduct.product.productId forKey:@"product id"];
    [dict setObject:self.currentProduct.product.Name forKey:@"product title"];
    [dict setObject:self.currentProduct.product.vendorName forKey:@"brand"];
    
//    [HSFlurry segmentTrack:EVENT_NAME_PRODUCT_DETAILS withParameters:dict];
}
@end

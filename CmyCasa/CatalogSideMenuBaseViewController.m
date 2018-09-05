//
//  CatalogSideMenuViewController.m
//  Homestyler
//
//  Created by Maayan Zalevas on 7/9/14.
//
//

#import "CatalogSideMenuBaseViewController.h"
#import "UIImage+SafeFileLoading.h"
#import "UIView+Effects.h"
#import "WishListProductDO.h"
#import "CatalogMenuLogicManger.h"
#import "DataManager.h"

@interface CatalogSideMenuBaseViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (nonatomic, strong) NSArray *arrTopLevelData;
@property (nonatomic, strong) NSDictionary *dicAllItems;

@end

@implementation CatalogSideMenuBaseViewController

- (void)setDataArray:(NSArray *)dataArray
  andItemsDictionary:(NSDictionary *)dicItems
         catalogType:(CatalogType)catalogType
{
    [self.backBtn setTitle:@"" forState:UIControlStateNormal];
    self.catalogType = catalogType;
    self.arrTopLevelData = [dataArray copy];
    self.dicAllItems = [dicItems copy];
    self.arrPresentedData = [NSMutableArray arrayWithArray:self.arrTopLevelData];
    
    [self reloadSideMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backBtn setTitle:@"" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ((self.arrPresentedData == nil) || (self.arrPresentedData.count == 0))
    {
        if ((self.dataSource != nil) && ([self.dataSource respondsToSelector:@selector(requestDataRefresh)]))
        {
            [self.dataSource requestDataRefresh];
        }
    }
}

-(void)refreshData{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.arrPresentedData = nil;
    self.arrTopLevelData = nil;
    self.dicAllItems = nil;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - CatalogSideMenuBaseViewController");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrPresentedData count];
}

/*** THIS IS A DEFAULT IMPLEMENTATION, SHOULD BE IMPLEMENTED BY THE SUBCLASS ***/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    return cell;
}

- (void)flurryCategory:(id <CatalogSideMenuItemProtocol>)category
{
#ifdef USE_FLURRY
    NSString *catname = [category getName];
    
    if (catname == nil || [catname isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if (ANALYTICS_ENABLED)
    {
//        [ HSFlurry logEvent:FLURRY_CATALOG_ROOT_CATEGORY_CLICK withParameters:[NSDictionary dictionaryWithObject:catname forKey:EVENT_ACTION_CATALOG_NAME]];
    }
#endif
}

- (void)flurryWishList:(WishListProductDO*)wishList
{
#ifdef USE_FLURRY
    NSString *catname = wishList.productName;
    
    if (catname == nil || [catname isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if (ANALYTICS_ENABLED)
    {
//        [ HSFlurry logEvent:FLURRY_CATALOG_ROOT_WISHLIST_CLICK withParameters:[NSDictionary dictionaryWithObject:catname forKey:@"wishlist_category"]];
    }
#endif
}

- (void)flurrySubCategory:(id <CatalogSideMenuItemProtocol>)category
{
#ifdef USE_FLURRY
    NSString *catname = [category getName];
    
    if (catname==nil || [catname isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if (ANALYTICS_ENABLED)
    {
//        [HSFlurry logEvent:FLURRY_CATALOG_SUB_CATEGORY_CLICK withParameters:[NSDictionary dictionaryWithObject:catname forKey:EVENT_ACTION_CATALOG_NAME]];
    }
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.arrPresentedData == nil) || (self.arrPresentedData.count <= indexPath.row))
    {
        return;
    }
    
    if (self.catalogType == PRODUCTS_CATALOG) {
        id <CatalogSideMenuItemProtocol> category = [self.arrPresentedData objectAtIndex:indexPath.row];
        
        if ([category hasChildren])
        {
            [self flurryCategory:category];
            
            //analytics
            [[DataManger sharedInstance] setCategory:[category getName]];
            
            self.arrPresentedData = [NSMutableArray arrayWithArray:[category getChildren]];          
            
            self.titleLabel.text = [category getName];
            [self.backBtn setTitle:@"" forState:UIControlStateNormal];
            
            [self.tableView setContentOffset:CGPointZero animated:NO];
            [self.tableView reloadData];
        }
        else
        {
            [self flurrySubCategory:category];
            
             //analytics
            [[DataManger sharedInstance] setCategory:@""];
            [[DataManger sharedInstance] setSubCategory:[category getName]];

            
            if ((self.delegate) && (category) && ([category getId]))
            {
                [self.delegate catalogSideMenuItemPickedWithId:[category getId] catalogType:PRODUCTS_CATALOG];
                [[CatalogMenuLogicManger sharedInstance] setSelectedCategoryId:[category getId]];
                [CatalogMenuLogicManger sharedInstance].searchHistory = nil;
            }
        }
    }else if (self.catalogType == WISHLIST_CATALOG){
        WishListProductDO * category = [self.arrPresentedData objectAtIndex:indexPath.row];
        
        [self flurryWishList:category];
        
        if ((self.delegate) && (category) && ([category productId]))
        {
            [self.delegate catalogSideMenuItemPickedWithId:[category productId] catalogType:WISHLIST_CATALOG];
        }
    }
}

- (IBAction)backPressed:(id)sender
{
    if (self.catalogType == PRODUCTS_CATALOG) {
        
        self.titleLabel.text = NSLocalizedString(@"select_category_title", @"");
        
        NSString *strParentId = nil;
        NSArray *tempPresentedArr = nil;
        
        if ((self.arrPresentedData != nil) && (self.arrPresentedData.count > 0))
        {
            id <CatalogSideMenuItemProtocol> currentCat = [self.arrPresentedData objectAtIndex:0];
            strParentId = [currentCat getParentId];
        }
        
        if (strParentId != nil)
        {
            id <CatalogSideMenuItemProtocol> parentCat = [self.dicAllItems objectForKey:strParentId];
            NSString *strGrandparentId = nil;
            
            if (parentCat != nil)
            {
                strGrandparentId = [parentCat getParentId];
            }
            
            if (strGrandparentId != nil)
            {
                id <CatalogSideMenuItemProtocol> grandparentCat = [self.dicAllItems objectForKey:strGrandparentId];
                tempPresentedArr = [[grandparentCat getChildren] copy];
            }
        }
        
        if (tempPresentedArr != nil)
        {
            self.arrPresentedData = [NSMutableArray arrayWithArray:tempPresentedArr];
            [self.backBtn setTitle:@"" forState:UIControlStateNormal];
        }
        else
        {
            self.arrPresentedData = [NSMutableArray arrayWithArray:self.arrTopLevelData];
            [self.backBtn setTitle:@"" forState:UIControlStateNormal];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)isTopLevelCategory:(CatalogCategoryDO*)category {
    return [self.arrTopLevelData containsObject:category];
}

-(void)reloadSideMenuForCategoryId:(NSString*)categoryId{
    if (categoryId != nil)
    {
        self.selectedCategoryId = categoryId;
        
         CatalogCategoryDO * category = [self.dicAllItems objectForKey:categoryId];
        
        NSString *parentId = nil;
        NSArray *tempPresentedArr = nil;
        
        if (category)
        {
            parentId = [category getParentId];
            
            if ([parentId isEqualToString:@"0"]){
                self.arrPresentedData = [NSMutableArray arrayWithArray:self.arrTopLevelData];
                [self.backBtn setTitle:@"" forState:UIControlStateNormal];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView selectRowAtIndexPath:indexPath
                                                animated:YES
                                          scrollPosition:UITableViewScrollPositionNone];
                    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];

                });
            }else{
                CatalogCategoryDO * parentCat = [self.dicAllItems objectForKey:parentId];
                tempPresentedArr = [[parentCat getChildren] copy];
                
                if (tempPresentedArr){
                    self.arrPresentedData = [NSMutableArray arrayWithArray:tempPresentedArr];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.backBtn setTitle:@"" forState:UIControlStateNormal];
                        self.titleLabel.text = [parentCat getName];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                        
                        for (int i = 0; i < [tempPresentedArr count]; i++) {
                            CatalogCategoryDO* selectedCategoryId = [tempPresentedArr objectAtIndex:i];
                            
                            if ([[selectedCategoryId getId] isEqualToString:categoryId]) {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                                [self.tableView selectRowAtIndexPath:indexPath
                                                            animated:YES
                                                      scrollPosition:UITableViewScrollPositionNone];
                                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                                break;
                            }
                        }
                        
                     });
                }
            }
        }
    }
}

-(void)reloadSideMenu{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)backToTopLevelCategory{
    self.arrPresentedData = [NSMutableArray arrayWithArray:self.arrTopLevelData];
    
    [self.backBtn setTitle:@"" forState:UIControlStateNormal];
    [self.titleLabel setText:NSLocalizedString(@"select_category_title", @"")];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

@end

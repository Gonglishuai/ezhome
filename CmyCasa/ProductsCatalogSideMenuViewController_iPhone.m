//
//  iPhoneProductsCatalogSideMenuViewController.m
//  Homestyler
//
//  Created by Maayan Zalevas on 7/16/14.
//
//

#import "ProductsCatalogSideMenuViewController_iPhone.h"
#import "CategoryCell_iPhone.h"
#import "WishListProductDO.h"
#import "ModelsHandler.h"
#import "WishlistHandler.h"
#import "CatalogMenuLogicManger.h"

@implementation ProductsCatalogSideMenuViewController_iPhone

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.view.alpha = 0;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (self.catalogType == WISHLIST_CATALOG)
        return YES;
    else
        return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        WishListProductDO * wlpdo = [self.arrPresentedData objectAtIndex:indexPath.row];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.arrPresentedData removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        });
        
        [[WishlistHandler sharedInstance] deleteWishlist:wlpdo.productId withCompletionBlock:^(id serverResponse, id error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCatalogDataRequestedNotification" object:nil];
        } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell_iPhone *cell = nil;
    
    if (indexPath.row == [self addYourBrandRowNumber]) //in case this is the last row
    {
        static NSString *CellIdentifierSub = @"CellAddBrand";
        
        cell = (CategoryCell_iPhone *) [tableView dequeueReusableCellWithIdentifier:CellIdentifierSub forIndexPath:indexPath];
        cell.catTitle.text = NSLocalizedString(@"side_menu_cell_add_your_brand", @"Add Your Brand");
    }
    else
    {
        if (self.catalogType == PRODUCTS_CATALOG) {
            
            CatalogCategoryDO *category = nil;
            
            if (self.arrPresentedData != nil)
            {
                category = [self.arrPresentedData objectAtIndex:indexPath.row];
            }
            
            
            NSString* CellIdentifierSub = @"Cell";
            
            BOOL isTopLevelCategory = [self isTopLevelCategory:category];
            if (isTopLevelCategory) {
                CellIdentifierSub = @"RootCell";
            }
            
            cell = (CategoryCell_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierSub];
            
            [cell updateWithCategory:category isRoot:isTopLevelCategory];
            [cell.deleteIndicator setHidden:YES];
        }else if(self.catalogType == WISHLIST_CATALOG){
            
            WishListProductDO * wishList = nil;
            
            if ((self.arrPresentedData != nil) && (indexPath.row < [self.arrPresentedData count]))
            {
                wishList = [self.arrPresentedData objectAtIndex:indexPath.row];
            }
            
            cell = (CategoryCell_iPhone *) [tableView dequeueReusableCellWithIdentifier:@"RootCell"];
            
            [cell updateWithWishList:wishList isRoot:NO];
            [cell.deleteIndicator setHidden:NO];
            return cell;
        }
    }
    
    return  cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger res = 0;
    if ([ConfigManager isAddYourBrandActive]) {
        res = [super tableView:tableView numberOfRowsInSection:section] + 1; //+1 for the add your brand row
    }else{
        res = [super tableView:tableView numberOfRowsInSection:section] ;
    }
    return res;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self addYourBrandRowNumber])
    {
        [self buttonPressedAddYouBrand];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)buttonPressedAddYouBrand
{
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(buttonPressedAddYouBrand)]))
    {
        [self.delegate performSelector:@selector(buttonPressedAddYouBrand)];
    }
}

- (NSInteger)addYourBrandRowNumber
{
    NSInteger iLastRow = -1;
    
    if (self.arrPresentedData != nil)
    {
        iLastRow  = self.arrPresentedData.count;
    }
    
    return iLastRow;
}

@end

//
//  ProductsCatalogSideMenuViewController_iPad.m
//  Homestyler
//
//  Created by Maayan Zalevas on 7/16/14.
//
//

#import "ProductsCatalogSideMenuViewController_iPad.h"
#import "CatalogCategoryDO.h"
#import "WishListProductDO.h"
#import "CatalogCell.h"
#import "WishlistHandler.h"
#import "CatalogMenuLogicManger.h"


@implementation ProductsCatalogSideMenuViewController_iPad

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
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
                //update complete map
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCatalogDataRequestedNotification" object:nil];
            
        } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (self.catalogType == PRODUCTS_CATALOG) {
        
        CatalogCategoryDO *category = nil;
        
        if ((self.arrPresentedData != nil) && (indexPath.row < [self.arrPresentedData count]))
        {
            category = [self.arrPresentedData objectAtIndex:indexPath.row];
        }
        
        BOOL isTopLevelCategory = [self isTopLevelCategory:category];
        if (isTopLevelCategory) {
            CellIdentifier = @"RootCell";
        }
        
        CatalogCell *cell = (CatalogCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        [cell updateWithCategory:category isRoot:isTopLevelCategory];
        [cell.deleteIndicator setHidden:YES];
        cell.selectionBackground.hidden = YES;
        return cell;
        
    } else if (self.catalogType == WISHLIST_CATALOG){
        
        WishListProductDO * wishList = nil;
        
        if ((self.arrPresentedData != nil) && (indexPath.row < [self.arrPresentedData count]))
        {
            wishList = [self.arrPresentedData objectAtIndex:indexPath.row];
        }

        CatalogCell *cell = (CatalogCell *) [tableView dequeueReusableCellWithIdentifier:@"RootCell"];
        
        [cell updateWithWishList:wishList isRoot:NO];
        [cell.deleteIndicator setHidden:NO];
        
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


@end

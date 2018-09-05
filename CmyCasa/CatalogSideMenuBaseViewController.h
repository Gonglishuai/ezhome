//
//  CatalogSideMenuViewController.h
//  Homestyler
//
//  Created by Maayan Zalevas on 7/9/14.
//
//

#import <UIKit/UIKit.h>
#import "CatalogSideMenuProtocols.h"
#import "CatalogCategoryDO.h"
#import "ProtocolsDef.h"

@interface CatalogSideMenuBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id <CatalogSideMenuDataSourceProtocol> dataSource;
@property (nonatomic, weak) id <CatalogSideMenuDelegate> delegate;
@property (nonatomic, assign) CatalogType  catalogType;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *arrPresentedData;
@property (nonatomic, strong) NSString * selectedCategoryId;

#pragma mark - Private Functions

- (IBAction)backPressed:(id)sender;

#pragma mark - Public functions
/*
    To be called after alloc init
    Set the dataArray which is an array of top level items
    Set the dicItems with a flat view of all items, top level and children, keyed by their ids
    All items should implement "CatalogSideMenuItemProtocol"
*/

- (void)setDataArray:(NSArray *)dataArray andItemsDictionary:(NSDictionary *)dicItems catalogType:(CatalogType)catalogType;

- (BOOL)isTopLevelCategory:(CatalogCategoryDO*)category;
- (void)backToTopLevelCategory;

/*
 *  refresh side menu table for spesific categories
 */
- (void)reloadSideMenuForCategoryId:(NSString*)categoryId;

/*
 *  refresh side menu table
 */
- (void)reloadSideMenu;

@end

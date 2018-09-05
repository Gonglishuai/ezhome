//
//  CatalogSideMenuProtocols.h
//  Homestyler
//
//  Created by Maayan Zalevas on 7/14/14.
//
//

#import <Foundation/Foundation.h>

/*
    This protocol should be implemented by all DOs will be used as items for the SideMenuViewController data array.
 */
@protocol CatalogSideMenuItemProtocol <NSObject>

@required

- (BOOL)hasChildren;
- (NSString *)getId;
- (NSString *)getName;
- (NSString *)getParentId;
- (NSArray *)getChildren;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@protocol CatalogSideMenuDataSourceProtocol <NSObject>

@required

/*
    Should end with the dataSource activating "setDataArray: andItemsDictionary:"
 */
- (void)requestDataRefresh;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@protocol CatalogSideMenuDelegate <NSObject>

@optional

/*
    Called when a child menu item is selected.
 */
- (void)catalogSideMenuItemPickedWithId:(NSString *)itemId catalogType:(CatalogType)catalogType;

@end
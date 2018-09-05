//
//  CatalogGroupsDO.h
//  Homestyler
//
//  Created by Dan Baharir on 2/15/15.
//
//

#import <Foundation/Foundation.h>
#import "CatalogGroupDO.h"

@interface CatalogGroupsDO : NSObject

@property (nonatomic, strong) CatalogGroupDO *family;
@property (nonatomic, strong) NSArray *products;

- (id)initWithDictionary:(NSDictionary *)dict;

@end

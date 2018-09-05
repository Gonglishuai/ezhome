//
//  CatalogBaseProductDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/1/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@interface WishListProductDO : NSObject <RestkitObjectProtocol>

@property(nonatomic,copy) NSString * productId;
@property(nonatomic,copy) NSString * productName;
@property(nonatomic,copy) NSString * productDescription;
@property(nonatomic,copy) NSString * productCount;

+ (RKObjectMapping*)jsonMapping;

@end

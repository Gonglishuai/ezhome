//
//  ProductVendorDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/1/13.
//
//

#import "ProductVendorDO.h"

@implementation ProductVendorDO

-(instancetype)initWithName:(NSString*)name andLogo:(NSString*)logo path:(NSString*)logopath andProductURL:(NSString*)prodUrl{
    
    self=[super init];
    if (self) {
        self.vendorImagePath=logopath;
        self.vendorImageUrl=logo;
        self.vendorName=name;
        self.vendorProductUrl=prodUrl;
    }
    return self;
}
@end

//
//  ProductVendorDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/1/13.
//
//

#import <Foundation/Foundation.h>

@interface ProductVendorDO : NSObject

-(instancetype)initWithName:(NSString*)name andLogo:(NSString*)logo path:(NSString*)logopath andProductURL:(NSString*)prodUrl;

@property(nonatomic,copy) NSString *vendorName;
@property(nonatomic,copy) NSString *vendorProductUrl;
@property(nonatomic,copy) NSString *vendorImageUrl;
@property(nonatomic,copy) NSString *vendorImagePath;



@end

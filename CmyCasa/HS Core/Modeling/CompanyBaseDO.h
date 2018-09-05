//
//  CompanyBaseDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 3/4/14.
//
//

#import <Foundation/Foundation.h>



@interface CompanyBaseDO : NSObject

@property(nonatomic)NSString * companyUrl;
- (BOOL)isVendroSiteLinkExists;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end

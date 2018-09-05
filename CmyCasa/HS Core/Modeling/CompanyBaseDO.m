//
//  CompanyBaseDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 3/4/14.
//
//

#import "CompanyBaseDO.h"
#import "NSString+Contains.h"
@implementation CompanyBaseDO

-(instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self=[super init];
    self.companyUrl = [dictionary objectForKey:@"vendorUrl"];

    if ([NSString isNullOrEmpty:self.companyUrl]) {
        self.companyUrl = nil;
    }
 
    return self;
}

- (BOOL)isVendroSiteLinkExists
{
    if (! self.companyUrl) {
        return NO;
    }
    
    if (![NSURL URLWithString:self.companyUrl]) {
        return NO;
    }
    
    return YES;
}
@end

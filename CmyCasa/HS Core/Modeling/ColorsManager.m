//
//  ColorsManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "ColorsManager.h"

@implementation ColorsManager
static ColorsManager *sharedInstance = nil;

+ (ColorsManager *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[ColorsManager alloc] init];
        sharedInstance.colorCompanies=[NSMutableArray arrayWithCapacity:0];
        
        [sharedInstance prepareColorCompanies];
    });
    
    return sharedInstance;
}
-(void)prepareColorCompanies{
    
    NSMutableDictionary * config=[[ConfigManager sharedInstance] getMainConfigDict];
    
    NSArray * colorsArray=[config objectForKey:@"color_companies"];
    
    for (int i=0;i<[colorsArray count]; i++) {
        NSDictionary * comp=[colorsArray objectAtIndex:i];
        
        PaintCompanyDO * p=   [[PaintCompanyDO alloc] initWithDictionary: comp];
        [sharedInstance.colorCompanies addObject:p];
    }
}
@end

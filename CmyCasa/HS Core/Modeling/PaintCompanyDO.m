//
//  PaintCompanyDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "PaintCompanyDO.h"
#import "PaintColorCategoryDO.h"
#import "NSString+Contains.h"
#import "CompanyBaseDO.h"
#import "PackageManager.h"
#import "SDImageCache.h"

@implementation PaintCompanyDO


-(instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self=[super initWithDictionary:dictionary];
   
    self.companyName=[dictionary objectForKey:@"name"];
    self.iconRetinaUrl=[dictionary objectForKey:@"iconRatina"];
    
    self.flatAllPallets=[NSMutableArray arrayWithCapacity:0];
    self.categories=[NSMutableArray arrayWithCapacity:0];
    self.categoryColorPallets=[NSMutableDictionary dictionaryWithCapacity:0];
 
    
    NSString *fileurl=[dictionary objectForKey:@"json_url"];
    
    NSURL * url=[NSURL URLWithString:fileurl];
    NSError * error=nil;
    
    NSString* json;
    if (![ConfigManager isAnyNetworkAvailable] && [ConfigManager isOfflineModeActive])
    {
        NSData *data = [[PackageManager sharedInstance] getFileByURLString:fileurl];
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else
    {
        json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    }

    if (error != nil)
    {
        return  self;
    }
    
    NSMutableDictionary * dict= [json parseJsonStringIntoMutableDictionary];
    
    self.companyUrl = [dict objectForKey:@"vendorUrl"];
    
    if ([NSString isNullOrEmpty:self.companyUrl]) {
        self.companyUrl = nil;
    }

    
    //parse categories
    NSArray * categories=[dict objectForKey:@"category_map"];
    
    for (int i=0; i<[categories count]; i++) {
        
        PaintColorCategoryDO * pcat=[[PaintColorCategoryDO alloc]initWithDict:[categories objectAtIndex:i]];
        [self.categories addObject:pcat];
        [self.categoryColorPallets setObject:pcat forKey:pcat.categoryID];
        
    }
    //parse pallets
    NSArray * pallets=[dict objectForKey:@"pallets"];
    
    for (int i=0; i<[pallets count]; i++) {
        PaintColorPalletItemDO * pitem=[[PaintColorPalletItemDO alloc] initWithDict:[pallets objectAtIndex:i]];
        PaintColorCategoryDO * pcat=[self.categoryColorPallets objectForKey:pitem.categoryID];
        if (pcat) {
            [pcat addColorPalletItemForCategory:pitem];
        }
        
        [self.flatAllPallets addObject:pitem];
        
    }
    
    return self;
}

- (UIImage*)getLogo {
    if (self.logo) return self.logo;
    dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!self.logo) {
            NSString* url;
            if ([UIScreen mainScreen].scale > 1) {
                url = self.iconRetinaUrl;
            } else {
                url = self.iconRetinaUrl;
            }
            if (![ConfigManager isAnyNetworkAvailable] && [ConfigManager isOfflineModeActive])
            {
                NSData *data = [[PackageManager sharedInstance] getFileByURLString:url];
                self.logo = [UIImage imageWithData:data];
            }
            
            if (!self.logo)
                self.logo = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
            
            if (!self.logo) {
                self.logo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                [[SDImageCache sharedImageCache] storeImage:self.logo imageData:UIImagePNGRepresentation(self.logo) forKey:url toDisk:YES completion:nil];
            }
        }
    });
    
    return self.logo;
}

@end








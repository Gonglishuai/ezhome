//
//  FloortileCompanyDO.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import "FloortileCompanyDO.h"
#import "TilingDO.h"
#import "SDImageCache.h"
#import "PackageManager.h"

NSString * const kFloorCompanyNameKey = @"company-name";
NSString * const kFloorCompanyLogoKey = @"logo";
NSString * const kFloorCompanyLogoRetinaKey = @"logo@2x";
NSString * const kFloorCompanyBaseURL = @"base-url";
NSString * const kFloorCompanySiteURL = @"vendorUrl";
NSString * const kFloorCompanyFloortilesKey = @"floortiles";


@interface FloortileCompanyDO ()
@property (strong, nonatomic, readwrite) NSString* name;
@property (strong, nonatomic, readwrite) NSString* logoURL;
@property (strong, nonatomic, readwrite) NSString* logoRetinaURL;
@property (strong, nonatomic, readwrite) NSArray* floortiles;
@property (strong, nonatomic) UIImage* logo;
@property (atomic, readwrite) BOOL isImageDataAvailable;
@end

@implementation FloortileCompanyDO 
- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
   self = [super initWithDictionary:dictionary];

    if (!dictionary[kFloorCompanyNameKey] || !dictionary[kFloorCompanyLogoKey] ||
        !dictionary[kFloorCompanyLogoRetinaKey] || !dictionary[kFloorCompanyFloortilesKey] || !dictionary[kFloorCompanyBaseURL]) {
        return nil;
    }
    if (self = [super init])
    {
        self.name = dictionary[kFloorCompanyNameKey];
        NSString* baseURL = dictionary[kFloorCompanyBaseURL];
        self.logoURL = [baseURL stringByAppendingPathComponent:dictionary[kFloorCompanyLogoKey]];
        self.logoRetinaURL = [baseURL stringByAppendingPathComponent:dictionary[kFloorCompanyLogoRetinaKey]];
        NSArray* arr = dictionary[kFloorCompanyFloortilesKey];
        NSMutableArray* floortiles = [NSMutableArray arrayWithCapacity:arr.count];
        for (NSDictionary* d in arr)
        {
            NSString* imageURL = [baseURL stringByAppendingString:d[kTilingImageURLKey]];
            
            NSString *floorURL = @"";
            if ([d objectForKey:kTilingURLKey] != nil)
                floorURL = d[kTilingURLKey];
            
            TilingDO* floortile = [[TilingDO alloc] initWithTitle:d[kTilingTitleKey] imageURL:imageURL tileSize:d[kTilingSizeKey] tileURL:floorURL];
            floortile.tilingProperties = d[kTilingPropertiesKey];
            
            
            if ([d objectForKey:kTilingThumbKey] != nil)
                floortile.thumbURL = [baseURL stringByAppendingPathComponent:d[kTilingThumbKey]];;
            
            if (!floortile)
                break;
            
            [floortiles addObject:floortile];
        }
        self.floortiles = [floortiles copy];
    }
    return self;
}


- (instancetype)initWithImages:(NSArray*)imagesURL
{
    if (self = [super init]) {
        self.name = [NSString stringWithFormat:@"Company%d", arc4random_uniform(20000000)];
        self.logo = nil;
        self.logoRetinaURL = nil;
        NSMutableArray* floortiles = [[NSMutableArray alloc] init];
        for (NSString *url in imagesURL) {
            if (url == nil) continue;
            
            NSString *tileName = [NSString stringWithFormat:@"Tile%d", arc4random_uniform(2000000000)];
            TilingDO *newFloortile = [[TilingDO alloc] initWithTitle:tileName imageURL:url tileSize:[NSNumber numberWithInt:arc4random_uniform(300)] tileURL:@""];
            if (newFloortile)
                [floortiles addObject:newFloortile];
        }
        
        self.floortiles = [floortiles copy];
            
    }
    return self;
}

- (UIImage*)getLogo {
    dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!self.logo) {
            NSString* url;
            if ([UIScreen mainScreen].scale > 1) {
                url = self.logoRetinaURL;
            } else {
                url = self.logoURL;
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
            
            if (self.logo)
                self.isImageDataAvailable = YES;
        }
    });
    
    return self.logo;
}

- (void)loadLogoURLInBackground:(void (^)(UIImage* logo))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [self getLogo];
        block(image);
    });
}

-(void)clearCache{
    if (self.floortiles) {
        [self.floortiles makeObjectsPerformSelector:@selector(clearCache)];
        
    }
    
}
@end

//
//  WallpaperCompanyDO.m
//  Homestyler
//
//  Created by Or Sharir on 7/2/13.
//
//

#import "WallpaperCompanyDO.h"
#import "TilingDO.h"
#import "SDImageCache.h"
#import "PackageManager.h"


NSString * const kCompanyNameKey = @"company-name";
NSString * const kCompanyLogoKey = @"logo";
NSString * const kCompanyLogoRetinaKey = @"logo@2x";
NSString * const kCompanyWallpapersKey = @"wallpapers";
NSString * const kCompanyBaseURL = @"base-url";


@interface WallpaperCompanyDO ()
@end

@implementation WallpaperCompanyDO
- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super initWithDictionary:dictionary];

    if (!dictionary[kCompanyNameKey] || !dictionary[kCompanyLogoKey] ||
        !dictionary[kCompanyLogoRetinaKey] || !dictionary[kCompanyWallpapersKey] || !dictionary[kCompanyBaseURL]) {
        return nil;
    }
    if (self = [super init]) {
        self.name = dictionary[kCompanyNameKey];
        NSString* baseURL = dictionary[kCompanyBaseURL];
        self.logoURL = [baseURL stringByAppendingPathComponent:dictionary[kCompanyLogoKey]];
        self.logoRetinaURL = [baseURL stringByAppendingPathComponent:dictionary[kCompanyLogoRetinaKey]];
        NSArray* arr = dictionary[kCompanyWallpapersKey];
        NSMutableArray* wallpapers = [NSMutableArray arrayWithCapacity:arr.count];
        for (NSDictionary* d in arr)
        {
            NSString* imageURL = [baseURL stringByAppendingString:d[kTilingImageURLKey]];
            
            // Tile URL is optional
            NSString *tileURL = @"";
            if ([d objectForKey:kTilingURLKey] != nil)
                tileURL = d[kTilingURLKey];
            
            // Tile size should remain optional for wallpapers
            NSNumber *tileSize = d[kTilingSizeKey];
            if (nil == tileSize || [tileSize integerValue] == 0)
                tileSize = [NSNumber numberWithInt:100];

            TilingDO * wallpaper = [[TilingDO alloc] initWithTitle:d[kTilingTitleKey] imageURL:imageURL tileSize:tileSize tileURL:tileURL];
            if (wallpaper) {
                [wallpapers addObject:wallpaper];
            } else {
                break;
            }
        }
        self.wallpapers = [wallpapers copy];
    }
    return self;
}

- (UIImage*)getLogo {
    if (self.logo) return self.logo;
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
    if (self.wallpapers) {
        [self.wallpapers makeObjectsPerformSelector:@selector(clearCache)];
        
    }
    
}
@end

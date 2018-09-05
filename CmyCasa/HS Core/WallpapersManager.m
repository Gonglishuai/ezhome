//
//  WallpapersManager.m
//  Homestyler
//
//  Created by Or Sharir on 7/2/13.
//
//

#import "WallpapersManager.h"
#import "WallpaperCompanyDO.h"
#import "PackageManager.h"
#import "HSMacros.h"

NSString * const kWallpaperCompaniesKey = @"wallpaper-companies";

@interface WallpapersManager ()
@property (strong, nonatomic, readwrite) NSArray* wallpaperCompanies;
-(instancetype)init;
-(void)loadCompanies;
@end

@implementation WallpapersManager

-(instancetype)init {
    if (self = [super init]) {
        [self loadCompanies];
    }
    return self;
}

-(void)loadCompanies
{
    NSDictionary *config = [[ConfigManager sharedInstance] getMainConfigDict];
    
    RETURN_VOID_ON_NIL(config);
    
    NSArray* wallpaperCompaniesURLs = config[kWallpaperCompaniesKey];
    if (!wallpaperCompaniesURLs) {
        //HSMDebugLogDetailed(@"error: no wallpaper companies key in config");
        return;
    }
    
    NSMutableArray* companies = [NSMutableArray array];
    for (NSString* jsonURL in wallpaperCompaniesURLs)
    {
        NSData* jsonData;
        NSError* err;
        if (![ConfigManager isAnyNetworkAvailable] && [ConfigManager isOfflineModeActive])
        {
            jsonData = [[PackageManager sharedInstance] getFileByURLString:jsonURL];
        }
        else
        {
            jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonURL]];
        }
        
        if (!jsonData)
        {
            //HSMDebugLogDetailed(@"error downloading wallpaper json: %@", [err localizedDescription]);
            continue;
        }
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
        if (!json) {
            //HSMDebugLogDetailed(@"error loading wallpaper json: %@", [err localizedDescription]);
            continue;
        }
        
        WallpaperCompanyDO* company = [[WallpaperCompanyDO alloc] initWithDictionary:json];
        if (!company) {
            //HSMDebugLogDetailed(@"error processing wallpaper json: %@", json);
            continue;
        }
        
        [companies addObject:company];
    }
    self.wallpaperCompanies = [companies copy];
    
}

- (void)clearData
{
    self.wallpaperCompanies = nil;
}

- (NSArray*)wallpaperCompanies {
    if (!_wallpaperCompanies) {
        [self loadCompanies];
    }
    return _wallpaperCompanies;
}
- (void)prefetchWallpapersData {
    [self loadCompanies];
}
+ (WallpapersManager *)sharedInstance {
    static WallpapersManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WallpapersManager alloc] init];
    });
    return sharedInstance;
}


-(void)clearCache{
    if (_wallpaperCompanies) {
        [_wallpaperCompanies makeObjectsPerformSelector:@selector(clearCache)];
    }
}
@end

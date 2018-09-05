//
//  FloortilesManager.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import "FloortilesManager.h"
#import "FloortileCompanyDO.h"
#import "PackageManager.h"

NSString * const kFloortileCompaniesKey = @"floortile-companies";

@interface FloortilesManager ()
@property (strong, nonatomic, readwrite) NSArray* floortileCompanies;
-(instancetype)init;
-(void)loadCompanies;
@end

@implementation FloortilesManager
-(instancetype)init {
    if (self = [super init]) {
        [self loadCompanies];
    }
    return self;
}

-(void)loadCompanies {
    
    NSDictionary* config=[[ConfigManager sharedInstance] getMainConfigDict];
    if (!config) return;
    
    NSArray* floortileCompaniesURLs = config[kFloortileCompaniesKey];
    if (!floortileCompaniesURLs) {
        //HSMDebugLogDetailed(@"error: no floortile companies key in config");
        return;
    }
    
    NSMutableArray* companies = [NSMutableArray array];
    for (NSString* jsonURL in floortileCompaniesURLs) {
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
            ///HSMDebugLogDetailed(@"error downloading wallpaper json: %@", [err localizedDescription]);
            continue;
        }
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
        if (!json) {
           // HSMDebugLogDetailed(@"error loading floortile json: %@", [err localizedDescription]);
            continue;
        }
        
        FloortileCompanyDO* company = [[FloortileCompanyDO alloc] initWithDictionary:json];
        if (!company) {
            //HSMDebugLogDetailed(@"error processing floortile json: %@", json);
            continue;
        }
        
        [companies addObject:company];
    }
    self.floortileCompanies = [companies copy];
    
}

- (void)clearData
{
    self.floortileCompanies = nil;
}

- (NSArray*)floortileCompanies {
    if (!_floortileCompanies) {
        [self loadCompanies];
    }
    return _floortileCompanies;
}
- (void)prefetchFloortilesData {
    [self loadCompanies];
}
+ (FloortilesManager *)sharedInstance {
    static FloortilesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FloortilesManager alloc] init];
    });
    return sharedInstance;
}


-(void)clearCache
{
    if (_floortileCompanies) {
        [_floortileCompanies makeObjectsPerformSelector:@selector(clearCache)];
    }
}

@end

/**
 * @file    MPRegionManager.m
 * @brief   the manager of region query.
 * @author  Jiao
 * @version 1.0
 * @date    2016-03-13
 *
 */

#import "MPRegionManager.h"
#import "FMDB.h"
#import "MPRegionModel.h"

@interface MPRegionManager()

@property (nonatomic, strong) FMDatabase *db;
@end
@implementation MPRegionManager

+ (instancetype)sharedInstance {
    
    static MPRegionManager *dbManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dbManager = [[super allocWithZone:NULL]init];
    });
    
    return dbManager;
}

///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [MPRegionManager sharedInstance];
}

///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [MPRegionManager sharedInstance];
}

- (FMDatabase *)db {
    if (_db == nil) {
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"MPRegion" ofType:@"db"];
        _db = [FMDatabase databaseWithPath:dbPath] ;
    }
    return _db;
}
- (NSArray <MPRegionModel *>*)getRegionWithType:(MPRegionType)type withParentCode:(NSString *)parent_code {
    NSString *regionType = [NSString stringWithFormat:@"%ld",(unsigned long)type];
    NSString * sql;
    if ([parent_code integerValue] <= 1) {
        sql =[NSString stringWithFormat:@"SELECT * FROM %@ WHERE region_type = '%@' and code != 710000 ORDER BY region_type, code ASC",@"RegionList",regionType];
    }else {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE parent_code = '%@' ORDER BY region_type, code ASC",@"RegionList", parent_code];
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc]init];
    if ([self.db open]) {
        FMResultSet * rs = [self.db executeQuery:sql];
        while ([rs next]) {
            NSDictionary *dict = @{@"abbname":[rs stringForColumn:@"abbname"],
                                   @"region_name":[rs stringForColumn:@"region_name"],
                                   @"code":[rs stringForColumn:@"code"],
                                   @"parent_code":[rs stringForColumn:@"parent_code"],
                                   @"region_type":[rs stringForColumn:@"region_type"],
                                   @"zip":[rs stringForColumn:@"zip"]};
            [resultArr addObject:[MPRegionModel getRegionModelWithDict:dict]];
        }
        [self.db close];
    }
    return resultArr;
}

- (NSDictionary *)getRegionWithProvinceCode:(NSString *)province_code
                               withCityCode:(NSString *)city_code
                            andDistrictCode:(NSString *)district_code {
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSString * sql =[NSString stringWithFormat:@"SELECT * FROM %@",@"RegionList"];
    if ([self.db open]) {
        FMResultSet * rs = [self.db executeQuery:sql];
        while ([rs next]) {
            NSString *code = [rs stringForColumn:@"code"];

            NSString *region_name = [rs stringForColumn:@"region_name"];

            if ([code isEqualToString:province_code]) {
                [resultDic setObject:region_name forKey:@"province"];
            }
            
            if ([code isEqualToString:city_code]) {
                [resultDic setObject:region_name forKey:@"city"];
            }
            
            if ([code isEqualToString:district_code]) {
                [resultDic setObject:region_name forKey:@"district"];
            }
        }
        
        if ([resultDic[@"province"] isEqualToString:@"<null>"] || [resultDic[@"province"] isEqualToString:@"(null)"] || resultDic[@"province"] == nil || [resultDic[@"province"] isEqualToString:@""]) {
            
            resultDic[@"province"] = (province_code == nil)?@"":province_code;
        }
        
        if ([resultDic[@"city"] isEqualToString:@"<null>"] || [resultDic[@"city"] isEqualToString:@"(null)"] || resultDic[@"city"] == nil || [resultDic[@"city"] isEqualToString:@""]) {
            resultDic[@"city"] = (city_code == nil)?@"":city_code;
        }
        
        if ([resultDic[@"district"] isEqualToString:@"<null>"] || [resultDic[@"district"] isEqualToString:@"(null)"] || resultDic[@"district"] == nil || [resultDic[@"district"] isEqualToString:@""]) {
            resultDic[@"district"] = (district_code == nil)?@"":district_code;
        }
        
        [self.db close];
    }
    return resultDic;
}
@end

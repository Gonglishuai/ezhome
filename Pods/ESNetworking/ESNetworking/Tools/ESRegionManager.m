//
//  ESRegionManager.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/10.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESRegionManager.h"
#import "ESAddrerssAPI.h"
#import "FMDB.h"

#define ES_ADDRESS_FOLDER @"esaddress"
#define ES_DATABASE @"esshejijia.sqlite"
#define WS(weakSelf)  __weak __block __typeof(&*self)weakSelf = self;

@interface ESRegionManager()
@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) FMDatabaseQueue * dbQueue;
@end
@implementation ESRegionManager

+ (instancetype)sharedInstance {
    static ESRegionManager *s_request = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        s_request = [[super allocWithZone:NULL]init];
    });
    
    return s_request;
}


///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [ESRegionManager sharedInstance];
}


///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [ESRegionManager sharedInstance];
}

- (NSString *)dbPath {
    if (_dbPath == nil) {
        _dbPath = [[ESRegionManager getAddressFolder] stringByAppendingPathComponent: ES_DATABASE];
    }
    return _dbPath;
}

- (FMDatabaseQueue *)dbQueue {
    if (_dbQueue == nil) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    }
    return _dbQueue;
}

+ (void)retrieveNewDistrict {
    ESRegionManager *manager = [ESRegionManager sharedInstance];
    [manager createDBFile];
    
    [ESAddrerssAPI retrieveNewDistrictWithSuccess:^(NSDictionary *content, NSDictionary *responseHeader) {
        NSTimeInterval request = 0;
        if ([responseHeader objectForKey:@"Date"]) {
            NSString *dateStr = [responseHeader objectForKey:@"Date"];
            NSDate *requestDate = [ESRegionManager getLocalDateFromDateStr:dateStr];
            request = [ESRegionManager getTimestamp:requestDate];
        }
        
        
        if (request > 0) {
            [manager updateRegionWithTimestamp:request withBack:^(BOOL shouldUpdate) {
                if (shouldUpdate) {
                    [manager updateDataWithDict:content];
                }
            }];
        }
        
    } andFailure:^(NSError *error) {
        NSLog(@"%ld", (long)error.code);
    }];
}

+ (NSDate *)getLocalDateFromDateStr:(NSString *)dateStr {
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date =[dateFormat dateFromString:dateStr];
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return destinationDateNow;
}

+ (NSTimeInterval)getTimestamp:(NSDate *)date {
    return [date timeIntervalSince1970];
}

- (void)updateDataWithDict:(NSDictionary *)dict {
    if (dict && [dict objectForKey:@"results"] &&
        ![dict isKindOfClass:[NSNull class]] &&
        ![[dict objectForKey:@"results"] isKindOfClass:[NSNull class]]) {
        
        NSArray *results = [dict objectForKey:@"results"];
        NSMutableArray <ESRegionModel *> *models = [NSMutableArray array];
        if (results.count > 0) {
            for (NSDictionary *dic in results) {
                [models addObject:[ESRegionModel objFromDict:dic]];
            }
        }
        
        if (models.count > 0) {
            [self updateDatabaseWithArray:models];
        }
    }
}

#pragma mark - database
- (void)updateDatabaseWithArray:(NSArray <ESRegionModel *>*)array {
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    dispatch_async(q, ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString * sql1 = @"drop table if exists esregion";
            BOOL res1 = [db executeUpdate:sql1];
            if (!res1) {
                NSLog(@"error to delete db data");
            } else {
                NSLog(@"succ to deleta db data");
            }
            
            NSString * sql2 = @"CREATE TABLE IF NOT EXISTS 'esregion' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , 'rid' TEXT, 'name' TEXT, 'parentId' TEXT,  'shortName' TEXT, 'levelType' TEXT, 'cityCode' TEXT, 'zipcode' TEXT, 'pinyin' TEXT);";
            BOOL res2 = [db executeUpdate:sql2];
            if (!res2) {
                NSLog(@"create table failure");
            } else {
                NSLog(@"create table success" );
            }
            
            for (ESRegionModel *model in array) {
                NSString * sql3 = @"insert into esregion (rid, name, parentId, shortName, levelType, cityCode, zipcode, pinyin) values (?, ?, ?, ?, ?, ?, ?, ?);";
                BOOL res3 = [db executeUpdate:sql3, model.rid, model.name, model.parentId, model.shortName, model.levelType, model.cityCode, model.zipcode, model.pinyin];
                if (!res3) {
                    NSLog(@"fail to add db data: %@", model.name);
                    *rollback = YES;
                    return;
                }
            }
        }];
    });
    
}

+ (void)getRegionsWithParentId:(NSString *)parentId
                   withSuccess:(void(^)(NSArray <ESRegionModel *>*))success {
    ESRegionManager *manager = [ESRegionManager sharedInstance];
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    dispatch_async(q, ^{
        [manager.dbQueue inDatabase:^(FMDatabase *db) {
            NSMutableArray *dataArray = [NSMutableArray array];
            
            FMResultSet *res = [db executeQuery:@"SELECT * FROM esregion where parentId = ?", parentId];
            
            while ([res next]) {
                ESRegionModel *region = [[ESRegionModel alloc] init];
                region.rid       = [res stringForColumn:@"rid"];
                region.name      = [res stringForColumn:@"name"];
                region.parentId  = [res stringForColumn:@"parentId"];
                region.shortName = [res stringForColumn:@"shortName"];
                region.levelType = [res stringForColumn:@"levelType"];
                region.cityCode  = [res stringForColumn:@"cityCode"];
                region.zipcode   = [res stringForColumn:@"zipcode"];
                region.pinyin    = [res stringForColumn:@"pinyin"];
                
                [dataArray addObject:region];
            }
            
            if (success) {
                success(dataArray);
            }
        }];
    });
}

+ (void)getRegionWithId:(NSString *)regionId withSuccess:(void(^)(ESRegionModel *region))success{
    if (!regionId) {
        if (success) {
            success(nil);
        }
    }
    ESRegionManager *manager = [ESRegionManager sharedInstance];
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    dispatch_async(q, ^{
        [manager.dbQueue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *res = [db executeQuery:@"SELECT * FROM esregion where rid = ?", regionId];
            ESRegionModel *region = [[ESRegionModel alloc] init];
            
            while ([res next]) {
                region.rid       = [res stringForColumn:@"rid"];
                region.name      = [res stringForColumn:@"name"];
                region.parentId  = [res stringForColumn:@"parentId"];
                region.shortName = [res stringForColumn:@"shortName"];
                region.levelType = [res stringForColumn:@"levelType"];
                region.cityCode  = [res stringForColumn:@"cityCode"];
                region.zipcode   = [res stringForColumn:@"zipcode"];
                region.pinyin    = [res stringForColumn:@"pinyin"];
                
            }
            
            if (success) {
                success(region);
            }
        }];
    });
}

+ (void)getRegionWithCityName:(NSString *)cityName
                  withSuccess:(void(^)(ESRegionModel *region))success {
    if (!cityName) {
        if (success) {
            success(nil);
        }
    }
    ESRegionManager *manager = [ESRegionManager sharedInstance];
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    dispatch_async(q, ^{
        [manager.dbQueue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *res = [db executeQuery:@"SELECT * FROM esregion where name = ?", cityName];
            ESRegionModel *region = [[ESRegionModel alloc] init];
            
            while ([res next]) {
                region.rid       = [res stringForColumn:@"rid"];
                region.name      = [res stringForColumn:@"name"];
                region.parentId  = [res stringForColumn:@"parentId"];
                region.shortName = [res stringForColumn:@"shortName"];
                region.levelType = [res stringForColumn:@"levelType"];
                region.cityCode  = [res stringForColumn:@"cityCode"];
                region.zipcode   = [res stringForColumn:@"zipcode"];
                region.pinyin    = [res stringForColumn:@"pinyin"];
                
            }
            
            if (success) {
                if (region.rid) {
                    success(region);
                }else {
                    success(nil);
                }
            }
        }];
    });
}

+ (void)getRegionInfoWithCityName:(NSString *)cityName
                 withDistrictCode:(NSString *)districtCode
                      withSuccess:(void(^)(ESRegionModel *province, ESRegionModel *city, ESRegionModel *district))success {
    if (!cityName) {
        if (success) {
            success(nil, nil, nil);
        }
    }
    ESRegionManager *manager = [ESRegionManager sharedInstance];
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    dispatch_async(q, ^{
        [manager.dbQueue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *res1 = [db executeQuery:@"SELECT * FROM esregion where name = ?", cityName];
            ESRegionModel *city = nil;
            
            while ([res1 next]) {
                if (city == nil) {
                    city = [[ESRegionModel alloc] init];
                }
                city.rid       = [res1 stringForColumn:@"rid"];
                city.name      = [res1 stringForColumn:@"name"];
                city.parentId  = [res1 stringForColumn:@"parentId"];
                city.shortName = [res1 stringForColumn:@"shortName"];
                city.levelType = [res1 stringForColumn:@"levelType"];
                city.cityCode  = [res1 stringForColumn:@"cityCode"];
                city.zipcode   = [res1 stringForColumn:@"zipcode"];
                city.pinyin    = [res1 stringForColumn:@"pinyin"];
                
            }
            
            ESRegionModel *province = nil;
            if (city && city.parentId) {
                FMResultSet *res2 = [db executeQuery:@"SELECT * FROM esregion where rid = ?", city.parentId];
                
                while ([res2 next]) {
                    if (province == nil) {
                        province = [[ESRegionModel alloc] init];
                    }
                    province.rid       = [res2 stringForColumn:@"rid"];
                    province.name      = [res2 stringForColumn:@"name"];
                    province.parentId  = [res2 stringForColumn:@"parentId"];
                    province.shortName = [res2 stringForColumn:@"shortName"];
                    province.levelType = [res2 stringForColumn:@"levelType"];
                    province.cityCode  = [res2 stringForColumn:@"cityCode"];
                    province.zipcode   = [res2 stringForColumn:@"zipcode"];
                    province.pinyin    = [res2 stringForColumn:@"pinyin"];
                    
                }
            }
            
            ESRegionModel *district = nil;
            if (city && city.rid && districtCode) {
                FMResultSet *res3 = [db executeQuery:@"SELECT * FROM esregion where parentId = ? and rid = ?", city.rid, districtCode];
                
                while ([res3 next]) {
                    if (district == nil) {
                        district = [[ESRegionModel alloc] init];
                    }
                    district.rid       = [res3 stringForColumn:@"rid"];
                    district.name      = [res3 stringForColumn:@"name"];
                    district.parentId  = [res3 stringForColumn:@"parentId"];
                    district.shortName = [res3 stringForColumn:@"shortName"];
                    district.levelType = [res3 stringForColumn:@"levelType"];
                    district.cityCode  = [res3 stringForColumn:@"cityCode"];
                    district.zipcode   = [res3 stringForColumn:@"zipcode"];
                    district.pinyin    = [res3 stringForColumn:@"pinyin"];
                }
            }
            
            if (success) {
                success(province, city, district);
            }
        }];
    });
}
#pragma mark - Directory
- (BOOL) createDBFile {
    
    NSString *folderPath = [ESRegionManager getAddressFolder];
    return ([ESRegionManager createFile:[folderPath stringByAppendingPathComponent:ES_DATABASE]]);
}

+ (BOOL) createFile:(NSString *)filePath {
    BOOL bSuccess = NO;
    if (filePath) {
        if (![ESRegionManager isFileExist:filePath]) {
            NSString *folder = [ESRegionManager getAddressFolder];
            if (![ESRegionManager isDirectoryExist:folder]) {
                [ESRegionManager createFolder:folder];
            }
            NSError *err = nil;
            
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *backupDbPath = [[NSBundle mainBundle]
                                      pathForResource:@"esshejijia"
                                      ofType:@"sqlite"];
            
            bSuccess = [fm copyItemAtPath:backupDbPath toPath:filePath error:&err];
            NSLog(@"cp = %d",bSuccess);
            NSLog(@"backupDbPath =%@",backupDbPath);
            if (err) {
                NSLog(@"%@", err.description);
            }
        }else {
            bSuccess = YES;
        }
    }
    
    return bSuccess;
}

+ (BOOL) isFileExist:(NSString *)filePath{
    if (filePath) {
        BOOL bExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        
        return bExists;
    }
    return NO;
}

+ (NSString *) getAddressFolder {
    NSString *docDir = [NSString stringWithFormat:@"%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    NSString *folder = [docDir stringByAppendingPathComponent:ES_ADDRESS_FOLDER];
    return folder;
}

+ (void)createFolder:(NSString *)folderPath {
    BOOL bSuccess = NO;
    NSError *err = nil;
    bSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:&err];
    if (!bSuccess) {
        NSLog(@"%@", err.localizedFailureReason);
    }
    
}

+ (BOOL)isDirectoryExist:(NSString *)filePath {
    if (filePath) {
        BOOL bStatus = NO;
        BOOL bExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&bStatus];
        if (bExists) {
            return bStatus;
        }
    }
    return NO;
}

#pragma mark - update Data
- (void)updateRegionWithTimestamp:(NSTimeInterval)timestamp
                         withBack:(void(^)(BOOL shouldUpdate))back {
    WS(weakSelf);
    dispatch_queue_t q2 = dispatch_queue_create("queue12", NULL);
    dispatch_async(q2, ^{
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            [weakSelf initUpdateTable:db];
            FMResultSet *res = [db executeQuery:@"SELECT * FROM updatetimestamp where name = ?", @"region"];
            NSString *name = nil;
            NSString *timeStr = nil;
            while ([res next]) {
                name       = [res stringForColumn:@"name"];
                timeStr    = [res stringForColumn:@"timestamp"];
            }
            
            if (name == nil) {
                NSString *name = @"region";
                NSString *times = [NSString stringWithFormat:@"%f", timestamp];
                NSString *description = @"更新行政区服务地址";
                [weakSelf insertDataWithName:name withTimestamp:times withDescription:description withDatabase:db];
                if (back) {
                    back(YES);
                }
            }else if (timeStr) {
                NSTimeInterval time = [timeStr doubleValue];
                if (time == timestamp) {
                    if (back) {
                        back(NO);
                    }
                }else {
                    NSString *name = @"region";
                    NSString *times = [NSString stringWithFormat:@"%f", timestamp];
                    NSString *description = @"更新行政区服务地址";
                    [weakSelf updateDataWithName:name withTimestamp:times withDescription:description withDatabase:db];
                    if (back) {
                        back(YES);
                    }
                }
            }
            
        }];
    });
}

- (void)insertDataWithName:(NSString *)name
             withTimestamp:(NSString *)timestamp
           withDescription:(NSString *)description
              withDatabase:(FMDatabase *)db {
    NSString * sql = @"insert into updatetimestamp (name, timestamp, description) values (?, ?, ?);";
    BOOL res = [db executeUpdate:sql, name, timestamp, description];
    if (!res) {
        NSLog(@"fail to insert updateTimestamp data: %@", timestamp);
    }
}

- (void)updateDataWithName:(NSString *)name
             withTimestamp:(NSString *)timestamp
           withDescription:(NSString *)description
              withDatabase:(FMDatabase *)db {
    NSString * sql = @"UPDATE updatetimestamp SET timestamp = ?, description = ? WHERE name = ?;";
    BOOL res = [db executeUpdate:sql, timestamp, description, name];
    if (!res) {
        NSLog(@"fail to update updateTimestamp data: %@", timestamp);
    }
}

#pragma mark - public
- (void)initUpdateTable:(FMDatabase *)db {
    NSString * sql = @"CREATE TABLE IF NOT EXISTS 'updatetimestamp' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , 'name' TEXT, 'timestamp' TEXT, 'description' TEXT);";
    NSError *error = nil;
    [db executeUpdate:sql values:nil error:&error];
    if (error) {
        NSLog(@"%@",error.description);
    }
    BOOL res = [db executeUpdate:sql];
    if (!res) {
        NSLog(@"create updateTimestamp failure");
    } else {
        NSLog(@"create updateTimestamp success" );
    }
}
@end


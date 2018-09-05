//
//  FloortilesManager.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kFloortileCompaniesKey;

@interface FloortilesManager : NSObject
@property (strong, nonatomic, readonly) NSArray* floortileCompanies;
+ (FloortilesManager *)sharedInstance;
- (void)prefetchFloortilesData;
- (void)clearCache;
- (void)clearData;
@end

//
//  WallpapersManager.h
//  Homestyler
//
//  Created by Or Sharir on 7/2/13.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kWallpaperCompaniesKey;

@interface WallpapersManager : NSObject
@property (strong, nonatomic, readonly) NSArray* wallpaperCompanies;
+ (WallpapersManager *)sharedInstance;
- (void)prefetchWallpapersData;
- (void)clearCache;
- (void)clearData;
@end

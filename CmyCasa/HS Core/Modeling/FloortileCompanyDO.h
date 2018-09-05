//
//  FloortileCompanyDO.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import <Foundation/Foundation.h>
#import "WallpaperCompanyDO.h"

extern NSString * const kFloorCompanyNameKey;
extern NSString * const kFloorCompanyLogoKey;
extern NSString * const kFloorCompanyLogoRetinaKey;
extern NSString * const kFloorCompanyFloortilesKey;
extern NSString * const kFloorCompanyBaseURL;

@interface FloortileCompanyDO : CompanyBaseDO
@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* logoURL;
@property (strong, nonatomic, readonly) NSString* logoRetinaURL;
@property (strong, nonatomic, readonly) NSArray* floortiles;
@property (atomic, readonly) BOOL isImageDataAvailable;


- (instancetype)initWithImages:(NSArray*)imagesURL;
- (UIImage*)getLogo;
- (void)loadLogoURLInBackground:(void (^)(UIImage* logo))block;

-(void)clearCache;
@end

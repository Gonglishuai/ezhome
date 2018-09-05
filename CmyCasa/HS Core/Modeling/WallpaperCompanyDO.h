//
//  WallpaperCompanyDO.h
//  Homestyler
//
//  Created by Or Sharir on 7/2/13.
//
//

#import <Foundation/Foundation.h>
#import "CompanyBaseDO.h"




@interface WallpaperCompanyDO : CompanyBaseDO
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* logoURL;
@property (strong, nonatomic) NSString* logoRetinaURL;
@property (strong, nonatomic) NSArray* wallpapers;
@property (strong, nonatomic) UIImage *logo;


- (UIImage*)getLogo;
- (void)loadLogoURLInBackground:(void (^)(UIImage* logo))block;
- (void)clearCache;
@end

//
//  TilingDO.h
//  Homestyler
//
//  Created by Or Sharir on 7/2/13.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kTilingTitleKey;
extern NSString * const kTilingImageURLKey;
extern NSString * const kTilingSizeKey;
extern NSString * const kTilingURLKey;
extern NSString * const kTilingPropertiesKey;
extern NSString * const kTilingThumbKey;

@interface TilingDO : NSObject
@property (strong, nonatomic, readonly) NSString        *title;
@property (strong, nonatomic, readonly) NSString        *imageURL;
@property (strong, nonatomic, readonly) NSString        *tileURL;
@property (strong, nonatomic, readonly) NSNumber        *tileSize;
@property (atomic, readonly) BOOL                       isImageDataAvailable;
@property (strong, nonatomic) UIImage                   *image;
@property (strong, nonatomic) UIImage                   *thumbImage;
@property (strong, nonatomic) NSArray                   *tilingProperties;
@property (strong, nonatomic, readwrite) NSString       *thumbURL;


-(instancetype)initWithTitle:(NSString*)title imageURL:(NSString*)imageURL tileSize:(NSNumber*)tileSize  tileURL:(NSString*)tileURL;
-(UIImage*)getImage;
-(void)loadImageInBackground:(void (^)(UIImage* image))block;
-(void)loadThumbnailInBackground:(void (^)(UIImage* image))block;

-(void)clearCache;
@end

//
//  UIImage+UIImage_EXIF.h
//  Homestyler
//
//  Created by Berenson Sergei on 3/2/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (EXIF)

+ (NSDictionary*)loadExifMetaData:( NSData *)data;
+ (NSDictionary*)imageMetadataWithAssetURL:(NSURL*)url;
+ (NSNumber*)focalLengthIn35mmFilmFromMetadata:(NSDictionary*)metadata;

@end

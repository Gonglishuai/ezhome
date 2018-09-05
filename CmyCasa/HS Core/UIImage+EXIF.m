//
//  UIImage+UIImage_EXIF.m
//  Homestyler
//
//  Created by Berenson Sergei on 3/2/14.
//
//

#import "UIImage+EXIF.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

enum
{
    WDASSETURL_PENDINGREADS = 1,
    WDASSETURL_ALLFINISHED = 0
};

@implementation UIImage (EXIF)


+ (NSDictionary*)loadExifMetaData:(NSData*)data
{
    if(!data)
        return nil;
    
    @autoreleasepool {
        CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        CFDictionaryRef metadataRef =  CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
        NSDictionary *exifDic;
        if (metadataRef) {
            NSDictionary *myMetadata = (__bridge_transfer NSDictionary *)metadataRef;
            exifDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
        }
        if (mySourceRef) {
            CFRelease(mySourceRef); 
        }
        
        return exifDic;
    }
    
}

+(NSDictionary*)imageMetadataWithAssetURL:(NSURL*)url {
    __block NSDictionary* metadata = nil;
    // sets up a condition lock with "pending reads"
    __block NSConditionLock* albumReadLock = [[NSConditionLock alloc] initWithCondition:WDASSETURL_PENDINGREADS];
    // the call to the asset library can't be made from the main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:url resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            metadata = [representation metadata];
            [albumReadLock lock];
            [albumReadLock unlockWithCondition:WDASSETURL_ALLFINISHED];
        } failureBlock:^(NSError *error) {
            [albumReadLock lock];
            [albumReadLock unlockWithCondition:WDASSETURL_ALLFINISHED];
        }];
    });
    // wait for the tasks to finish
    [albumReadLock lockWhenCondition:WDASSETURL_ALLFINISHED];
    [albumReadLock unlock];
    
    return metadata;
}

+(NSNumber*)focalLengthIn35mmFilmFromMetadata:(NSDictionary*)metadata {
    if (metadata) {
        NSNumber* focalLength;
        NSDictionary* exif = [metadata objectForKey:(NSString*)kCGImagePropertyExifDictionary];
        if (exif) {
            focalLength = [exif objectForKey:(NSString*)kCGImagePropertyExifFocalLenIn35mmFilm];
            if (focalLength == nil) {
                NSArray* possibleKeys = [[exif allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if ([(NSString*)evaluatedObject rangeOfString:@"35mm"].location != NSNotFound) {
                        return YES;
                    }
                    return NO;
                }]];
                if (possibleKeys.count > 0) {
                    if (possibleKeys.count > 1) HSMDebugLog(@"35mm keys: %@", possibleKeys);
                    focalLength = [exif objectForKey:[possibleKeys objectAtIndex:0]];
                }
            }
        }
        return focalLength;
    }
    return nil;
}


@end

//
//  ImageFetcher.m
//  Homestyler
//
//  Created by Ma'ayan on 1/12/14.
//
//

#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#import "ImageFetcher.h"
#import "FileFactoryGenerator.h"
#import "NSString+ImageResizer.h"
#import "SDWebImageDownloaderNew.h"
#import "MD5Categories.h"
#import "SDImageCacheNew.h"
#import "UIImage+Exif.h"
#import "PackageManager.h"

#define IMAGE_FETCHER_UID_ASSOCIATION_KEY             @"img_fetcher_ass_key"
#define IMAGE_FETCHER_SIZE_SCALE                      [[UIScreen mainScreen] scale] //1

@interface ImageFetcher ()
{
    FileFactoryGenerator *fileGenerator;
    
    //the uid for the connection operations
    volatile int32_t uidCounter;
}

@end

@implementation ImageFetcher

#pragma mark - Init

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    static ImageFetcher *sharedImageFetcher = nil;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedImageFetcher = [[ImageFetcher alloc] init];
                      [[SDWebImageDownloaderNew sharedDownloader] setMaxConcurrentDownloads:50];
                      [[SDWebImageDownloaderNew sharedDownloader] setExecutionOrder:SDWebImageDownloaderLIFOExecutionOrder];
                  });
    
    return sharedImageFetcher;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        fileGenerator = [[FileFactoryGenerator alloc] init];
        uidCounter = 0;
    }
    return self;
}

#pragma mark - UID

- (NSInteger)getNewUID
{
    if (OSAtomicIncrement32(&uidCounter) > 0)
    {
        return uidCounter;
    }
    
    return -1;
}

- (void)setAssociatedUid:(NSInteger)uid forObject:(NSObject *)obj
{
    if (obj != nil)
    {
        NSNumber *number = [NSNumber numberWithInteger:uid];
        objc_setAssociatedObject(obj, IMAGE_FETCHER_UID_ASSOCIATION_KEY, number, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSInteger)getAssociatedUidFromObject:(NSObject *)obj
{
    NSInteger val = -1;
    
    if (obj != nil)
    {
        NSNumber *number = objc_getAssociatedObject(obj, IMAGE_FETCHER_UID_ASSOCIATION_KEY);
        if (number != nil)
        {
            val = [number integerValue];
        }
    }
    
    return val;
}

#pragma mark - Image Fetch


/* The image fetching process generally works as follows:
 try fetching the image from the local cache, if fail ->
 try loading the image from the disk, if fail ->
 try downloading the image from the cloud cache, if fail ->
 try using the servers’ resizer in order to create the image you want, if fail ->
 try downloading the original image from the server with its’ original size, if fail ->
 image fetching had failed and return ‘nil’.
*/
- (NSInteger)fetchImagewithInfo:(NSDictionary *)info andCompletionBlock:(ImageFetchResultBlock)completion
{
    //we use this key to later identify that spesific request
    NSInteger uid = [self getNewUID];
    
    NSObject *associatedObject = [info objectForKey:IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT];
    
    if (associatedObject != nil)
    {
        [self setAssociatedUid:uid forObject:associatedObject];
    }
    
    if ([ConfigManager isOfflineModeActive] && ![ConfigManager isAnyNetworkAvailable])
    {
        NSData *data = [[PackageManager sharedInstance] getFileByURLString:[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]];
        
        if (!data)
        {
            completion(nil, uid,nil);
        }
        
        UIImage *image = [UIImage imageWithData:data];
        completion(image, uid, nil);
        return uid;
    }
    
    if (![self validateUserInfo:info])
    {
        if (completion != nil)
        {
            if ([info objectForKey:IMAGE_FETCHER_INFO_KEY_DEFAULT_IMAGE_URL] != nil) // If a default image is given return it
            {
                completion([info objectForKey:IMAGE_FETCHER_INFO_KEY_DEFAULT_IMAGE_URL], uid,nil);
            }
            else
            {
                completion(nil, uid,nil);
            }
        }
    }
    else
    {
        //HSMDebugLog(@"Start Image Fetch: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
        
        [self fetchImageFromLocalUrlWithInfo:info andCompletionBlock:^ (UIImage *img,NSDictionary * imageMeta)
         {
             //HSMDebugLog(@"fetchImageFromLocalUrlWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
             
             if (img != nil) //success
             {
                 if (imageMeta) {
                     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:imageMeta];
                     dict[@"isCache"] = @(YES);
                     imageMeta = dict;
                 } else {
                     imageMeta = @{@"isCache":@(YES)};
                 }
                 if (completion != nil)
                 {
                     completion(img, uid,imageMeta);
                 }
             }
             else //failure
             {
                 [self fetchImageFromExternalUrlWithInfo:info andCompletionBlock:^ (UIImage *img, NSData *data, NSDictionary *headers)
                  {
                      //HSMDebugLog(@"fetchImageFromExternalUrlWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
                      
                      if (img != nil) //success
                      {
                          [self storeImage:img withData:data andUrlInfo:info];
                          
                          if (completion != nil)
                          {
                              completion(img, uid,[UIImage loadExifMetaData:data]);
                          }
                      }
                      else //failure
                      {
                          if (completion != nil)
                          {
                              if ([info objectForKey:IMAGE_FETCHER_INFO_KEY_DEFAULT_IMAGE_URL] != nil) // If a default image is given return it
                              {
                                  completion([info objectForKey:IMAGE_FETCHER_INFO_KEY_DEFAULT_IMAGE_URL], uid,nil);
                              }
                              else
                              {
                                  completion(nil, uid,nil);
                              }
                          }
                      }
                  }];
             }
         }];
    }
    
    
    return uid;
}

- (void)fetchImageFromLocalUrlWithInfo:(NSDictionary *)info andCompletionBlock:(ImageFetchInnerResultBlock)completion
{

    NSString *finalPath = [self getLocalPathForImageInfo:info];
    BOOL shouldLoadExif = ([info objectForKey:IMAGE_FETCHER_INFO_KEY_LOAD_IMAGE_EXIF] != nil);
    
    NSDictionary *dicExif = nil;
    UIImage *img = nil;
    
    if (shouldLoadExif)
    {
        NSData *data = [[SDImageCacheNew sharedImageCache] diskImageDataBySearchingAllPathsForKey:finalPath];
        if (data) {
            dicExif = [UIImage loadExifMetaData:data];
            img = [UIImage imageWithData:data];
        }
    }
    else {
        //this checks the mem cache first and only after - the disk..
        img = [[SDImageCacheNew sharedImageCache] imageFromDiskCacheForKey:finalPath];
    }

    completion(img, dicExif);
}
- (void)fetchImageFromLocalUrlWithInfoAsync:(NSDictionary *)info andCompletionBlock:(ImageFetchInnerResultBlock)completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
 
                       [self fetchImageFromLocalUrlWithInfo:info andCompletionBlock:completion];
                       
                   });
}
- (void)fetchImageFromExternalUrlWithInfo:(NSDictionary *)info andCompletionBlock:(ImageDownloadResultBlock)completion
{
    //exclude images that dont need resizing at all
    if (![self isNeedResizingDefinedForInfo:info])
    {
        //cloud
        [self fetchImageFromCloudCacheWithInfo:info andCompletionBlock:^(UIImage *image, NSData *data, NSDictionary *headers)
         {
             //HSMDebugLog(@"fetchImageFromCloudCacheWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
             if (image != nil)
             {
                 if (completion != nil)
                 {
                     completion(image, data, headers);
                 }
             }
             else
             {
                 //original
                 [self fetchImageFromOriginalUrlWithInfo:info andCompletionBlock:^(UIImage *image, NSData *data, NSDictionary *headers)
                  {
                      //HSMDebugLog(@"fetchImageFromOriginalUrlWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
                      if (image != nil)
                      {
                          if (completion != nil)
                          {
                              completion(image, data, headers);
                          }
                      }
                      else //FAIL
                      {
                          if (completion != nil)
                          {
                              completion(nil, nil, nil);
                          }
                      }
                  }];
             }
         }];
    }
    else
    {
        [self fetchImageFromResizerWithInfo:info andCompletionBlock:^(UIImage *image, NSData *data, NSDictionary *headers)
         {
             //HSMDebugLog(@"fetchImageFromResizerWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
             //calc checksum for resizer
             BOOL isValidChecksum = NO;
             
             if (data != nil)
             {
                 NSString *checksum = [headers valueForKey:@"checksum"];
                 
                 if ((checksum == nil) || ([checksum length] == 0))
                 {
                     checksum = [headers valueForKey:@"ETag"];
                 }
                 
                 if (checksum != nil)
                 {
                     isValidChecksum = [self verifyChecksum:checksum forData:data withUrlInfo:info];
                 }
             }
             
             if ((image != nil) && (isValidChecksum == YES))
             {
                 if (completion != nil)
                 {
                     completion(image, data, headers);
                 }
             }
             else //original
             {
                 
                 //cloud
                 [self fetchImageFromCloudCacheWithInfo:info andCompletionBlock:^(UIImage *image, NSData *data, NSDictionary *headers)
                  {
                      //HSMDebugLog(@"fetchImageFromCloudCacheWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
                      if (image != nil)
                      {
                          if (completion != nil)
                          {
                              completion(image, data, headers);
                          }
                      }
                      else
                      {
                          //original
                          [self fetchImageFromOriginalUrlWithInfo:info andCompletionBlock:^(UIImage *image, NSData *data, NSDictionary *headers)
                           {
                               //HSMDebugLog(@"fetchImageFromOriginalUrlWithInfo ENDED: %@, url:%@",[NSDate date],([info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL])?[info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL]:@"");
                               if (image != nil)
                               {
                                   if (completion != nil)
                                   {
                                       completion(image, data, headers);
                                   }
                               }
                               else //FAIL
                               {
                                   if (completion != nil)
                                   {
                                       completion(nil, nil, nil);
                                   }
                               }
                           }];
                      }
                  }];
             }
         }];
    }
}


- (void)fetchImageFromCloudCacheWithInfo:(NSDictionary *)info andCompletionBlock:(ImageDownloadResultBlock)completion
{
    NSString *strExtUrl = [info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL];
    NSValue *valSize = [info objectForKey:IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE];
    BOOL cloudResizeNeeded = [self isNeedResizingDefinedForInfo:info];
    BOOL isValidServerUrl = [fileGenerator isValidServerUrl:strExtUrl];
    CGSize size = [valSize CGSizeValue];
    size.width *= IMAGE_FETCHER_SIZE_SCALE;
    size.height *= IMAGE_FETCHER_SIZE_SCALE;
    NSString *strCloud;
    
    if (isValidServerUrl)
    {
        if (!cloudResizeNeeded)
        {
            strCloud = [fileGenerator createCloudURLWithoutResizing:strExtUrl];
        }
        else
        {
//            strCloud = [fileGenerator createCloudURL:strExtUrl withSize:size smartfit:[self isNeedSmartfitDefinedForInfo:info]];
            
            // resize needed should go to anothor api
            HSMDebugLog(@"Fetch resized image with wrong function!");
        }
    }
    
    //could cache path example for "smartfit": https://hsm-prod-designs.s3.amazonaws.com/uwM25u0Iw4/resized/f_w150_h150_smartfit.jpg
    
    [SDWebImageDownloaderNew.sharedDownloader downloadImageWithURL:[NSURL URLWithString:strCloud] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished, NSDictionary *headers)
    {
        if (image && finished)
        {
            if (completion != nil)
            {
                completion(image, data, headers);
            }
        }
        else
        {
            if (completion != nil)
            {
                completion(nil, nil, nil);
            }
        }
    }];
}

- (void)fetchImageFromResizerWithInfo:(NSDictionary *)info andCompletionBlock:(ImageDownloadResultBlock)completion
{
    NSString *strExtUrl = [info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL];
    NSValue *valSize = [info objectForKey:IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE];
    CGSize size = [valSize CGSizeValue];
    size.width *= IMAGE_FETCHER_SIZE_SCALE;
    size.height *= IMAGE_FETCHER_SIZE_SCALE;
    NSString *strResizer = [strExtUrl generateImageURLforWidth:size.width andHight:size.height];
    
    if ([self isNeedSmartfitDefinedForInfo:info])
    {
        strResizer = [strResizer addSmartfitSuffix];
    }
    
    [SDWebImageDownloaderNew.sharedDownloader downloadImageWithURL:[NSURL URLWithString:strResizer] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished, NSDictionary *headers)
    {
        if (image && finished)
        {
            if (completion != nil)
            {
                completion(image, data, headers);
            }
        }
        else
        {
            if (completion != nil)
            {
                completion(nil, nil, nil);
            }
        }
    }];
}

- (void)fetchImageFromOriginalUrlWithInfo:(NSDictionary *)info andCompletionBlock:(ImageDownloadResultBlock)completion
{
    NSString *strExtUrl = [info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL];

    [SDWebImageDownloaderNew.sharedDownloader downloadImageWithURL:[NSURL URLWithString:strExtUrl] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished, NSDictionary *headers)
    {
        if (image && finished)
        {
            if (completion != nil)
            {
                completion(image, data, headers);
            }
        }
        else
        {
            if (completion != nil)
            {
                completion(nil, nil, nil);
            }
        }
    }];
}

#pragma mark - Image Store

- (void)storeImage:(UIImage *)image withData:(NSData *)data andUrlInfo:(NSDictionary *)info
{
    NSString *finalPath = [self getLocalPathForImageInfo:info];
    
    /* filepath for a facebook image: DesignStream/https://graph.facebook_62_62.com/100001030441561/picture
     which can cause the file manager to create multiple folders.. */
    
    //Save image
    SDImageCacheNew *imageCache = [SDImageCacheNew sharedImageCache];
    [imageCache storeImage:image recalculateFromImage:NO imageData:data forKey:finalPath toDisk:YES];
}

- (NSString *)getLocalPathForImageInfo:(NSDictionary *)info
{
    NSString *path = [info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL];
    NSValue *valSize = [info objectForKey:IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE];
    CGSize size = [valSize CGSizeValue];
    size.width *= IMAGE_FETCHER_SIZE_SCALE;
    size.height *= IMAGE_FETCHER_SIZE_SCALE;
    NSString *localPrefix = [info objectForKey:IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE];
    NSString *finalPath = [NSString stringWithFormat:@"%@/%@", localPrefix, [fileGenerator getLocalFilePathFromURL:path withImageSize:size]];
    
    if ([self isNeedSmartfitDefinedForInfo:info])
    {
        finalPath = [self getPathByAddingSmartfitFromPath:finalPath];
    }
    
    return finalPath;
}

- (void)setMemoryCachingEnabled:(BOOL)isEnabled {
    
    [[SDImageCacheNew sharedImageCache]setMemoryCachingEnabled:isEnabled];
}

#pragma mark - Logic Helpers

- (BOOL)verifyChecksum:(NSString *)strChecksum forData:(NSData *)data withUrlInfo:(NSDictionary *)info
{
    //Verify checksum
    NSString *path = [info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL];
    BOOL bChecksum = NO;
    
    if (data == nil)
    {
        return NO;
    }
    
    if(strChecksum && [strChecksum length] > 0)
    {
        strChecksum = [strChecksum stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        bChecksum = [data checkMD5:strChecksum];
    }
    
    if (strChecksum == nil || [strChecksum length] == 0)
    {
        bChecksum = YES;
    }
    
    
    if (([self isJPEG:path] && [ConfigManager isJPGImageValid:data] == NO) || ([self isPNG:path] && [ConfigManager isPNGImageValid:data] == NO) || bChecksum == NO)
    {
        //int delay = [[ConfigManager sharedInstance] delayBetweenRetries];
        
        return NO;
    }
    
    return YES;
}

/* . Another key function is ‘- (BOOL)validateUserInfo:(NSDictionary *)info’ which we use in order to make sure we have all the info we need before starting the process of image fetching.
 */
- (BOOL)validateUserInfo:(NSDictionary *)info
{
    NSString *path = [info objectForKey:IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL];
    NSValue *valSize = [info objectForKey:IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE];
    BOOL resizeNeeded = [self isNeedResizingDefinedForInfo:info];
    CGSize size = [valSize CGSizeValue];
    size.width *= IMAGE_FETCHER_SIZE_SCALE;
    size.height *= IMAGE_FETCHER_SIZE_SCALE;
    NSString *localFolder = [info objectForKey:IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE];

    if ((path == nil) || ([path rangeOfString:@"."].location == NSNotFound) || ([path componentsSeparatedByString:@"/"].count < 2))
    {
        return NO;
    }
    //If size is Zero no resizing will be applied if resizeneeded is not null
    if (CGSizeEqualToSize(size, CGSizeZero) && resizeNeeded == YES)
    {
        return NO;
    }
    
    if (localFolder == nil)
    {
        return NO;
    }

    return YES;
}

- (BOOL)isJPEG:(NSString *)path
{
    return [path hasSuffix:@".jpg"];
}

- (BOOL)isPNG:(NSString *)path
{
    return [path hasSuffix:@".png"];
}

- (BOOL)isNeedResizingDefinedForInfo:(NSDictionary *)info
{
    return !([info objectForKey:IMAGE_FETCHER_INFO_KEY_URL_FORMATING] && [[info objectForKey:IMAGE_FETCHER_INFO_KEY_URL_FORMATING] isEqualToString:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING]);
}
        
- (BOOL)isNeedSmartfitDefinedForInfo:(NSDictionary *)info
{
    //BOOL b1 = ([info objectForKey:IMAGE_FETCHER_INFO_KEY_SMARTFIT] != nil);
    //BOOL b2 = ([[info objectForKey:IMAGE_FETCHER_INFO_KEY_SMARTFIT] boolValue] == YES);
    
    return (([info objectForKey:IMAGE_FETCHER_INFO_KEY_SMARTFIT] != nil) && ([[info objectForKey:IMAGE_FETCHER_INFO_KEY_SMARTFIT] boolValue] == YES));
}

- (NSString *)getPathByAddingSmartfitFromPath:(NSString *)path
{
    return [NSString stringWithFormat:@"%@%@", path, @"_smartfit"];
}


@end

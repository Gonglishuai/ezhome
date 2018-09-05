//
//  ImageFetcher.h
//  Homestyler
//
//  Created by Ma'ayan on 1/12/14.
//
//

/* ImageFetcher is a new manager designed to unify the process of downloading images from the server or fetching them from the local cache or disk,  as well as saving the images to their correct folders using smart filenames. */

#import <Foundation/Foundation.h>

/* Required */
#define IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL                 @"ext_url" //the external url from which to download the image
#define IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE           @"val_size" //the desired size of the image
#define IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE            @"loc_folder" //the local folder in which to save the image after it had been downloaded
/* Optional */
#define IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT            @"ass_object" //the object that is destined to use the image
#define IMAGE_FETCHER_INFO_KEY_URL_FORMATING                @"url_format"
#define IMAGE_FETCHER_INFO_KEY_DEFAULT_IMAGE_URL            @"default_image_url"
#define IMAGE_FETCHER_INFO_KEY_SMARTFIT                     @"url_use_smartfit" //insert an '[NSNumber numberWithBool:YES]' in this key in order to force the server to use smartfit algorithm
#define IMAGE_FETCHER_INFO_KEY_LOAD_IMAGE_EXIF              @"loadExif" //assign this key with any value if you with to load the image exif metada along with the image

/*Local Folder Types*/
#define IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS              @"Models"
#define IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM       @"DesignStream"
/*IMAGE_FETCHER_INFO_KEY_URL_FORMATING Values*/
#define IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING    @"url_without_resize"



typedef void(^ImageFetchResultBlock)(UIImage *img, NSInteger imgUid, NSDictionary* imageMeta);
typedef void(^ImageFetchInnerResultBlock)(UIImage *img, NSDictionary* imageMeta);
typedef void(^ImageDownloadResultBlock)(UIImage *img, NSData *data, NSDictionary *headers);

@interface ImageFetcher : NSObject

/* The ImageFetcher is a singleton manager, thus you will refrence it using  ‘[ImageFetcher sharedInstance]’ */
+ (id)sharedInstance;

/*
 In the ‘info’ dictionary you will need to provide 3 mandatory values: a NSString representing the image url, an NSValue representing a CGSIze of the image view that will present the image and a pre defined NSString for the desired folder in which to save the image after it has been downloaded.
 
 Values of info dictionary:
 ext_url -      the external url of the image
 loc_url -      the local url to save or fetch the image from
 loc_prefix -   the prefix (if any) to add to the unique filename when saving locally
 val_size -     an NSValue representing a desired CGSize of the image
 
 The ‘ImageFetchResultBlock’ returns a simple (UIImage *) that will point to the image in case of success, or will be nil in case of failure.
 */
- (NSInteger)fetchImagewithInfo:(NSDictionary *)info andCompletionBlock:(ImageFetchResultBlock)completion;


- (void)fetchImageFromLocalUrlWithInfoAsync:(NSDictionary *)info andCompletionBlock:(ImageFetchInnerResultBlock)completion;


- (void)storeImage:(UIImage *)image withData:(NSData *)data andUrlInfo:(NSDictionary *)info;

- (void)fetchImageFromOriginalUrlWithInfo:(NSDictionary *)info andCompletionBlock:(ImageDownloadResultBlock)completion;
/*
 These are comfort functions in order to potentially associate the 'uid' recieved from 'fetchImagewithInfo:andCompletionBlock:' to a spesific object, probably uiimageview.
 */
- (void)setAssociatedUid:(NSInteger)uid forObject:(NSObject *)obj;
- (NSInteger)getAssociatedUidFromObject:(NSObject *)obj;
- (void)setMemoryCachingEnabled:(BOOL)isEnabled;

@end

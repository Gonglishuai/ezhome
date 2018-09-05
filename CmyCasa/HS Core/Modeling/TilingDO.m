//
//  TilingDO.m
//  Homestyler
//
//  Created by Or Sharir on 7/2/13.
//
//

#import "TilingDO.h"
#import "SDWebImageManager.h"
#import "ImageFetcher.h"

NSString * const kTilingTitleKey = @"title";
NSString * const kTilingImageURLKey = @"filename";
NSString * const kTilingSizeKey = @"tileSize";
NSString * const kTilingURLKey = @"url";
NSString * const kTilingThumbKey = @"thumb";
NSString * const kTilingPropertiesKey = @"parameters";

@interface TilingDO ()
@property (strong, atomic) dispatch_queue_t             queue;
@property (strong, nonatomic, readwrite) NSString       *title;
@property (strong, nonatomic, readwrite) NSString       *imageURL;
@property (strong, nonatomic, readwrite) NSString       *tileURL;
@property (strong, nonatomic, readwrite) NSNumber       *tileSize;
@property (assign, atomic, readwrite) BOOL              isImageDataAvailable;
@property (assign, atomic, readwrite) BOOL              loadingImage;
@end

@implementation TilingDO
-(instancetype)initWithTitle:(NSString*)title imageURL:(NSString*)imageURL tileSize:(NSNumber*)tileSize  tileURL:(NSString*)tileURL
{
    static NSString * const queueName = @"TilingDO";
    if (!title || !imageURL) return nil;
    if (self = [super init]) {
        self.queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        self.title = title;
        self.imageURL = imageURL;
        self.isImageDataAvailable = NO;
        self.tileSize = tileSize;
        self.tileURL = tileURL;
    }
    return self;
}
- (void)dealloc {
    if (self.queue) {
        //dispatch_release(self.queue);
        self.queue = NULL;
    }
}
-(UIImage*)getImage {
	@synchronized(self) {
    if (self.image) return self.image;
    dispatch_sync(self.queue, ^{
        if (!self.image) {

            self.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.imageURL];
            if (!self.image) {
                static const int retries = 3;
                for (int i = 0; i < retries && self.image == nil; ++i) {
                    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]]]; // FIXME
                }
                if (self.image) {
                    [[SDImageCache sharedImageCache] storeImage:self.image forKey:self.imageURL completion:nil];
                }
            }
            if (self.image) self.isImageDataAvailable = YES;
        }
    });
    }
    return self.image;
        
}

-(void)loadImageInBackground:(void (^)(UIImage* image))block
{
        NSValue *valSize = [NSValue valueWithCGSize:CGSizeZero];
        NSDictionary *dic;
        
        if (IS_IPHONE && !IS_PHONEPOD5()) {
            valSize = [NSValue valueWithCGSize:CGSizeMake(128, 128)];
            dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.imageURL)?self.imageURL:@"",
                    IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                    IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS};
            
        }else{
            dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.imageURL)?self.imageURL:@"",
                    IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                    IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS,
                    IMAGE_FETCHER_INFO_KEY_URL_FORMATING : IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
            
        }
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       self.isImageDataAvailable = YES;
                       self.image = image;
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          block(image);
                                      });
                   }];
   
}

-(void)loadThumbnailInBackground:(void (^)(UIImage* image))block
{
    NSValue *valSize = [NSValue valueWithCGSize:CGSizeZero];
    NSDictionary *dic;
    
    if (IS_IPHONE && !IS_PHONEPOD5()) {
        valSize = [NSValue valueWithCGSize:CGSizeMake(128, 128)];
        dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.thumbURL)?self.thumbURL:@"",
                IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS};
        
    }else{
        dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.thumbURL)?self.thumbURL:@"",
                IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS,
                IMAGE_FETCHER_INFO_KEY_URL_FORMATING : IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
        
    }
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   self.isImageDataAvailable = YES;
                   self.thumbImage = image;
                   dispatch_async(dispatch_get_main_queue(), ^
                                  {
                                      block(image);
                                  });
               }];
    
}

-(void)clearCache{
    self.isImageDataAvailable = NO;
    self.image=nil;
}
@end

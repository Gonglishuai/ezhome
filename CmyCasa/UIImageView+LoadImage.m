//
//  UIImageView+LoadImage.m
//  Homestyler
//
//  Created by Eric Dong on 02/04/18.
//
//

#import "UIImageView+LoadImage.h"
#import "ImageFetcher.h"
#import "NSString+Contains.h"

@implementation UIImageView (LoadImage)

- (void)loadImageFromUrl:(nullable NSString *)url defaultImage:(nullable UIImage*)defaultImage {
    [self loadImageFromUrl:url defaultImage:defaultImage animated:NO completion:nil];
}

- (void)loadImageFromUrl:(nullable NSString *)url defaultImage:(nullable UIImage*)defaultImage animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock {
    [self loadImageFromUrl:url withSize:CGSizeZero defaultImage:defaultImage animated:animated completion:completionBlock];
}

- (void)loadImageFromUrl:(nullable NSString *)url withSize:(CGSize)size defaultImage:(nullable UIImage*)defaultImage animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock {
    if ([NSString isNullOrEmpty:url]) {
        if (defaultImage != nil) {
            self.image = defaultImage;
        }
        if (completionBlock != nil) {
            completionBlock(nil, -1, nil);
        }
        return;
    }

    CGSize imgSize = CGSizeEqualToSize(size, CGSizeZero) ? CGSizeMake(self.bounds.size.width, self.bounds.size.height) : size;
    NSValue *valSize = [NSValue valueWithCGSize:imgSize];
    NSDictionary *dict = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL : url,
                           IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                           IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                           IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self
                           };

    __weak typeof(self) weakSelf = self;
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dict andCompletionBlock:^(UIImage *image, NSInteger uid, NSDictionary* imageMeta) {
        if (weakSelf == nil || (image == nil && defaultImage == nil))
        {
            if (completionBlock != nil) {
                completionBlock(image, uid, imageMeta);
            }
            return;
        }
        
        NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:weakSelf];
        if (currentUid == uid) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (image != nil) {
                    BOOL animated_ = animated && (imageMeta == nil || ![imageMeta objectForKey:@"isCache"]);
                    [weakSelf setImage:image animated:animated_ completion:^{
                        if (completionBlock != nil)
                            completionBlock(image, uid, imageMeta);
                    }];
                } else if (defaultImage != nil) {
                    [weakSelf setImage:defaultImage animated:animated completion:^{
                        if (completionBlock != nil)
                            completionBlock(image, uid, imageMeta);
                    }];
                } else {
                    if (completionBlock != nil)
                        completionBlock(image, uid, imageMeta);
                }
            });
        } else {
            if (completionBlock != nil) {
                completionBlock(nil, uid, nil);
            }
        }
    }];
}

- (void)loadImageFromUrl:(nullable NSString *)url defaultImageName:(nullable NSString *)defaultImageName {
    [self loadImageFromUrl:url defaultImageName:defaultImageName animated:NO completion:nil];
}

- (void)loadImageFromUrl:(nullable NSString *)url defaultImageName:(nullable NSString *)defaultImageName animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock {
    [self loadImageFromUrl:url withSize:CGSizeZero defaultImageName:defaultImageName animated:animated completion:completionBlock];
}

- (void)loadImageFromUrl:(nullable NSString *)url withSize:(CGSize)size defaultImageName:(nullable NSString *)defaultImageName animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock {
    if ([NSString isNullOrEmpty:url]) {
        if (![NSString isNullOrEmpty:defaultImageName]) {
            self.image = [UIImage imageNamed:defaultImageName];
        }
        return;
    }

    CGSize imgSize = CGSizeEqualToSize(size, CGSizeZero) ? CGSizeMake(self.bounds.size.width, self.bounds.size.height) : size;
    NSValue *valSize = [NSValue valueWithCGSize:imgSize];
    NSDictionary *dict = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL : url,
                           IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                           IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                           IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self
                           };

    __weak typeof(self) weakSelf = self;
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dict andCompletionBlock:^(UIImage *image, NSInteger uid, NSDictionary* imageMeta) {
        if (weakSelf == nil || (image == nil && defaultImageName == nil))
            return;

        NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:weakSelf];
        if (currentUid == uid) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (image != nil) {
                    BOOL animated_ = animated && (imageMeta == nil || ![imageMeta objectForKey:@"isCache"]);
                    [weakSelf setImage:image animated:animated_ completion:^{
                        if (completionBlock != nil)
                            completionBlock(image, uid, imageMeta);
                    }];
                } else if (defaultImageName != nil) {
                    [weakSelf setImage:[UIImage imageNamed:defaultImageName] animated:animated completion:^{
                        if (completionBlock != nil)
                            completionBlock(image, uid, imageMeta);
                    }];
                }
            });
        }
    }];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated completion:(void (^ __nullable)())completionBlock {
    if (animated) {
        self.alpha = 0.0;
        self.image = image;
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             if (completionBlock != nil) {
                                 completionBlock();
                             }
                         }];
    } else {
        self.image = image;
        if (completionBlock != nil) {
            completionBlock();
        }
    }

}

@end

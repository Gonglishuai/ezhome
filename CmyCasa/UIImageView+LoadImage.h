//
//  UIImageView+LoadImage.h
//  Homestyler
//
//  Created by Eric Dong on 02/04/18.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (LoadImage)

- (void)loadImageFromUrl:(nullable NSString *)url defaultImage:(nullable UIImage *)defaultImage;
- (void)loadImageFromUrl:(nullable NSString *)url defaultImage:(nullable UIImage *)defaultImage animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock;
- (void)loadImageFromUrl:(nullable NSString *)url withSize:(CGSize)size defaultImage:(nullable UIImage *)defaultImage animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock;

- (void)loadImageFromUrl:(nullable NSString *)url defaultImageName:(nullable NSString *)defaultImageName;
- (void)loadImageFromUrl:(nullable NSString *)url defaultImageName:(nullable NSString *)defaultImageName animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock;
- (void)loadImageFromUrl:(nullable NSString *)url withSize:(CGSize)size defaultImageName:(nullable NSString *)defaultImageName animated:(BOOL)animated
              completion:(void (^ __nullable)(UIImage *image, NSInteger uid, NSDictionary* imageMeta))completionBlock;

@end

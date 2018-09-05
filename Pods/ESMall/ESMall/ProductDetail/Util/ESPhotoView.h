
#import <UIKit/UIKit.h>

@class ESPhotoBrowser, ESPhoto, ESPhotoView;

@protocol ESPhotoViewDelegate <NSObject>

- (void)photoViewImageFinishLoad:(ESPhotoView *)photoView;
- (void)photoViewSingleTap:(ESPhotoView *)photoView;
- (void)photoViewDidEndZoom:(ESPhotoView *)photoView;

@end

@interface ESPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) ESPhoto *photo;
// 代理
@property (nonatomic, weak) id<ESPhotoViewDelegate> photoViewDelegate;

@end

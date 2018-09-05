
#import <UIKit/UIKit.h>
#import "ESPhoto.h"

@protocol ESPhotoBrowserDelegate;

@interface ESPhotoBrowser : UIViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<ESPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)show;

@end

@protocol ESPhotoBrowserDelegate <NSObject>

// 切换到某一页图片
- (void)photoBrowserDidChangedToPageAtIndex:(NSUInteger)index;

@end

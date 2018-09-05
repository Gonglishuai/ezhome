
#import <Foundation/Foundation.h>

@interface ESPhoto : NSObject

@property (nonatomic, strong) NSURL *url;

/// 完整的图片
@property (nonatomic, strong) UIImage *image;

/// 来源view
@property (nonatomic, strong) UIImageView *srcImageView;
@property (nonatomic, strong, readonly) UIImage *placeholder;
@property (nonatomic, strong, readonly) UIImage *capture;

@property (nonatomic, assign) BOOL firstShow;

/// 索引
@property (nonatomic, assign) int index;

@end

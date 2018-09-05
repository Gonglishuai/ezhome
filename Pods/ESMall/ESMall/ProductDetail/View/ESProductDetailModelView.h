
#import <UIKit/UIKit.h>

@class ESProductDetailSampleroomModel;
@protocol ESProductDetailModelViewDelegate <NSObject>

- (ESProductDetailSampleroomModel *)getSampleroomWithIndex:(NSInteger)index;

- (void)modelViewDidTappedWithIndex:(NSInteger)index;

@end

@interface ESProductDetailModelView : UIView

@property (nonatomic, assign) id<ESProductDetailModelViewDelegate>viewDelegate;

+ (instancetype)productDetailModelView;

- (void)updateModelViewWithIndex:(NSInteger)index;

@end

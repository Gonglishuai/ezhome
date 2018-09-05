
#import <UIKit/UIKit.h>

@class ESFlashSaleInfoModel;
@protocol ESFlashSaleViewDelegate <NSObject>

- (ESFlashSaleInfoModel *)getSkuMessage;

- (void)sureButtonDidTapped:(NSInteger)quantity;

- (void)closeButtonDidTapped;

@end

@interface ESFlashSaleView : UIView

@property (nonatomic, assign) id<ESFlashSaleViewDelegate>viewDelegate;

+ (instancetype)flashSaleView;

- (void)updateView;

@end

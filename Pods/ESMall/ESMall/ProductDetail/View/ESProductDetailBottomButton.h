
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESProductDetailBottomButtonType)
{
    ESProductDetailBottomButtonTypeUnknow = 0,
    ESProductDetailBottomButtonTypeShoppingCart,
    ESProductDetailBottomButtonTypeAddToCart,
    ESProductDetailBottomButtonTypeBuy,
    ESProductDetailBottomButtonTypeCustomMade,
    ESProductDetailBottomButtonTypeFlashSale,
    ESProductDetailBottomButtonTypEarnest
};

@protocol ESProductDetailBottomButtonDelegate <NSObject>

- (NSDictionary *)getBottomParams;

- (void)productDetailButtonDidTapped:(ESProductDetailBottomButtonType)type
                              enable:(BOOL)enable;

@end

@interface ESProductDetailBottomButton : UIView

@property (nonatomic, assign) id<ESProductDetailBottomButtonDelegate>buttonDelegate;

- (void)updateBottomButtons;

@end

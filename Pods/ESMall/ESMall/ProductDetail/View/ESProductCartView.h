
#import <UIKit/UIKit.h>

@class ESProductSKUModel;
@protocol ESProductCartViewDelegate <NSObject>

- (NSInteger)getProductCartSections;

- (NSInteger)getProductCartRowsAtSection:(NSInteger)section;

- (CGSize)getProductCartItemSizeAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)getCellIDAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)getProductHeaderTipMessage;

- (ESProductSKUModel *)getProductHeaderSku;

- (BOOL)getCustomizableeStatus;

- (void)productCartAddButtonDidTapped;

- (void)productCartCloseButtonDidTapped;

- (void)productCartItemDidTappedWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductCartView : UIView

@property (nonatomic, assign) id<ESProductCartViewDelegate>viewDelegate;

+ (instancetype)productCartView;

- (void)refreshProductCartHeaderView;

- (void)refreshProductCartLabelsView;

- (void)keyboardWillBeShownWithKeyBoardHeight:(NSInteger)kbHeight;

- (void)keyboardWillBeHidden;

@end

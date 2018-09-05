
#import <UIKit/UIKit.h>

@class ESProductStoreModel;
@protocol ESProductDetailStoreMapViewDelegate <NSObject>

- (NSArray <ESProductStoreModel *> *)getStoreInformations;

- (NSInteger)getStoreCount;

- (void)storeDidTappedWithName:(NSString *)storeName
                      latitude:(CGFloat)latitude
                     longitude:(CGFloat)longitude;

- (void)storeDidSelectedWithName:(NSString *)storeName;

- (void)storeItemDidTappedWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailStoreMapView : UIView

@property (nonatomic, assign) id<ESProductDetailStoreMapViewDelegate>viewDelegate;

- (void)refreshView;

- (void)refreshStoresTable;

@end

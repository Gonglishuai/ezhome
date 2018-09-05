
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESProductDetailSegControlType)
{
    ESProductDetailSegControlTypeUnknow = 0,
    ESProductDetailSegControlTypeProduct,
    ESProductDetailSegControlTypeDescription,
    ESProductDetailSegControlTypeParameters
};

typedef NS_ENUM(NSInteger, ESProductDetailTableType)
{
    ESProductDetailTableTypeUnKnow = 0,
    ESProductDetailTableTypeProduct,
    ESProductDetailTableTypeParameters,
};

@protocol ESProductDetailViewDelegate <NSObject>

- (void)registerCellAtTableView:(UITableView *)tableView
                           type:(ESProductDetailTableType)tableType;

- (NSInteger)numberOfSectionsInProductViewWithType:(ESProductDetailSegControlType)type;

- (NSInteger)numberOfRowsInProductViewWithSection:(NSInteger)section
                                             type:(ESProductDetailSegControlType)type;

- (BOOL)getShowModelStatus;

- (NSString *)getCellIDAtIndexPath:(NSIndexPath *)indexPath
                         tableType:(ESProductDetailTableType)tableType;

- (NSString *)getProductDetailHtmlStr;

- (void)scrollDidEndDragingWithIndex:(NSInteger)index;

- (void)productDescriptionViewDidPull;

- (void)productInformationViewDidUpdate;

@end

@interface ESProductDetailView : UIView

@property (nonatomic, assign) id<ESProductDetailViewDelegate>viewDelegate;

- (void)updateProductDetailViewWithType:(ESProductDetailSegControlType)index;

- (void)refreshProductDetailTableViewWithSection:(NSInteger)index;

- (void)refreshProductDetailView;

- (void)updateBottomButton;

@end

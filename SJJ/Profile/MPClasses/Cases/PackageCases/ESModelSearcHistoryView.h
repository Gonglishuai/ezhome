
#import <UIKit/UIKit.h>

@protocol ESModelSearcHistoryViewDelegate <NSObject>

- (NSInteger)getModelSearchHistoryRowsCount;

- (void)historyItemDidTapped:(NSIndexPath *)indexPath;

@end

@interface ESModelSearcHistoryView : UIView

@property (nonatomic, assign) id<ESModelSearcHistoryViewDelegate>viewDelegate;

- (void)refreshHistory;

@end

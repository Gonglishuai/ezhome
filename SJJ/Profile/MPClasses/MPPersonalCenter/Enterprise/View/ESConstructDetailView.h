
#import <UIKit/UIKit.h>

@protocol ESConstructDetailViewDelegate <NSObject>

- (NSInteger)getConstructDetailSections;

- (NSInteger)getConstructDetailRowsWithSection:(NSInteger)section;

- (void)cellDidTappedWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESConstructDetailView : UIView

@property (nonatomic, assign) id<ESConstructDetailViewDelegate>viewDelegate;

- (void)tableViewReload;

@end

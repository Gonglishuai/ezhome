
#import <UIKit/UIKit.h>

@protocol ESPayTimesViewDelegate <NSObject>

- (NSInteger)getPayViewRowsWithSection:(NSInteger)section;

- (NSArray *)getRegCellNames;

- (NSString *)getCellIdWithIndexPath:(NSIndexPath *)indexPath;

- (void)payButtonDidTapped;

@end

@interface ESPayTimesView : UIView

@property (nonatomic, assign) id<ESPayTimesViewDelegate>viewDelegate;

- (void)tableViewReload;

- (void)tableviewShowTextInputWithIndexPath:(NSIndexPath *)indexPath
                                 showStatus:(BOOL)showStatus;

- (void)updateButtonWithAmount:(NSString *)amount
                        enable:(BOOL)enable;

@end

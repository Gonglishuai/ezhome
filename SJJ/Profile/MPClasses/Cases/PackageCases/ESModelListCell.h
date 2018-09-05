
#import <UIKit/UIKit.h>

@class ESSampleRoomModel;
@protocol ESModelListCellDelegate <NSObject>

- (ESSampleRoomModel *)getModelListCellDataWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESModelListCell : UITableViewCell

@property (nonatomic, assign) id<ESModelListCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end


#import "MPBaseViewController.h"

@class ESSampleRoomTagModel;
@protocol ESModelFilterViewControllerDelegate <NSObject>

- (void)closeButtonDidTapped;

- (void)filterCompleteButtonDidTapped:(NSString *)tagsString;

@end

@interface ESModelFilterViewController : MPBaseViewController

@property (nonatomic, assign) id<ESModelFilterViewControllerDelegate>delegate;

@property (nonatomic, retain) NSArray <ESSampleRoomTagModel *> *tags;

@end

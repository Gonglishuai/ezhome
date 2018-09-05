
#import <UIKit/UIKit.h>

@protocol ESModelFilterViewDelegate <NSObject>

- (NSInteger)getModelFilterSections;

- (NSInteger)getModelFilterRowsAtSection:(NSInteger)section;

@end

@interface ESModelFilterView : UIView

@property (nonatomic, assign) id<ESModelFilterViewDelegate>viewDelegate;

- (void)refreshTags;

- (void)refreshTagSection:(NSInteger)section;

@end

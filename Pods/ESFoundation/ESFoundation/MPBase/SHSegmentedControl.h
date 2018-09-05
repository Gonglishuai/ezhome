
#import <UIKit/UIKit.h>

@protocol SHSegmentedControlDelegate <NSObject>

/**
 *  @brief the method for button click.
 *
 *  @param index the title index.
 *
 *  @return void nil.
 */
- (void)segBtnClickWithTitleIndex:(NSInteger)index;

@end

@interface SHSegmentedControl : UIView

/// delegate.
@property (nonatomic, assign) id<SHSegmentedControlDelegate>delegate;

/// line color, default is red.
@property (nonatomic, strong) UIColor *lineColor;

/// title color, default is red.
@property (nonatomic, strong) UIColor *titleColor;

/// title place color, default is light gray.
@property (nonatomic, strong) UIColor *titlePlaceColor;

/// the time for moving line, default is 0.2s.
@property (nonatomic ,assign) NSTimeInterval time;

/// 首次选中的索引，初始化为0 （不影响之前使用）
@property (nonatomic ,assign) NSInteger selectedIndex;

/// 默认为系统font
@property (nonatomic ,assign) CGFloat titleFont;


/**
 *  @brief the method for create Seg.
 *
 *  @param titles the array of button title.
 *
 *  @return void nil.
 */
- (void)createSegUIWithTitles:(NSArray *)titles;

- (void)updateSelectedSegmentAtIndex:(NSInteger)index;

@end

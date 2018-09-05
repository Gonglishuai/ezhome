
#import <UIKit/UIKit.h>

@interface MPPickerView : UIView

/**
 *  @brief Initialize the selector and return the selected data.
 *
 *  @param frame the frame for pickerView.
 *
 *  @param type the type for pickerView.
 *
 *  @param finish the block for return result for selected data.
 *
 *  @param componet1 the data of pickerView in componet one.
 *
 *  @param dict the information of picker seleted.
 *
 *  @return instancetype return pickerView.
 */
- (instancetype)initWithFrame:(CGRect)frame
                    plistName:(NSString *)plistName
                 compontCount:(NSInteger)compont
                      linkage:(BOOL)isLinkage
                     optional:(BOOL)isOptional style:(NSString *)style finish:(void(^) (NSDictionary *dict))finish ;

/// compont count is 1;
- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
              arrayDataSource:(NSArray *)arrayDataSource
                       finish:(void(^) (NSDictionary *dict))finish;

/**
 *  @brief the method for remove picker.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void)removePickerView;

- (void)showInView:(UIView *)view;

- (void)hiddenPickerView;

@end

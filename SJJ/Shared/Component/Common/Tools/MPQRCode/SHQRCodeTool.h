
#import <Foundation/Foundation.h>

@protocol SHQRCodeToolDelegate <NSObject>

@required
- (BOOL)setQRButtonShown;

@end
@interface SHQRCodeTool : NSObject
@property (nonatomic, weak) id<SHQRCodeToolDelegate> delegate;

+ (instancetype)sharedInstance;
/**
 *  @brief the method for check camera.
 *
 *  @param nil.
 *
 *  @return BOOL camera enable or not.
 */
+ (BOOL)checkCameraEnable;

/**
 *  @brief the method for check QR information.
 *
 *  @param vc the view controller.
 *
 *  @param dict the information for qr reader.
 *
 *  @return void nil.
 */
+ (void)checkQRWithViewController:(UIViewController *)vc
                             dict:(NSDictionary *)dict;

/**
 *  @brief the method for check qr button.
 *
 *  @param btn the button for qr reader.
 *
 *  @return void nil.
 */
+ (void)checkQRBtn:(UIButton *)btn;

@end

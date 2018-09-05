
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SHQRCodeGenerate : NSObject

/**
 *  @brief the method for create qr code.
 *
 *  @param stringURL the string of qr code.
 *
 *  @param complete the block for create over.
 *
 *  @return MPQRCodeGenerate object manager.
 */
+ (void)createQRCodeWithString: (NSString *)stringURL
                      complete:(void(^) (UIImage *QRImage))complete;

@end


#import "MPBaseViewController.h"

@interface SHAboutWebViewController : MPBaseViewController

/**
 *  @brief the method for instancetype.
 *
 *  @param titleStr the string for title.
 *
 *  @param fileNameStr the string for fileName.
 *
 *  @return instancetype.
 */
- (instancetype)initWithParm:(NSString *)titleStr
                   withFile:(NSString *)fileNameStr;

@end


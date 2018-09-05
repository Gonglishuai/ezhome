
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ESPromotionType)
{
    ESPromotionTypeBackground = 0,
    ESPromotionTypeForeground,
};

@interface ESPromotionUtil : NSObject

+ (void)showPromotionAlert:(NSDictionary *)userInfo;

+ (void)showPromotionViewWithUrl:(NSString *)url
                            type:(ESPromotionType)type;

@end

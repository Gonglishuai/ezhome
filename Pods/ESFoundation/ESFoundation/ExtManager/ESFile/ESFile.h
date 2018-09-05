
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ESFileType)
{
    ESFileTypeUnknow = 0,
    ESFileTypeHD,
    ESFileTypeLarge,
};

@interface ESFile : NSObject

+ (NSString *)getImageUrl:(NSString *)url
                 withType:(ESFileType)fileType;

@end


#import "ESFile.h"

@implementation ESFile

+ (NSString *)getImageUrl:(NSString *)url
                 withType:(ESFileType)fileType
{
    if (!url
        || ![url isKindOfClass:[NSString class]]
        || url.length <= 0)
    {
        return url;
    }
    
    switch (fileType)
    {
        case ESFileTypeHD:
        {
            url = [url stringByAppendingString:@"?x-oss-process=style/hd"];
            break;
        }
        case ESFileTypeLarge:
        {
            url = [url stringByAppendingString:@"?x-oss-process=style/large"];
            break;
        }
        default:
        {
            break;
        }
    }
    
    return url;
}

@end

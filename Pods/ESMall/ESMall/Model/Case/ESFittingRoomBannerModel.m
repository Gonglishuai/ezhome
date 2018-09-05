
#import "ESFittingRoomBannerModel.h"

@implementation ESFittingRoomBannerModel

- (id)createModelWithDic:(NSDictionary *)dic
{
    if (dic
        && [dic isKindOfClass:[NSDictionary class]])
    {
        self.dataDic = dic;
        
        NSDictionary *extend_dic = dic[@"extend_dic"];
        if (extend_dic
            && [extend_dic isKindOfClass:[NSDictionary class]])
        {
            NSString *image = extend_dic[@"image"];
            if (image
                && [image isKindOfClass:[NSString class]])
            {
                self.imageUrl = image;
            }
        }
    }
    else
    {
        self.dataDic = @{};
    }
    
    if (!self.imageUrl
        || ![self.imageUrl isKindOfClass:[NSString class]])
    {
        self.imageUrl = @"";
    }
    
    return self;
}

@end

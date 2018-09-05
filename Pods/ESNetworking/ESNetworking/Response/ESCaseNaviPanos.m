//
//  ESCaseNaviPanos.m
//  AFNetworking
//
//  Created by xiefei on 28/7/18.
//

#import "ESCaseNaviPanos.h"
#import "CoStringManager.h"

@implementation ESCaseNaviPanos

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.roomTypeCode       = [CoStringManager judgeNSString:dict forKey:@"roomTypeCode"];
        self.description_Nav    = [CoStringManager judgeNSString:dict forKey:@"description"];
        
        self.renderImgs         = [NSMutableArray array];
        self.imageUrls          = [NSMutableArray array];
        self.isHave360Urls      = [NSMutableArray array];
        if (dict && [[dict objectForKey:@"renderImgs"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in [dict objectForKey:@"renderImgs"]) {
                [self.renderImgs addObject:[ESCaseRenderImage objFromDict:dic]];
                if (![[CoStringManager displayCheckString:[dic objectForKey:@"coverUrl"]] isEqualToString:NO_DATA_STRING]) {
                    [self.imageUrls addObject:[dic objectForKey:@"coverUrl"]];
                }
                
                if (![[CoStringManager displayCheckString:[dic objectForKey:@"photo360Url"]] isEqualToString:NO_DATA_STRING]) {
                    [self.isHave360Urls addObject:@"3D看房"];
                }else{
                    [self.isHave360Urls addObject:@""];
                }
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseNaviPanos *caseDetail = [[ESCaseNaviPanos alloc] initWithDict:dict];
    return caseDetail;
}
@end

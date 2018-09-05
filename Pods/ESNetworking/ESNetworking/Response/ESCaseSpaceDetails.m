//
//  ESCaseSpaceDetails.m
//  AFNetworking
//
//  Created by xiefei on 28/7/18.
//

#import "ESCaseSpaceDetails.h"
#import "CoStringManager.h"

@implementation ESCaseSpaceDetails

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.roomTypeCode               = [CoStringManager judgeNSString:dict forKey:@"roomTypeCode"];
        self.description_Space          = [CoStringManager judgeNSString:dict forKey:@"description"];
        
        self.renderImgs     = [NSMutableArray array];
        self.imageUrls      = [NSMutableArray array];
        self.isHave360Urls  = [NSMutableArray array];

        if (dict && [[dict objectForKey:@"renderImgs"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in [dict objectForKey:@"renderImgs"]) {
                [self.renderImgs addObject:[ESCaseRenderImage objFromDict:dic]];
                if (![[CoStringManager displayCheckString:[dic objectForKey:@"coverUrl"]] isEqualToString:NO_DATA_STRING]) {
                    [self.imageUrls addObject:[dic objectForKey:@"coverUrl"]];
                }else if (![[CoStringManager displayCheckString:[dic objectForKey:@"photoUrl"]] isEqualToString:NO_DATA_STRING]) {
                    [self.imageUrls addObject:[dic objectForKey:@"photoUrl"]];
                }
        
                if (![[CoStringManager displayCheckString:[dic objectForKey:@"photo360Url"]] isEqualToString:NO_DATA_STRING]) {
                    [self.isHave360Urls addObject:@"3D看房"];
                }             
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseSpaceDetails *caseDetail = [[ESCaseSpaceDetails alloc] initWithDict:dict];
    return caseDetail;
}
@end

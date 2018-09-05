//
//  ESCaseRenderImage.m
//  AFNetworking
//
//  Created by xiefei on 28/7/18.
//

#import "ESCaseRenderImage.h"
#import "CoStringManager.h"

@implementation ESCaseRenderImage

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.renderId               = [CoStringManager judgeNSString:dict forKey:@"renderId"];
        self.roomId                 = [CoStringManager judgeNSString:dict forKey:@"roomId"];
        self.roomTypeDisplayName    = [CoStringManager judgeNSString:dict forKey:@"roomTypeDisplayName"];
        self.status                 = [CoStringManager judgeNSInteger:dict forKey:@"status"];
        self.selectStatus           = [CoStringManager judgeNSInteger:dict forKey:@"selectStatus"];
        self.renderType             = [CoStringManager judgeNSString:dict forKey:@"renderType"];
        self.coverUrl               = [CoStringManager judgeNSString:dict forKey:@"coverUrl"];
        self.photoUrl               = [CoStringManager judgeNSString:dict forKey:@"photoUrl"];
        self.photo360Url            = [CoStringManager judgeNSString:dict forKey:@"photo360Url"];
        self.skus                   = [CoStringManager judgeNSString:dict forKey:@"skus"];
        self.subRenderingType       = [CoStringManager judgeNSString:dict forKey:@"subRenderingType"];
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseRenderImage *caseDetail = [[ESCaseRenderImage alloc] initWithDict:dict];
    return caseDetail;
}

@end

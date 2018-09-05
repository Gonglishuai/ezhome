//
//  ESCase2DImageModel.m
//  AFNetworking
//
//  Created by Admin on 2018/8/6.
//

#import "ESCase2DImageModel.h"
#import "CoStringManager.h"
#import "ESCase2DItemModel.h"

@implementation ESCase2DImageModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.typeKey = [CoStringManager judgeNSString:dict forKey:@"typeKey"];
        self.description_Space = [CoStringManager judgeNSString:dict forKey:@"description"];
        self.typeName = [CoStringManager judgeNSString:dict forKey:@"typeName"];
        
        self.renderImgs  = [NSMutableArray array];
        if (dict && [[dict objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in [dict objectForKey:@"data"]) {
                [self.renderImgs addObject:[ESCase2DItemModel objFromDict:dic]];
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCase2DImageModel *caseDetail = [[ESCase2DImageModel alloc] initWithDict:dict];
    return caseDetail;
}
@end

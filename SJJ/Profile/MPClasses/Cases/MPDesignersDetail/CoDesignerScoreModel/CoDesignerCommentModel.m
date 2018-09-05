//
//  CoDesignerCommentModel.m
//  Consumer
//
//  Created by xuezy on 16/7/27.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoDesignerCommentModel.h"

@implementation CoDesignerCommentModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self=[super init];
    
    if (self) {
      
        if (![dict isKindOfClass:[NSNull class]]) {
            if (self) {
                self.avatar = [NSString stringWithFormat:@"%@",dict[@"avatar"]];
                self.member_estimate = [NSString stringWithFormat:@"%@",dict[@"member_estimate"]];
                self.member_name = [NSString stringWithFormat:@"%@",dict[@"member_name"]];
                self.member_id = [NSString stringWithFormat:@"%@",dict[@"member_id"]];
                self.estimate_data = [NSString stringWithFormat:@"%@",dict[@"estimate_date"]];
                self.member_grade = [NSString stringWithFormat:@"%@",dict[@"member_grade"]];
            }
        }
        
    }
    
    return self;
}

+ (instancetype)designerCommentWithDict:(NSDictionary *)dict {
    
    return [[CoDesignerCommentModel alloc]initWithDict:dict];
}

+(void)createDesignerCommentListWithDesignerId:(NSString *)designer_id Parameter:(NSDictionary *)parameterDict success:(void (^)(NSMutableArray* array))success failure:(void(^) (NSError *error))failure {
    if (success) {
        success([NSMutableArray array]);
    }
}
@end

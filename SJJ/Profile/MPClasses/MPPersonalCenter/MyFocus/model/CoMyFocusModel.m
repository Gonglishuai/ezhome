//
//  CoMyFocusModel.m
//  Consumer
//
//  Created by Jiao on 16/7/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoMyFocusModel.h"
#import "JRKeychain.h"

@implementation CoMyFocusModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self=[super init];
    
    if (self) {
//        [self setValuesForKeysWithDictionary:dict];
        self.avatar = [NSString stringWithFormat:@"%@",dict[@"avatar"]];
        
        NSString *nameString = [NSString stringWithFormat:@"%@",dict[@"nick_name"]];
        NSArray *nameArray = [nameString componentsSeparatedByString:@"_"];
        
        if (nameArray.count>1) {
            self.nick_name = [nameArray objectAtIndex:0];
            self.hs_uid = [nameArray objectAtIndex:1];
        }
        self.is_real_name = [NSString stringWithFormat:@"%@",dict[@"is_real_name"]];
        self.member_id = [NSString stringWithFormat:@"%@",dict[@"member_id"]];

        
    }
    
    return self;
}

+ (instancetype)focusWithDict:(NSDictionary *)dict {
    
    return [[CoMyFocusModel alloc]initWithDict:dict];
}


+(void)createDesignerDetailWithModel:(CoMyFocusModel *)model
                             success:(void (^)(MPDesignerInfoModel *))success
                             failure:(void(^) (NSError *))failure {

}
@end

/**
 * @file    MPMemberModel.m
 * @brief   the view of MPMemberModel
 * @author  fu
 * @version 1.0
 * @date    2015-12-29
 */

#import "SHMemberModel.h"
#import "CoStringManager.h"

@implementation SHMemberModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self=[super init];
    
    if (self) {
        
        self.home_phone = [NSString stringWithFormat:@"%@",[dict objectForKey:@"home_phone"]];
        self.birthday = [NSString stringWithFormat:@"%@",[dict objectForKey:@"birthday"]];
        self.zip_code = [NSString stringWithFormat:@"%@",[dict objectForKey:@"zip_code"]];
        
        self.hitachi_account = [NSString stringWithFormat:@"%@",[dict objectForKey:@"hitachi_account"]];
        if (dict[@"real_name"] && ![dict[@"real_name"] isKindOfClass:[NSNull class]] && dict[@"real_name"][@"real_name"] && ![dict[@"real_name"][@"real_name"] isKindOfClass:[NSNull class]]) {
            
            self.true_name = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"real_name"] objectForKey:@"real_name"]];
        }else {
            self.true_name = @"";
        }
//        self.true_name = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"real_name"] objectForKey:@"real_name"]];
        //self.true_name = [[dict objectForKey:@"real_name"] objectForKey:@"real_name"];
//        self.id_card = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"real_name"] objectForKey:@"certificate_no"]];
        
        self.province = [NSString stringWithFormat:@"%@",[dict objectForKey:@"province"]];
        self.nick_name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"nick_name"]];
        self.address =  [NSString stringWithFormat:@"%@",[dict objectForKey:@"address"] ];
        self.mobile_number = [NSString stringWithFormat:@"%@",[dict objectForKey:@"mobile_number"]];
        self.measurement_price = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"measurement_price"] ];
//        self.design_price_max = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"design_price_max"] ];
        
        self.design_price_max = [SHModel formatDic:[[dict objectForKey:@"designer"] objectForKey:@"design_price_max"]];
        
//        self.design_price_min = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"design_price_min"] ];
        self.design_price_min = [SHModel formatDic:[[dict objectForKey:@"designer"] objectForKey:@"design_price_min"]];

        self.style_long_names = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"style_long_names"]];
        self.introduction = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"introduction"]];
        self.experience = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"experience"]];
        self.diy_count = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"diy_count"]];
        self.case_count = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"case_count"]];
        self.theme_pic = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"theme_pic"]];
        self.personal_honour = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"personal_honour"]];

        self.gender= [NSString stringWithFormat:@"%@",[dict objectForKey:@"gender"]];
        if ([self.gender isEqualToString:@"1"]) {
            self.gender = @"女";
        }if ([self.gender isEqualToString:@"2"]) {
            self.gender = @"男";
        }if ([self.gender isEqualToString:@"0"]) {
            self.gender = NSLocalizedString(@"保密", nil);
        }
        self.avatar = [NSString stringWithFormat:@"%@",[dict objectForKey:@"avatar"] ];
        self.acount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"hitachi_account"]];
        self.email = [NSString stringWithFormat:@"%@",[dict objectForKey:@"email"]];
//        self.town = [NSString stringWithFormat:@"%@",[dict objectForKey:@"town"]];
        self.city= [NSString stringWithFormat:@"%@",[dict objectForKey:@"city"]];
        self.district = [NSString stringWithFormat:@"%@",[dict objectForKey:@"district"]];
        self.is_loho = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"designer"] objectForKey:@"is_loho"] ] ;
        self.province_name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"province_name"]];
        self.city_name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"city_name"]];
//        self.district_name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"district_name"]];
        self.district_name = [SHMemberModel addressToForm:[[dict objectForKey:@"district_name"] description]];
        self.validate_by_mobile = [NSString stringWithFormat:@"%@",[dict objectForKey:@"is_validated_by_mobile"]];
        self.is_email_binding = [NSString stringWithFormat:@"%@",[dict objectForKey:@"is_email_binding"]];
        
        self.thread_id = [self judgeNSString:dict forKey:@"thread_id"];
        
        self.couponsAmount = [NSString stringWithFormat:@"%ld",(long)[CoStringManager judgeNSInteger:dict forKey:@"couponsAmount"]];
        self.pointAmount = [NSString stringWithFormat:@"%ld",(long)[CoStringManager judgeNSInteger:dict forKey:@"pointAmount"]];
        
    }
    return self;
}


+ (instancetype)MemberWithDict:(NSDictionary *)dict {
    
    return [[SHMemberModel alloc]initWithDict:dict];
    
}

- (NSString *)judgeNSString:(id)obj forKey:(NSString *)key {
    if ([self objectIsNull:obj forKey:key]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",[obj objectForKey:key]];
}

- (BOOL)objectIsNull:(id)obj forKey:(NSString *)key {
    if (obj == nil ||
        [obj isKindOfClass:[NSNull class]] ||
        [obj objectForKey:key] == nil ||
        [[obj objectForKey:key] isKindOfClass:[NSNull class]]) {
        return YES;
    }
    return NO;
}



@end

//
//  CoMyFocusModel.h
//  Consumer
//
//  Created by Jiao on 16/7/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "SHModel.h"
#import "MPDesignerInfoModel.h"
@interface CoMyFocusModel : SHModel

@property (nonatomic,copy)NSString *avatar;

@property (nonatomic,copy)NSString *hs_uid;
@property (nonatomic,copy)NSString *is_real_name;
@property (nonatomic,copy)NSString *member_id;
@property (nonatomic,copy)NSString *nick_name;

-(instancetype)initWithDict:(NSDictionary *)dict;

+(instancetype)focusWithDict:(NSDictionary *)dict;


+(void)createDesignerDetailWithModel:(CoMyFocusModel *)model
                             success:(void (^)(MPDesignerInfoModel *model))success
                             failure:(void(^) (NSError *error))failure;
@end

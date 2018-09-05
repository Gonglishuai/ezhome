//
//  CoDesignerCommentModel.h
//  Consumer
//
//  Created by xuezy on 16/7/27.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "SHModel.h"

@interface CoDesignerCommentModel : SHModel
@property (nonatomic,copy)NSString *avatar;
@property (nonatomic,copy)NSString *estimate_data;
@property (nonatomic,copy)NSString *member_name;
@property (nonatomic,copy)NSString *member_id;
@property (nonatomic,copy)NSString *member_estimate;
@property (nonatomic,copy)NSString *member_grade;

-(instancetype)initWithDict:(NSDictionary *)dict;

+(instancetype)designerCommentWithDict:(NSDictionary *)dict;


+(void)createDesignerCommentListWithDesignerId:(NSString *)designer_id Parameter:(NSDictionary *)parameterDict success:(void (^)(NSMutableArray* array))success failure:(void(^) (NSError *error))failure;
@end

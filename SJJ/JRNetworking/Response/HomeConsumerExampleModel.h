//
//  HomeConsumerExampleModel.h
//  Consumer
//
//  Created by jiang on 2017/5/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESBaseModel.h"

@interface HomeConsumerExampleModel : ESBaseModel

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *case_id;
@property (nonatomic, copy) NSString *style;
@property (nonatomic, copy) NSString *house_type;
@property (nonatomic, copy) NSString *house_area;
/// 使用时记得boolValue
@property (nonatomic, copy) NSString *is_new;

@property (nonatomic, copy) NSString *designer_member_id;
@property (nonatomic, copy) NSString *designer_hs_uid;
@property (nonatomic, copy) NSString *designer_cover;
@property (nonatomic, copy) NSString *designer_nick_name;

@end

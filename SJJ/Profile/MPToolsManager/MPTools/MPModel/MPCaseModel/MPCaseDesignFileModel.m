//
//  MPCaseDesignFileModel.m
//  Consumer
//
//  Created by 董鑫 on 16/8/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MPCaseDesignFileModel.h"

@implementation MPCaseDesignFileModel

//@property (nonatomic, copy) NSString *bedroom;  //厅
//@property (nonatomic, copy) NSString *city;     //市
//@property (nonatomic, copy) NSString *community_name;  //小区名称
//@property (nonatomic, copy) NSString *conception;    //设计理念
//@property (nonatomic, copy) NSString *design_name; // 方案名称
//@property (nonatomic, copy) NSString *district;    //区
//@property (nonatomic, copy) NSString *hs_designer_uid;   //homestyle设计师id<br>
//@property (nonatomic, copy) NSString *design_asset_id; //case_id
//@property (nonatomic, retain) NSNumber *designer_id;
//@property (nonatomic, retain) MPDesignerInfoModel *designer_info;  // 设计师信息
//@property (nonatomic, retain) NSArray<MPCaseDesignFileModel>*images3D; //images
//@property (nonatomic, copy) NSString *hs_design_id;  //方案ID<br>
//@property (nonatomic, copy) NSString *project_style; //风格（下拉框，现代 田园 混搭 简约 地中海 中式 日式 韩式 新古典 欧式 美式 港式 北
//@property (nonatomic, copy) NSString *project_type;  //空间（下拉框，客厅 卧室 厨房 餐厅 卫生间 阳台 玄关 书房 衣帽间 儿童房 楼梯 其他
//@property (nonatomic, copy) NSString *province;      //省（直辖）市
//@property (nonatomic, copy) NSString *publish_status;    //公私标志
//@property (nonatomic, copy) NSString *restroom;           //卫
//@property (nonatomic, copy) NSString *room_area;          //面积
//@property (nonatomic, copy) NSString *room_type;          //室
//@property (nonatomic, retain) NSNumber *favorite_count;   //收藏数



- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.name       = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.link       = [CoStringManager judgeNSString:dict forKey:@"link"];
        self.type       = [CoStringManager judgeNSString:dict forKey:@"type"];
        self.is_primary = [CoStringManager judgeBOOL:dict forKey:@"is_primary"];
        self.cover      = [CoStringManager judgeNSString:dict forKey:@"cover"];
        
    }
    return self;
}

+ (instancetype)getModelFromDict:(NSDictionary *)dict {
    return [[MPCaseDesignFileModel alloc] initWithDict:dict];
}

@end

//
//  MP3DCaseModel.h
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "SHModel.h"
#import "MPDesignerInfoModel.h"
#import "MPCaseDesignFileModel.h"

@protocol MP3DCaseModel <NSObject>

@end

@interface MP3DCaseModel : SHModel

@property (nonatomic, copy) NSString *bedroom;  //厅
@property (nonatomic, copy) NSString *city;     //市
@property (nonatomic, copy) NSString *community_name;  //小区名称
@property (nonatomic, copy) NSString *conception;    //设计理念
@property (nonatomic, copy) NSString *design_name; // 方案名称
@property (nonatomic, copy) NSString *district;    //区
@property (nonatomic, copy) NSString *hs_designer_uid;   //homestyle设计师id<br>
@property (nonatomic, copy) NSString *design_asset_id; //case_id
@property (nonatomic, copy) NSString *designer_id;
@property (nonatomic, strong) MPDesignerInfoModel *designer_info;  // 设计师信息
//@property (nonatomic, strong) NSMutableArray <MPCaseDesignFileModel *>*images3D; //images
@property (nonatomic, copy) NSString *hs_design_id;  //方案ID<br>
@property (nonatomic, copy) NSString *project_style; //风格（下拉框，现代 田园 混搭 简约 地中海 中式 日式 韩式 新古典 欧式 美式 港式 北
@property (nonatomic, copy) NSString *project_type;  //空间（下拉框，客厅 卧室 厨房 餐厅 卫生间 阳台 玄关 书房 衣帽间 儿童房 楼梯 其他
@property (nonatomic, copy) NSString *province;      //省（直辖）市
@property (nonatomic, copy) NSString *publish_status;    //公私标志
@property (nonatomic, copy) NSString *restroom;           //卫
@property (nonatomic, copy) NSString *room_area;          //面积
@property (nonatomic, copy) NSString *room_type;          //室
@property (nonatomic, assign) NSInteger favorite_count;   //收藏数
@property (nonatomic, copy) NSString *thumbnailMainPath;

@property (nonatomic, copy) NSString *original_avatar;

@property (nonatomic, strong) NSMutableArray *imageShowScrollerArr; // 详情中图片滚动的图片数组

@property (nonatomic, strong)NSString *custom_string_style;


@property (nonatomic, copy) NSString *case_color;
@property (nonatomic, copy) NSString *case_id;
@property (nonatomic, copy) NSString *case_type;


@property (nonatomic, copy) NSString *custom_string_status; //null
@property (nonatomic, copy) NSString *decoration_type;
@property (nonatomic, copy) NSString *description_designercase;

@property (nonatomic, copy) NSString *id_designercase;
@property (nonatomic, copy) NSString *is_recommended;
@property (nonatomic, copy) NSString *main_image_name;
@property (nonatomic, copy) NSString *main_image_url;

@property (nonatomic, assign) BOOL is_new;
//@property (nonatomic, copy) NSString *room_area;



@property (nonatomic, copy) NSString *search_tag;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger weight;
@property (nonatomic, assign) NSInteger click_number;

@property (nonatomic, assign) NSInteger prj_base_price;
@property (nonatomic, assign) NSInteger prj_furniture_price;
@property (nonatomic, assign) NSInteger prj_hidden_price;
@property (nonatomic, assign) NSInteger prj_material_price;
@property (nonatomic, assign) NSInteger prj_other_price;
@property (nonatomic, assign) NSInteger prj_price;


@property (nonatomic, assign) NSInteger protocol_price;



@property (nonatomic, assign) BOOL is_member_like;
@property (nonatomic, assign) NSInteger count;

//@property (nonatomic ,weak)int thumb_count;


@property (nonatomic, strong) MPCaseDesignFileModel                   *coverImgArr; //首图
@property (nonatomic, strong) NSMutableArray <MPCaseDesignFileModel *>*renderImgArr;//渲染
@property (nonatomic, strong) NSMutableArray <MPCaseDesignFileModel *>*houseImgArr; // 户型
@property (nonatomic, strong) NSMutableArray <MPCaseDesignFileModel *>*roamImgArr;  // 漫游

//3D集用
@property (nonatomic, retain) NSArray        <MPCaseDesignFileModel>*images3D;     //images


+ (instancetype)getModelFromDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

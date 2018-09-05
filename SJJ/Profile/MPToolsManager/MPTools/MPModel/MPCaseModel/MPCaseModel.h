
#import "SHModel.h"
#import "MPDesignerInfoModel.h"
#import "MPCaseImageModel.h"

@protocol MPCaseModel <NSObject>

@end

@interface MPCaseModel : SHModel

//"case_color" : "黑色",
//"case_id" : "1543882",
//"case_type" : "01",
//"city" : "1",
//"click_number" : 0,
//"community_name" : "天安门",
//"custom_string_status" : null,
//"decoration_type" : "公装",
//"description" : "测试图片",
//"designer_id" : 101,
//"designer_info" : {},
//"district" : "1",
//"favorite_count" : 0,
//"id" : null,
//"images" : [],
//"is_recommended" : "N",
//"main_image_name" : "team7.jpg",
//"main_image_url" : "http://www.baidu.com",
//"prj_base_price" : 100000,
//"prj_furniture_price" : 100000,
//"prj_hidden_price" : 1000000,
//"prj_material_price" : 100000,
//"prj_other_price" : 100000,
//"prj_price" : 1000,
//"project_style" : "现代",
//"protocol_price" : 100000000,
//"province" : "1",
//"room_area" : 100,
//"room_type" : "2-2-2",
//"search_tag" : "Case",
//"title" : "测试数据",
//"weight" : 0


@property (nonatomic, copy) NSString *case_color;
@property (nonatomic, copy) NSString *case_id;
@property (nonatomic, copy) NSString *case_type;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *community_name;
@property (nonatomic, copy) NSString *custom_string_status; //null
@property (nonatomic, copy) NSString *decoration_type;
@property (nonatomic, copy) NSString *description_designercase;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *id_designercase;
@property (nonatomic, copy) NSString *is_recommended;
@property (nonatomic, copy) NSString *main_image_name;
@property (nonatomic, copy) NSString *main_image_url;
@property (nonatomic, copy) NSString *project_style;

@property (nonatomic, copy) NSString *custom_string_bedroom;
@property (nonatomic, copy) NSString *custom_string_restroom;

@property (nonatomic, copy) NSString *room_type;
@property (nonatomic, copy) NSString *bedroom;
@property (nonatomic, copy) NSString *restroom;

@property (nonatomic, copy) NSString *search_tag;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, retain) NSNumber *weight;
@property (nonatomic, retain) NSNumber *click_number;
@property (nonatomic, retain) NSNumber *designer_id;
@property (nonatomic, retain) NSNumber *favorite_count;
@property (nonatomic, retain) NSNumber *prj_base_price;
@property (nonatomic, retain) NSNumber *prj_furniture_price;
@property (nonatomic, retain) NSNumber *prj_hidden_price;
@property (nonatomic, retain) NSNumber *prj_material_price;
@property (nonatomic, retain) NSNumber *prj_other_price;
@property (nonatomic, retain) NSNumber *prj_price;          //项目造价
@property (nonatomic, copy) NSString *hs_designer_uid;
 
@property (nonatomic, retain) NSNumber *protocol_price;
@property (nonatomic, retain) NSNumber *room_area;
@property (nonatomic, retain) NSArray<MPCaseImageModel> *images;      //images
@property (nonatomic, retain) MPDesignerInfoModel *designer_info;

@property (nonatomic, assign) BOOL is_member_like;
@property (nonatomic, assign) int   count;

@property (nonatomic, assign) BOOL is_new;
//@property (nonatomic ,weak)int thumb_count;


- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

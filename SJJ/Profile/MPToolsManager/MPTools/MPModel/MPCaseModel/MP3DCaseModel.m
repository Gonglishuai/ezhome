//
//  MP3DCaseModel.m
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MP3DCaseModel.h"
#import "MPTranslate.h"

@implementation MP3DCaseModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self createModelWithDict:dict];
        
        self.bedroom            = [CoStringManager judgeNSString:dict forKey:@"bedroom"];
        self.city               = [CoStringManager judgeNSString:dict forKey:@"city"];
        self.community_name     = [CoStringManager judgeNSString:dict forKey:@"community_name"];
        self.conception         = [CoStringManager judgeNSString:dict forKey:@"conception"];
        self.design_name        = [CoStringManager judgeNSString:dict forKey:@"design_name"];
        self.district           = [CoStringManager judgeNSString:dict forKey:@"district"];
        self.hs_designer_uid    = [CoStringManager judgeNSString:dict forKey:@"hs_designer_uid"];
        self.design_asset_id    = [CoStringManager judgeNSString:dict forKey:@"design_asset_id"];
        self.designer_id        = [CoStringManager judgeNSString:dict forKey:@"designer_id"];
        self.thumbnailMainPath  = [CoStringManager judgeNSString:dict forKey:@"thumbnailMainPath"];

        if (dict[@"is_new"]
            && ![dict[@"is_new"] isKindOfClass:[NSNull class]])
        {
            NSString *str = [NSString stringWithFormat:@"%@", dict[@"is_new"]];
            self.is_new = [str boolValue];
        }
        
        if (dict && dict[@"designer_info"] && ![dict[@"designer_info"] isKindOfClass:[NSNull class]]) {
            self.designer_info = [[MPDesignerInfoModel alloc] initWithDictionary:dict[@"designer_info"]];
        }
        
        self.renderImgArr = [NSMutableArray array]; //渲染
        self.houseImgArr = [NSMutableArray array]; // 户型
        self.roamImgArr = [NSMutableArray array];  // 漫游
        self.imageShowScrollerArr = [NSMutableArray array]; // 详情中图片滚动的图片数组
        
        if (dict && dict[@"design_file"] && ![dict[@"design_file"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary *dic in dict[@"design_file"]) {
                MPCaseDesignFileModel *file = [MPCaseDesignFileModel getModelFromDict:dic];
                
                if (file.is_primary) {
                    self.coverImgArr = file;
                    //[self.imageShowScrollerArr  insertObject:file atIndex:0];
                }
                
                // 渲染图
                if ([file.type isEqualToString:@"0"]) {
                    [self.renderImgArr addObject:file];
                }
                // 户型图
                if ([file.type isEqualToString:@"9"]) {
                    [self.houseImgArr addObject:file];
                }
                // 漫游图
                if ([file.type isEqualToString:@"4"]) {
                    [self.roamImgArr addObject:file];
                }
            }
            
        }
        
        // 将图片按顺序添加至图片数组
        for (int i=0; i<_renderImgArr.count; i++) {
            [self.imageShowScrollerArr addObject:self.renderImgArr[i]];
        }
        
        for (int i = 0; i<_houseImgArr.count ; i++) {
            [self.imageShowScrollerArr addObject:_houseImgArr[i]];
        }
        
//        for (int i = 0; i<_roamImgArr.count; i++) {
//            [self.imageShowScrollerArr addObject:_roamImgArr[i]];
//        }
        
        
        if (self.renderImgArr.count > 0) {
            [self.renderImgArr objectAtIndex:0].sectionHead = YES;
        }else {
            MPCaseDesignFileModel *file = [MPCaseDesignFileModel getModelFromDict:nil];
            file.sectionHead = YES;
            file.type = @"0";
            [self.renderImgArr insertObject:file atIndex:0];
        }
        
        if (self.houseImgArr.count > 0) {
            [self.houseImgArr objectAtIndex:0].sectionHead = YES;
        }else {
            MPCaseDesignFileModel *file = [MPCaseDesignFileModel getModelFromDict:nil];
            file.sectionHead = YES;
            file.type = @"9";
            [self.houseImgArr insertObject:file atIndex:0];
        }
        
        if (self.roamImgArr.count > 0) {
            [self.roamImgArr objectAtIndex:0].sectionHead = YES;
        }else {
            MPCaseDesignFileModel *file = [MPCaseDesignFileModel getModelFromDict:nil];
            file.sectionHead = YES;
            file.type = @"4";
            [self.roamImgArr insertObject:file atIndex:0];
        }
        
        self.hs_design_id   = [CoStringManager judgeNSString:dict forKey:@"hs_design_id"];
        self.project_style  = [CoStringManager judgeNSString:dict forKey:@"project_style"];
        self.project_type   = [CoStringManager judgeNSString:dict forKey:@"project_type"];
        self.province       = [CoStringManager judgeNSString:dict forKey:@"province"];
        self.publish_status = [CoStringManager judgeNSString:dict forKey:@"publish_status"];
        self.restroom       = [CoStringManager judgeNSString:dict forKey:@"restroom"];
        self.room_area      = [CoStringManager judgeNSString:dict forKey:@"room_area"];
        self.room_type      = [CoStringManager judgeNSString:dict forKey:@"room_type"];
        self.favorite_count = [CoStringManager judgeNSInteger:dict forKey:@"favorite_count"];
        self.case_color     = [CoStringManager judgeNSString:dict forKey:@"case_color"];
        self.case_id        = [CoStringManager judgeNSString:dict forKey:@"case_id"];    // 暂时没有用到
        self.case_type      = [CoStringManager judgeNSString:dict forKey:@"case_type"];
        self.custom_string_status = [CoStringManager judgeNSString:dict forKey:@"custom_string_status"];
        self.decoration_type= [CoStringManager judgeNSString:dict forKey:@"decoration_type"];
        self.description_designercase= [CoStringManager judgeNSString:dict forKey:@"description_designercase"];
        self.id_designercase= [CoStringManager judgeNSString:dict forKey:@"id_designercase"];
        self.is_recommended = [CoStringManager judgeNSString:dict forKey:@"is_recommended"];
        self.main_image_name= [CoStringManager judgeNSString:dict forKey:@"main_image_name"];
        self.main_image_url = [CoStringManager judgeNSString:dict forKey:@"main_image_url"];
        self.search_tag     = [CoStringManager judgeNSString:dict forKey:@"search_tag"];
        self.title          = [CoStringManager judgeNSString:dict forKey:@"title"];
        self.original_avatar= [CoStringManager judgeNSString:dict forKey:@"original_avatar"];
        self.custom_string_style = [CoStringManager judgeNSString:dict forKey:@"custom_string_style"];
        
        
        self.weight         = [CoStringManager judgeNSInteger:dict forKey:@"weight"];
        self.click_number   = [CoStringManager judgeNSInteger:dict forKey:@"click_number"];
        self.prj_base_price = [CoStringManager judgeNSInteger:dict forKey:@"prj_base_price"];
        self.prj_furniture_price= [CoStringManager judgeNSInteger:dict forKey:@"prj_furniture_price"];
        self.prj_hidden_price= [CoStringManager judgeNSInteger:dict forKey:@"prj_hidden_price"];
        self.prj_material_price= [CoStringManager judgeNSInteger:dict forKey:@"prj_material_price"];
        self.prj_other_price= [CoStringManager judgeNSInteger:dict forKey:@"prj_other_price"];
        self.prj_price      = [CoStringManager judgeNSInteger:dict forKey:@"prj_price"];
        self.protocol_price = [CoStringManager judgeNSInteger:dict forKey:@"protocol_price"];
        self.is_member_like = [CoStringManager judgeBOOL:dict forKey:@"is_member_like"];
        self.count          = [CoStringManager judgeNSInteger:dict forKey:@"count"];
        
    }
    return self;
}


+ (instancetype)getModelFromDict:(NSDictionary *)dict {
    return [[MP3DCaseModel alloc] initWithDict:dict];
}
- (void)createModelWithDict:(NSDictionary *)dict {
    
    if ([dict isKindOfClass:[NSNull class]]) return;
    
    MPDesignerInfoModel *model = [[MPDesignerInfoModel alloc] initWithDictionary:dict[@"designer_info"]];
    self.designer_info = model;
    
    if ([dict[@"design_file"] isKindOfClass:[NSNull class]]) return;
    
    NSMutableArray *arrayImage3D = [NSMutableArray array];
    
    for (NSDictionary *dic in dict[@"design_file"]) {
        MPCaseDesignFileModel *model = [[MPCaseDesignFileModel alloc]initWithDict:dic];
        [arrayImage3D addObject:model];
        
    }
    self.images3D = (id)arrayImage3D;
}

- (NSString *)bedroom {//_living _toilet
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[NSString stringWithFormat:@"%@_toilet",[_bedroom lowercaseString]]];
    
    return ([str isEqualToString:@"(null)"])?_bedroom:str;
}

- (NSString *)restroom {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[NSString stringWithFormat:@"%@_living", [_restroom lowercaseString]]];
    
    return ([str isEqualToString:@"(null)"])?_restroom:str;
}


- (NSString *)project_style {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_custom_string_style lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_custom_string_style:str;
}

- (NSString *)room_type {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_room_type lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_room_type:str;
}
@end

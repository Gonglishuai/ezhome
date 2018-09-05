//
//  ESCaseDetailModel.m
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseDetailModel.h"
#import "CoStringManager.h"
#import "ESCase2DImageModel.h"

@implementation ESCaseDetailModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.caseId          = [CoStringManager judgeNSString:dict forKey:@"caseId"];
        self.caseUrl         = [CoStringManager judgeNSString:dict forKey:@"caseUrl"];
        self.caseName        = [CoStringManager judgeNSString:dict forKey:@"caseName"];
        self.likeCount       = [CoStringManager judgeNSInteger:dict forKey:@"likeCount"];
        self.isMemberLike    = [CoStringManager judgeBOOL:dict forKey:@"isMemberLike"];
        self.contest         = [CoStringManager judgeNSString:dict forKey:@"contest"];
        if (dict && [dict objectForKey:@"shareInfo"]) {
            self.shareInfo   = [ESCaseShareModel objFromDict:[dict objectForKey:@"shareInfo"]];
        }
        if (dict && [dict objectForKey:@"designerInfo"]) {
            self.designerInfo= [ESDesignerInfoModel createModelWithDic:[dict objectForKey:@"designerInfo"]];
        }
        
        self.productList     = [NSMutableArray array];
        if (dict && [[dict objectForKey:@"productList"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in [dict objectForKey:@"productList"]) {
                [self.productList addObject:[ESCaseProductModel objFromDict:dic]];
            }
        }
        
        self.showAddFav     = [CoStringManager judgeBOOL:dict forKey:@"showAddFav"];
        self.productId      = [CoStringManager judgeNSString:dict forKey:@"productId"];
        
        
        //详情改版接口
        self.name            = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.roomArea        = [CoStringManager judgeNSString:dict forKey:@"roomArea"];
        self.hsDesignId      = [CoStringManager judgeNSString:dict forKey:@"hsDesignId"];
        self.description_design     = [CoStringManager judgeNSString:dict forKey:@"description"];
        self.status          = [CoStringManager judgeNSInteger:dict forKey:@"status"];
        self.photo2DUrl      = [CoStringManager judgeNSString:dict forKey:@"photo2DUrl"];
        self.photo3DUrl      = [CoStringManager judgeNSString:dict forKey:@"photo3DUrl"];
        self.roomStyleCode   = [CoStringManager judgeNSString:dict forKey:@"roomStyleCode"];
        self.bedRoomNum      = [CoStringManager judgeNSString:dict forKey:@"bedRoomNum"];
        self.livingRoomNum   = [CoStringManager judgeNSString:dict forKey:@"livingRoomNum"];
        self.bathRoomNum     = [CoStringManager judgeNSString:dict forKey:@"bathRoomNum"];
        self.provinceId      = [CoStringManager judgeNSString:dict forKey:@"provinceId"];
        self.provinceName    = [CoStringManager judgeNSString:dict forKey:@"provinceName"];
        self.cityId          = [CoStringManager judgeNSString:dict forKey:@"cityId"];
        self.cityName        = [CoStringManager judgeNSString:dict forKey:@"cityName"];
        self.districtId      = [CoStringManager judgeNSString:dict forKey:@"districtId"];
        self.districtName    = [CoStringManager judgeNSString:dict forKey:@"districtName"];
        self.communityName   = [CoStringManager judgeNSString:dict forKey:@"communityName"];
        self.caseId_design   = [CoStringManager judgeNSInteger:dict forKey:@"caseId"];
        self.storageStatus   = [CoStringManager judgeNSInteger:dict forKey:@"storageStatus"];
        self.channel         = [CoStringManager judgeNSString:dict forKey:@"channel"];
        self.display         = [CoStringManager judgeNSInteger:dict forKey:@"display"];
        self.caseCover       = [CoStringManager judgeNSString:dict forKey:@"caseCover"];
        self.houseType       = [CoStringManager judgeNSString:dict forKey:@"houseType"];
        self.brilliant       = [CoStringManager judgeNSInteger:dict forKey:@"brilliant"];
        self.caseCover       = [CoStringManager judgeNSString:dict forKey:@"caseCover"];
        self.houseType       = [CoStringManager judgeNSString:dict forKey:@"houseType"];
        self.caseType        = [CoStringManager judgeNSString:dict forKey:@"caseType"];
        self.specialTag      = [CoStringManager judgeNSString:dict forKey:@"specialTag"];
        self.houseQuote      = [CoStringManager judgeNSString:dict forKey:@"houseQuote"];
        self.collectStatus   = [CoStringManager judgeNSInteger:dict forKey:@"collectStatus"];
        self.designerId      = [CoStringManager judgeNSString:dict forKey:@"designerId"];
        self.projectStyle    = [CoStringManager judgeNSString:dict forKey:@"projectStyle"];
        self.roomImages      = [dict objectForKey:@"roomImages"];
        if (dict && [dict objectForKey:@"user"]) {
            self.user   = [ESCaseUserInfo objFromDict:[dict objectForKey:@"user"]];
        }

        if (dict && [dict objectForKey:@"naviPanos"]) {
            self.naviPanos   = [ESCaseNaviPanos objFromDict:[dict objectForKey:@"naviPanos"]];
        }
        
        self.spaceDetails     = [NSMutableArray array];
        if (dict && [[dict objectForKey:@"spaceDetails"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in [dict objectForKey:@"spaceDetails"]) {
                [self.spaceDetails addObject:[ESCaseSpaceDetails objFromDict:dic]];
            }
        }
        
        self.roomImages     = [NSMutableArray array];
        if (dict && [[dict objectForKey:@"roomImages"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in [dict objectForKey:@"roomImages"]) {
                [self.roomImages addObject:[ESCase2DImageModel objFromDict:dic]];
            }
        }
        self.bedroom   = [CoStringManager judgeNSString:dict forKey:@"bedroom"];
        self.roomType   = [CoStringManager judgeNSString:dict forKey:@"roomType"];
        self.restroom   = [CoStringManager judgeNSString:dict forKey:@"restroom"];
        
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseDetailModel *caseDetail = [[ESCaseDetailModel alloc] initWithDict:dict];
    return caseDetail;
}

@end


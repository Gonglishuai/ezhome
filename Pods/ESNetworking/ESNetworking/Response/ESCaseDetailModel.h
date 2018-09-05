//
//  ESCaseDetailModel.h
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESCaseShareModel.h"
#import "ESCaseProductModel.h"
#import "ESDesignerInfoModel.h"
#import "ESCase2DImageModel.h"

#import "ESCaseUserInfo.h"
#import "ESCaseNaviPanos.h"
#import "ESCaseSpaceDetails.h"

/*
 {
 id (string, optional): 案例ID ,
 caseUrl (string, optional): 案例H5url ,
 caseName (string, optional): 案例名称 ,
 likeCount (integer, optional): 点赞数量 ,
 isMemberLike (boolean, optional): 是否点赞 ,
 contest (string, optional): 比赛 ,
 designerName (string, optional): 设计师名称 ,
 designerId (string, optional): 设计师ID ,
 designerAvatar (string, optional): 设计师头像 ,
 shareInfo (CaseShareDto, optional),
 productList (Array[RecommondProductDto], optional)
 }
 */
@interface ESCaseDetailModel : NSObject

@property (nonatomic, strong) NSString *caseId;       //
@property (nonatomic, strong) NSString *caseUrl;           //
@property (nonatomic, strong) NSString *caseName;         //
@property (nonatomic, assign) NSInteger likeCount; //
@property (nonatomic, assign) BOOL isMemberLike; //
@property (nonatomic, strong) NSString *contest;       //
@property (nonatomic, strong) ESDesignerInfoModel *designerInfo; //
@property (nonatomic, strong) ESCaseShareModel *shareInfo;
@property (nonatomic, strong) NSMutableArray <ESCaseProductModel *>* productList; //要申请退货的商品
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, assign) BOOL showAddFav; //
//详情改版接口
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *roomArea;
@property (nonatomic, copy) NSString *hsDesignId;
@property (nonatomic, copy) NSString *description_design;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *photo2DUrl;
@property (nonatomic, copy) NSString *photo3DUrl;
@property (nonatomic, copy) NSString *roomStyleCode;
@property (nonatomic, copy) NSString *bedRoomNum;
@property (nonatomic, copy) NSString *livingRoomNum;
@property (nonatomic, copy) NSString *bathRoomNum;
@property (nonatomic, copy) NSString *provinceId;
@property (nonatomic, copy) NSString *provinceName;
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *districtId;
@property (nonatomic, copy) NSString *districtName;
@property (nonatomic, copy) NSString *communityName;
@property (nonatomic, assign) NSInteger caseId_design;
@property (nonatomic, assign) NSInteger storageStatus;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, assign) NSInteger display;
@property (nonatomic, copy) NSString *caseCover;
@property (nonatomic, copy) NSString *houseType;
@property (nonatomic, assign) NSInteger brilliant;
@property (nonatomic, copy) NSString *caseType;
@property (nonatomic, copy) NSString *specialTag;
@property (nonatomic, copy) NSString *houseQuote;
@property (nonatomic, assign) NSInteger collectStatus;
@property (nonatomic, strong) ESCaseUserInfo *user;
@property (nonatomic, strong) ESCaseNaviPanos *naviPanos;
@property (nonatomic, strong) NSMutableArray <ESCaseSpaceDetails *>* spaceDetails;
@property (nonatomic, strong) NSMutableArray <ESCase2DImageModel *>* roomImages;
@property (nonatomic, copy) NSString *bedroom;
@property (nonatomic, copy) NSString *roomType;
@property (nonatomic, copy) NSString *restroom;
@property (nonatomic, copy) NSString *designerId;
@property (nonatomic, copy) NSString *projectStyle;

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end


//
//  JRDesignInfomodel.h
//  Consumer
//
//  Created by jiang on 2017/5/5.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESBaseModel.h"
#import "JRDesignOrderInfomodel.h"
#import "ESDesignProject3DCase.h"
/*
 Response:
 {
 "consumerName": "数据库啦放假",
 "consumerMobile": "18910331608",
 "consumerUid": "62bdc385-bc61-4963-ac0d-90ab1811ef7c",
 "consumerId": "20742805",
 "consumerAvatar": null,
 "contactsMobile": "18910331608",
 "contactsName": "数据库啦放假",
 "houseArea": "200",
 "province": 110000,
 "provinceName": "北京",
 "city": 110100,
 "cityName": "北京市",
 "district": 110102,
 "districtName": "西城区",
 "decorationBudget": "10万元-15万元",
 "publishTime": 1508221171000,
 "auditDesc": null,
 "auditer": "方志刚",
 "bookingStatus": 1,
 "designStyle": "country,mediterranean",
 "selectedType": 6,
 "dispatchType": 6,
 "selectedDesignerUid": null,
 "selectedDesignerId": null,
 "selectedDesignerName": null,
 "selectedDesignerAvatar": null,
 "dispatchDesignerUid": null,
 "dispatchDesignerId": null,
 "dispatchDesignerName": null,
 "dispatchDesignerAvatar": null,
 "order": null,
 "customStringStatus": 57,
 "channel": "web",
 "contest": "812",
 "store": null,
 "submit": null,
 "houseType": "1",
 "designAssetId": 1909520,
 "beishu": "0",
 "publicOrNot": "0",
 "customStringSource": "0",
 "customStringPayment": null,
 "communityName": null,
 "customStringQuote": null,
 "customStringSendedTime": null,
 "detailDesc": null,
 "deleteStatus": 0,
 "consumerJMemberId": "65810753084456960",
 "selectedDesignerJMemberId": null,
 "dispatchDesignerJMemberId": null
 }
 
 */
@interface JRDesignInfomodel : ESBaseModel
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *auditer;
@property (nonatomic, strong) NSMutableArray <JRDesignOrderInfomodel *> * order;    //订单列表
@property (nonatomic, copy) NSString *communityName;
@property (nonatomic, copy) NSString *consumerName;
@property (nonatomic, copy) NSString *consumerAvatar;
@property (nonatomic, copy) NSString *consumerMobile;
@property (nonatomic, copy) NSString *houseArea;
@property (nonatomic, copy) NSString *houseType;
@property (nonatomic, copy) NSString *decorationBudget;
@property (nonatomic, copy) NSString *provinceName;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *districtName;
@property (nonatomic, copy) NSString *selectedType;
@property (nonatomic, copy) NSString *dispatchType;
@property (nonatomic, copy) NSString *designStyle;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *bookingStatus;
@property (nonatomic, copy) NSString *auditDesc;
@property (nonatomic, copy) NSString *consumerUid;
@property (nonatomic, copy) NSString *consumerId;
@property (nonatomic, copy) NSString *detailDesc;
@property (nonatomic, copy) NSString *designAssetId;
@property (nonatomic, copy) NSString *wkTemplateId;
@property (nonatomic, copy) NSString *workflowId;
@property (nonatomic, copy) NSString *workflowStepId;
@property (nonatomic, copy) NSString *projectStatus;
@property (nonatomic, copy) NSString *projectType;
@property (nonatomic, copy) NSString *projectStartTime;
@property (nonatomic, copy) NSString *dispatchDesignerUid;
@property (nonatomic, copy) NSString *dispatchDesignerId;
@property (nonatomic, copy) NSString *dispatchDesignerName;
@property (nonatomic, copy) NSString *dispatchDesignerAvatar;
@property (nonatomic, copy) NSString *dispatchDesignerThreadId;
@property (nonatomic, copy) NSString *selectedDesignerUid;
@property (nonatomic, copy) NSString *selectedDesignerId;
@property (nonatomic, copy) NSString *selectedDesignerName;
@property (nonatomic, copy) NSString *selectedDesignerAvatar;
@property (nonatomic, copy) NSString *selectedDesignerThreadId;
@property (nonatomic, copy) NSString *customKeys;
@property (nonatomic, copy) NSString *mainProjrctId;
@property (nonatomic, copy) NSString *termnatedStatus;

@property (nonatomic, strong) NSMutableArray <ESDesignProject3DCase *>*d3Cases;//3d案例
@property (nonatomic, strong) NSString *channel;//来源
@property (nonatomic, strong) NSString *contest;//大赛标识
@property (nonatomic, strong) NSString *store;//店面code

@property (nonatomic, copy) NSString *deleteStatus;
@property (nonatomic, copy) NSString *consumerJMemberId;
@property (nonatomic, copy) NSString *selectedDesignerJMemberId;
@property (nonatomic, copy) NSString *dispatchDesignerJMemberId;
@property (nonatomic, copy) NSString *beishu;
@property (nonatomic, copy) NSString *projectNum;
@property (nonatomic, copy) NSString *showPayButton;
@end


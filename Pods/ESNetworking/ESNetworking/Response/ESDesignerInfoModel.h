//
//  ESDesignerInfoModel.h
//  Consumer
//
//  Created by jiang on 2017/11/15.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

//#import <ESNetworking/ESBaseModel.h>
#import "ESBaseModel.h"

@interface ESDesignerInfoModel : ESBaseModel
@property (nonatomic,copy)NSString *styleNames;
@property (nonatomic,copy)NSString *measurementPrice;
@property (nonatomic,copy)NSString *designPriceMin;
@property (nonatomic,copy)NSString *designPriceMax;

@property (nonatomic,copy)NSString *experience;
@property (nonatomic,copy)NSString *avatar;
@property (nonatomic,copy)NSString *isRealName;
@property (nonatomic,copy)NSString *nickName;

@property (nonatomic,copy)NSString *isFollowing;
@property (nonatomic,copy)NSString *isBindDecoration;
@property (nonatomic,copy)NSString *follows;
@property (nonatomic,copy)NSString *designPrice;
@property (nonatomic,copy)NSString *jmemberId;
@property (nonatomic,copy)NSString *commentCount;
@property (nonatomic,copy)NSString *commentScores;

///是否为签约设计师 1:是签约设计师
@property (nonatomic,copy)    NSString *isContract;
@end

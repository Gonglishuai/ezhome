//
//  ESCMSModel.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESCMSExtendModel.h"

@interface ESCMSModel : NSObject

@property (nonatomic, strong) NSString *operation_type;
@property (nonatomic, strong) ESCMSExtendModel *extend_dic;

+ (instancetype)objFromDict:(NSDictionary *)dict;

+ (NSDictionary *)dictFromObj:(ESCMSModel *)object;
@end

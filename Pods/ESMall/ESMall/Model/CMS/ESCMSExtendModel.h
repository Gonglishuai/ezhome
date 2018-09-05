//
//  ESCMSExtendModel.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCMSExtendModel : NSObject

@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *resourceId;

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end

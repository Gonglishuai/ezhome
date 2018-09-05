//
//  JRBaseSHModel.h
//  Consumer
//
//  Created by 姜云锋 on 17/4/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SHModel.h"

@interface JRBaseSHModel : SHModel //需要SHModel里方法的模型，可继承此model，不太建议使用

+ (id)createModelWithDic:(NSDictionary *)dic;
- (id)initWithDic:(NSDictionary *)dic;
@end

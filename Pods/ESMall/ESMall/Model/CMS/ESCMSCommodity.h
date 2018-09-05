//
//  ESCMSCommodity.h
//  Mall
//
//  Created by 焦旭 on 2017/9/10.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESCMSModel.h"

@interface ESCMSCommodity : NSObject
@property (nonatomic, strong) NSString *mainTitle;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSArray <ESCMSModel *> *elementList;

@end

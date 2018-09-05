//
//  ESCMSCommodity.m
//  Mall
//
//  Created by 焦旭 on 2017/9/10.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCMSCommodity.h"
#import "ESModel.h"

@implementation ESCMSCommodity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"elementList" : [ESCMSModel class]};
}
@end

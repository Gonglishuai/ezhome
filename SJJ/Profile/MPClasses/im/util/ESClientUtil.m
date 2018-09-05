//
//  ESClientUtil.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESClientUtil.h"

@implementation ESClientUtil

+ (NSString *)clientName:(NIMLoginClientType)clientType {
    switch (clientType) {
        case NIMLoginClientTypeAOS:
        case NIMLoginClientTypeiOS:
        case NIMLoginClientTypeWP:
            return @"移动";
        case NIMLoginClientTypePC:
        case NIMLoginClientTypemacOS:
            return @"电脑";
        case NIMLoginClientTypeWeb:
            return @"网页";
        default:
            return @"";
    }
}

@end

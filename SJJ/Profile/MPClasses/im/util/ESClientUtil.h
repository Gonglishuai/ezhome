//
//  ESClientUtil.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

@interface ESClientUtil : NSObject

+ (NSString *)clientName:(NIMLoginClientType)clientType;

@end

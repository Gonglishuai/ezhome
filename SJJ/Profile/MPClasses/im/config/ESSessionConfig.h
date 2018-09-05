//
//  ESSessionConfig.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSessionConfig.h"

@interface ESSessionConfig : NSObject<NIMSessionConfig>

@property (nonatomic,strong) NIMSession *session;
@property (nonatomic, assign) BOOL isManufacturer;

@end

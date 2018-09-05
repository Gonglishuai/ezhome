//
//  ESSubscribeManager.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "ESSubscribeDefine.h"

@interface ESSubscribeManager : NSObject

+ (instancetype)sharedManager;

- (void)start;

- (NSDictionary<NIMSubscribeEvent *, NSString *> *)eventsForType:(NSInteger)type;

- (void)subscribeTempUserOnlineState:(NSString *)userId;

- (void)unsubscribeTempUserOnlineState:(NSString *)userId;

@end

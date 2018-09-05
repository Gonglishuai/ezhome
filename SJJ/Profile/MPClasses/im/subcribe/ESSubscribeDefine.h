//
//  ESSubscribeDefine.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#ifndef ESSubscribeDefine_h
#define ESSubscribeDefine_h

extern NSString *const ESSubscribeNetState;

extern NSString *const ESSubscribeOnlineState;

typedef NS_ENUM(NSInteger, ESCustomStateValue) {
    ESCustomStateValueOnlineExt = 10001,
};


typedef NS_ENUM(NSInteger, ESOnlineState){
    ESOnlineStateNormal, //在线
    ESOnlineStateBusy,   //忙碌
    ESOnlineStateLeave,  //离开
};

#endif /* ESSubscribeDefine_h */

//
//  ESNIMManager.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESIMSource) {
    ESIMSourceNone,
    ESIMSourceCaseDetail,       //案例详情
    ESIMSourceDesignerHome,     //设计师主页
    ESIMSourceProjectDetail,    //项目详情页
    ESIMSourceProductDetail,    //商品详情
};

@protocol ESNIMManagerDelegate <NSObject>

/**
 是否有新消息
 */
- (void)hasNewMessage:(BOOL)newMsg;

@end
@interface ESNIMManager : NSObject

/**
 会话发起来源
 */
@property (nonatomic, strong) NSDictionary *source;

@property (nonatomic, assign) BOOL isLogined;

@property (nonatomic, weak) id<ESNIMManagerDelegate> delegate;

+ (instancetype)sharedManager;

/**
 初始化云信
 */
- (void)initNIM;

/**
 更新APNs DeviceToken

 @param deviceToken apns设备token
 */
- (void)updateApnsToken:(NSData *)deviceToken;

/**
 获取所有会话未读数

 @return 未读数
 */
- (NSInteger)getNIMAllUnreadCount;

/**
 自动登录
 */
- (void)autoLogin;

/**
 手动登录
 */
- (void)manualLogin;

/**
 登出云信
 */
- (void)logout;

/**
 点对点聊天

 @param viewController
 @param j_member_id
 @param source
 */
+ (void)startP2PSessionFromVc:(UIViewController *)viewController
                withJMemberId:(NSString *)j_member_id
                    andSource:(ESIMSource) source;

/**
 开启点对点聊天会话

 @param viewController
 @param hs_uid uid
 */
+ (void)startP2PSessionFromVc:(UIViewController *)viewController
                      withUid:(NSString *)hs_uid
                    andSource:(ESIMSource) source;
/**
 商城咨询
 
 @param viewController
 @param dealerId 经销商id
 */
+ (void)startP2PSessionFromVc:(UIViewController *)viewController
                 withDealerId:(NSString *)dealerId
                    andSource:(ESIMSource) source;

- (void)addESIMDelegate:(id<ESNIMManagerDelegate>)delegate;
- (void)removeESIMDelegate:(id<ESNIMManagerDelegate>)delegate;
@end

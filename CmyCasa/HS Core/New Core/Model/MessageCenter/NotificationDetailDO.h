//
//  NotificationDetailDO.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "BaseResponse.h"

@class FollowUserInfo;
@class NotificationDesignInfoDO;
@class NotificationContentDO;

@interface NotificationDetailDO : NSObject<RestkitObjectProtocol>

@property (nonatomic, strong) NotificationContentDO *noticeContent;
@property (nonatomic, strong) FollowUserInfo *fromUser;
@property (nonatomic, strong) NotificationDesignInfoDO *designInfo;
@property (nonatomic, strong) FollowUserInfo *replyeeInfo;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *noticeType;

@end


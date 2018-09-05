//
//  ESIMCustomSysNotificationSender.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

#define ESNotifyID        @"id"
#define ESCustomContent   @"content"
#define ESTeamMeetingMembers   @"members"
#define ESTeamMeetingTeamId    @"teamId"
#define ESTeamMeetingTeamName  @"teamName"
#define ESTeamMeetingName      @"room"

#define ESCommandTyping   (1)
#define ESCustom          (2)
#define ESTeamMeetingCall (3)

@interface ESIMCustomSysNotificationSender : NSObject
- (void)sendCustomContent:(NSString *)content toSession:(NIMSession *)session;

- (void)sendTypingState:(NIMSession *)session;

- (void)sendCallNotification:(NSString *)teamId
                    roomName:(NSString *)roomName
                     members:(NSArray *)members;
@end

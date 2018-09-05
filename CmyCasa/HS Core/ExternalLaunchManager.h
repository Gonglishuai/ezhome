//
//  ExternalLaunchManager.h
//  Homestyler
//
//  Created by Dor Alon on 6/18/13.
//
//

#import <Foundation/Foundation.h>
#import "PushDataBaseDO.h"
#define ANONIMUS_EMAIL_FORPN @"anonimus"


#define kInitialReminderKey     @"initialReminder"
#define kPeriodicalReminderKey  @"periodicalReminder"

typedef enum ScreenRequestTypes
{
    eScreenTypeFullScreen =  1,
    eScreenTypeProfile =  2,
    eScreenTypeProfessional= 3
} ScreenRequestType;



@interface ExternalLaunchManager : NSObject
{
    NSString* _pushNotificationToken;
}

+ (id) sharedInstance;
- (void) launchedFromUrl: (NSString*)url;
- (void) launchedFromPushNotification:(NSDictionary *) data;
- (void) launchedFromLocalNotification:(UILocalNotification*)notification;
- (void) setPushNotificationToken:(NSString *) pushNotificationToken;
- (PushDataBaseDO *)pushedObjectFromDictionary:(NSDictionary *)data;
- (void)checkRegistration;
- (void) registerNoSession;
- (void) registerWithSession;
- (void) unregisterSession:(BOOL)usingSession;
- (void)TestCases;

@property (nonatomic,strong) NSString * externalLinkID;
@property (nonatomic,strong) NSString * externalLinkType;
@property (nonatomic) ScreenRequestType screenRequestType;
@property (nonatomic,strong)PushDataBaseDO * lastPush;
@end

//
//  ExternalLaunchManager.m
//  Homestyler
//
//  Created by Dor Alon on 6/18/13.
//
//

#import "ExternalLaunchManager.h"
#import "PushDataBaseDO.h"
#import "NSObject+Flurry.h"
#import "CoreRO.h"
#import "NSString+Contains.h"
@implementation ExternalLaunchManager

static ExternalLaunchManager *sharedInstance = nil;

///////////////////////////////////////////////////////////////////////////////

+ (ExternalLaunchManager *)sharedInstance {
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[ExternalLaunchManager alloc] init];
        
    });
    
    return sharedInstance;
}
///////////////////////////////////////////////////////////////////////////////

- (void) launchedFromUrl: (NSString*)url {
    
    NSMutableDictionary * event=[NSMutableDictionary dictionaryWithCapacity:0];
    [event setObject:@"email" forKey:@"link_source"];
    if (url) {
        [event setObject:url forKey:@"link_url"];
    }
    
    [sharedInstance logFlurryEvent:FLURRY_EXTERNAL_LINKS withParams:[event copy]];
    
    NSURL * ur=[NSURL URLWithString:url];
    NSArray* params = [[ur query] componentsSeparatedByString:@"&"];
    //  NSString* itemType = nil;
    //  NSString* itemId = nil;
    
    if ([url rangeOfString:@"userprofile"].location!=NSNotFound) {
        for(NSString* param in params)
        {
            NSArray* keyVal = [param componentsSeparatedByString:@"="];
            NSString* key = [keyVal objectAtIndex:0];
            NSString* val = [keyVal objectAtIndex:1];
            
            
            if ([key isEqualToString:@"uid"]) {
                //open profile page
                self.lastPush=[[PushDataBaseDO alloc] init];
                self.lastPush.itemID=[val substringToIndex:[val rangeOfString:@"_utype_"].location];
                
                NSString * type=[val substringFromIndex:[val rangeOfString:@"_utype_"].location+7];
                //fix ids
                if ([type isEqualToString:@"1"]) {
                    self.screenRequestType=eScreenTypeProfile;
                    
                }else if([type isEqualToString:@"2"]){
                    
                    self.screenRequestType=eScreenTypeProfessional;
                }
                if (self.lastPush.itemID) {
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification" object:nil];
                    break;
                }
            }
        }
        
        return;
    }
    
    
    if ([url rangeOfString:@"gallerystream"].location!=NSNotFound ||
        [url rangeOfString:@"open"].location!=NSNotFound) {
        
        for(NSString* param in params)
        {
            NSArray* keyVal = [param componentsSeparatedByString:@"="];
            NSString* key = [keyVal objectAtIndex:0];
            NSString* val = [keyVal objectAtIndex:1];
            
            if ([key isEqualToString:@"id"]) {
                
                //split the string into type and id
                if ([val rangeOfString:@"_type_"].location!=NSNotFound) {
                    self.lastPush=[[PushDataBaseDO alloc] init];
                    self.screenRequestType=eScreenTypeFullScreen;
                    self.lastPush.itemID=[val substringToIndex:[val rangeOfString:@"_type_"].location];
                    self.lastPush.assetType = [val substringFromIndex:[val rangeOfString:@"_type_"].location+6];
                    
                    if (self.lastPush.assetType != nil &&  self.lastPush.itemID != nil) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification" object:nil];
                        break;
                    }
                }
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
-(void)checkRegistration{
    //never logged in from this device
    if (_pushNotificationToken==nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                       if ( [[UserManager sharedInstance] isLoggedIn]== NO) {
                           [self registerNoSession];
                       }else{
                           
                           [self registerWithSession];
                       }
                   });
}

///////////////////////////////////////////////////////////////////////////////
- (void) setPushNotificationToken:(NSString *) pushNotificationToken {
    _pushNotificationToken = pushNotificationToken;
}

///////////////////////////////////////////////////////////////////////////////
-(PushDataBaseDO*)pushedObjectFromDictionary:(NSDictionary*)data{
    
    if (!data) {
        return nil;
    }
    
    if (![data objectForKey:@"aps"]) {
        return nil;
    }
    id alert = [[data objectForKey:@"aps"] objectForKey:@"alert"];
    
    if ([alert isKindOfClass:[NSString class]] && [NSString isNullOrEmpty:alert] ) {
        return nil;
    }
    
    if ([alert isKindOfClass:[NSDictionary class]] && [[alert allKeys] count]==0) {
        return nil;
    }
    
    NSMutableArray * dataarray = [data objectForKey:@"data"];
    
    PushDataBaseDO *p = [[PushDataBaseDO alloc] init];
    
    if ([alert isKindOfClass:[NSString class]]) {
        [p setupDataObject:dataarray andArgs:nil forType:PUSH_MESSAGE_GENERAL_UNDEFINED];
        [p setCustomAlertMessage:alert];
    }
    
    if ([alert isKindOfClass:[NSDictionary class]]) {
        
        if (![alert objectForKey:@"loc-key"]) {
            return nil;
        }
        NSMutableArray *loc_args=([alert objectForKey:@"loc-args"]==[NSNull null])?nil:[alert objectForKey:@"loc-args"];
        
        [p setupDataObject:dataarray andArgs:loc_args forType:[alert objectForKey:@"loc-key"]];
    }
    
    
    
    return p;
}


- (void) launchedFromPushNotification:(NSDictionary *) data {
    
    PushDataBaseDO * push=nil;
    push=[self pushedObjectFromDictionary:data];
    if (push) {
        
        NSMutableDictionary * event=[NSMutableDictionary dictionaryWithCapacity:0];
        [event setObject:@"push" forKey:@"link_source"];
        [event setObject:push.pushType forKey:@"push_type"];
        
        if (push.itemID) {
            [event setObject:push.itemID forKey:@"item_id"];
        }
        
        if (push.assetType) {
            [event setObject:push.assetType forKey:@"item_type"];
        }
        
        [sharedInstance logFlurryEvent:FLURRY_EXTERNAL_LINKS withParams:[event copy]];
        
        self.lastPush=push;
        NSString * alertOnlyMessage=nil;
    
        if ([push.pushType isEqualToString:PUSH_MESSAGE_LIKED_ASSET] ||
            [push.pushType isEqualToString:PUSH_MESSAGE_GENERAL_NOTIFICATION]
            || [push.pushType isEqualToString:PUSH_MESSAGE_PRIVATE]
            || [push.pushType isEqualToString:PUSH_MESSAGE_GENERAL_UNDEFINED]) {
            alertOnlyMessage=[push generateUserMessage];
        }
        
        if ([push.pushType isEqualToString:PUSH_MESSAGE_COMMENT] || [push.pushType isEqualToString:PUSH_MESSAGE_COMMENT_UPDATE]) {
            //open full screen with comment
            if (push.itemID != nil && push.assetType != nil) {
                self.screenRequestType=eScreenTypeFullScreen;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification" object: [NSDictionary dictionaryWithObject:@"yes" forKey:@"comment"]];
            }
        }
        
        if ([push.pushType isEqualToString:PUSH_MESSAGE_FEATURED] || [push.pushType isEqualToString:PUSH_MESSAGE_PUBLISHED_ASSET]) {
            //open full screen without comment
            
            if (push.itemID != nil && push.assetType != nil) {
                self.screenRequestType=eScreenTypeFullScreen;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification" object:nil];
                
                
                alertOnlyMessage=[push generateUserMessage];
            }
            
        }
        
        if ([push.pushType isEqualToString:PUSH_MESSAGE_FOLLOW]) {
            
            //open full screen with
            if (push.itemID != nil ) {
                self.screenRequestType=eScreenTypeProfile;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification" object:nil];
                
                alertOnlyMessage=[push generateUserMessage];
            }
        }

        if (alertOnlyMessage) {
            [[[UIAlertView alloc]initWithTitle:@"" message:alertOnlyMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
        }
    }
}

- (void) launchedFromLocalNotification:(UILocalNotification*)notification {
    NSDictionary * userInfo = notification.userInfo;
    
    BOOL isInitialReminder = [[userInfo objectForKey:@"initialReminderUserInfoKey"] boolValue];
    
    if (isInitialReminder) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification"
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:@(YES) forKey:kInitialReminderKey]];
        return;
    }
    
    BOOL isPeriodicalReminder = [[userInfo objectForKey:@"periodicalReminderUserInfoKey"] boolValue];
    
    if (isPeriodicalReminder) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLFromExternalLinkNotification"
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:@(YES) forKey:kPeriodicalReminderKey]];
        return;
    }
}

///////////////////////////////////////////////////////////////////////////////
- (void) registerNoSession {
    
    if ([UserSettingsPreferences isUserForcedToDisablePushNotifications:ANONIMUS_EMAIL_FORPN]==YES) {
        return;
    }else{
        [[[UserManager sharedInstance]genericPreferences] setReceiveingPushNotificationsEnabled:YES forEmail:ANONIMUS_EMAIL_FORPN];
        
    }
    if (_pushNotificationToken==nil) {
        return;
    }
    
    [[CoreRO new] registerDeviceForPushes:_pushNotificationToken useSessionId:NO completionBlock:^(id serverResponse) {
        
        if (serverResponse==nil) {
            HSMDebugLog(@"registerNoSession status= FAILED, no server response");
        }else{
            BaseResponse * response=(BaseResponse*)serverResponse;
            if (response.errorCode==-1) {
                HSMDebugLog(@"registerNoSession status= SUCCESS");
            }else{
                HSMDebugLog(@"registerNoSession status= FAILED with server error");
            }
        }
    } failureBlock:^(NSError *error) {
        HSMDebugLog(@"registerNoSession status= FAILED with server network error");
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void) registerWithSession {
    
    if ([[UserManager sharedInstance] isLoggedIn]) {
        if ([UserSettingsPreferences isUserForcedToDisablePushNotifications:[[[UserManager sharedInstance]currentUser]userEmail]]==YES) {
            return;
        }
    }
    
    if (_pushNotificationToken==nil) {
        return;
    }
    
    [[CoreRO new] registerDeviceForPushes:_pushNotificationToken useSessionId:YES completionBlock:^(id serverResponse) {
        
        if (serverResponse==nil) {
            HSMDebugLog(@"registerSession status= FAILED, no server response");
        }else{
            BaseResponse * response=(BaseResponse*)serverResponse;
            if (response.errorCode==-1) {
                HSMDebugLog(@"registerSession status= SUCCESS");
            }else{
                HSMDebugLog(@"registerSession status= FAILED with server error");
            }
        }
    } failureBlock:^(NSError *error) {
        HSMDebugLog(@"registerSession status= FAILED with server network error");
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void) unregisterSession:(BOOL)usingSession {
    
    if (_pushNotificationToken == nil) {
        return;
    }
    
    [[CoreRO new] unregisterDeviceForPushes:_pushNotificationToken useSessionId:usingSession completionBlock:^(id serverResponse) {
        
        if (serverResponse==nil) {
            HSMDebugLog(@"registerSession status= FAILED, no server response");
        }else{
            BaseResponse * response=(BaseResponse*)serverResponse;
            if (response.errorCode==-1) {
                HSMDebugLog(@"unregisterSession status= SUCCESS");
            }else{
                HSMDebugLog(@"unregisterSession status= FAILED with server error");
            }
        }
    } failureBlock:^(NSError *error) {
        HSMDebugLog(@"unregisterSession status= FAILED with server network error");
        
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

///////////////////////////////////////////////////////////////////////////////
-(void)TestCases{
    
    int testype=2;
    
    switch (testype) {
        case 0:
        {
            //Generic Push
            
            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_GENERAL_NOTIFICATION forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"New version is available on appstore!", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            [self launchedFromPushNotification:[request copy]];
            
        }
            break;
        case 1:
        {
            //MESSAGE_LIKED_ASSET
            /*
             {
             appId = 1000;
             aps =     {
             alert =         {
             "loc-args" =             (
             Gil,
             "push test"
             );
             "loc-key" = "MESSAGE_LIKED_ASSET";
             };
             };
             data =     (
             A34S9X8HHV6AJNT,
             MDEE2E5HDMT7WTW,
             1
             );
             */
            
            
            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_LIKED_ASSET forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"Gil",@"push test", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            
            NSMutableArray * data=[NSMutableArray arrayWithObjects:@"A34S9X8HHV6AJNT",@"MDEE2E5HDMT7WTW",@"1", nil];
            
            [request setObject:data forKey:@"data"];
            [self launchedFromPushNotification:[request copy]];
            
        }
            break;
            
        case  2:
        {//message comment
            /*
             Push: 10/07/13 17:57 {
             appId = 1000;
             aps =     {
             alert =         {
             "loc-args" =             (
             test102,
             Fjdtthhb
             );
             "loc-key" = "MESSAGE_COMMENT";
             };
             };
             data =     (
             AUCKD9JHIWIDJS7,
             MKBJXJ2HHVOGTOE,
             1
             );
             }
             */

            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_COMMENT forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"test102",@"Fjdtthhb", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            
            NSMutableArray * data=[NSMutableArray arrayWithObjects:@"AUCKD9JHIWIDJS7",@"MKBJXJ2HHVOGTOE",@"1", nil];
            
            [request setObject:data forKey:@"data"];
            [self launchedFromPushNotification:[request copy]];
        }
            break;
            
        case  3:
        {
            //message_featured
            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_FEATURED forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"push test", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            
            NSMutableArray * data=[NSMutableArray arrayWithObjects:@"A34S9X8HHV6AJNT",@"1", nil];
            
            [request setObject:data forKey:@"data"];
            [self launchedFromPushNotification:[request copy]];
        }
            break;
            
        case  4:
        {
            //message follow
            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_FOLLOW forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"Gil", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            
            NSMutableArray * data=[NSMutableArray arrayWithObjects:@"MDEE2E5HDMT7WTW", nil];
            
            [request setObject:data forKey:@"data"];
            [self launchedFromPushNotification:[request copy]];
        }
            break;
            
        case  5:
        {
            //PUSH_MESSAGE_PUBLISHED_ASSET
            
            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_PUBLISHED_ASSET forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"Gil",@"push test", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            
            NSMutableArray * data=[NSMutableArray arrayWithObjects:@"A34S9X8HHV6AJNT",@"MDEE2E5HDMT7WTW",@"1", nil];
            
            [request setObject:data forKey:@"data"];
            [self launchedFromPushNotification:[request copy]];
        }
            break;
            
        case  6:
        {
            //PUSH_MESSAGE_PRIVATE
            
            NSMutableDictionary * aps=[NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableDictionary * alert_params=[NSMutableDictionary dictionaryWithCapacity:0];
            [alert_params setObject:PUSH_MESSAGE_PRIVATE forKey:@"loc-key"];
            [alert_params setObject:[NSMutableArray arrayWithObjects:@"Gil",@"Sends you test message", nil] forKey:@"loc-args"];
            NSMutableDictionary * request=[NSMutableDictionary dictionaryWithCapacity:0];
            [aps setObject:alert_params forKey:@"alert"];
            [request setObject:aps forKey:@"aps"];
            
            NSMutableArray * data=[NSMutableArray arrayWithObjects:@"MDEE2E5HDMT7WTW", nil];
            
            [request setObject:data forKey:@"data"];
            [self launchedFromPushNotification:[request copy]];
        }
            break;
        case 7:
        {
            //test open user profile page
            [sharedInstance launchedFromUrl:@"homestyler://userprofile?uid=MDEE2E5HDMT7WTW"];
            
        }
            break;
        case 8:
        {
            //test open professional profile page
            [sharedInstance launchedFromUrl:@"homestyler://profprofile?uid=MLXU9BZHFL12NZE"];
            
        }
            break;
        case 9:
        {
            //test open professional profile page
            [sharedInstance launchedFromUrl:@"homestyler://gallerystream?id=ALJOOT0HHVOEIGA_type_3"];
            
        }
            break;
            
        default:
            break;
    }
}

@end

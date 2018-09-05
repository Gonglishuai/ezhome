//
//  ApiAction.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/25/13.
//
//

#import <Foundation/Foundation.h>
#import "RKObjectManager.h"

@interface ApiAction : NSObject

-(instancetype)initWithDictionary:(NSDictionary*)dict;
-(instancetype)initWithAction:(NSString*)action
                        https:(BOOL)isHttps
                        cloud:(BOOL)isCloud
                     serverV2:(BOOL)isServerV2;
-(instancetype)initWithAction:(NSString*)action
                    ssoserver:(BOOL)isSSOServer;
-(RKObjectManager*)getManagerForSelfAction;

// The Action is the RestAPI that will be appended to the BaseURL
// which is currently loaded to RestKIT
@property (nonatomic, strong) NSString *action;

// If true, RestKit will use an HTTPS manager/connection
// to download the data.
@property (nonatomic) BOOL isHttps;

// If true, an approach to a clouded URL will be sent prior
// to sending the real URL to the API.
@property (nonatomic) BOOL isCloud;

// If true, the app will not retry to perform data fetch calls upon first
// failure
@property (nonatomic) BOOL retryCallsDisabled;

@property (nonatomic)BOOL isServerV2;

@property (nonatomic)BOOL isSSOServer;

@end

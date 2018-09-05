//
//  ErrorDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 3/11/13.
//
//

#import <Foundation/Foundation.h>
#import "LocalErrorCodes.h"
@interface ErrorDO : NSObject
@property(nonatomic)NSString * errorGuid;
@property(nonatomic)NSString * message;
@property(nonatomic)HSServerErrorCode  errorCode;
@property(nonatomic)NSDate * erroDatetime;
@property(nonatomic)NSInteger  currentRetryCount;
@property(nonatomic)BOOL needSilentLogin;
@property(nonatomic)BOOL needRetry;

-(id)initErrorWithDetails:(NSString*)msg withErrorCode:(HSServerErrorCode)errcode;
@end

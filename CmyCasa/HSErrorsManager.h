//
//  HSErrorsManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 3/11/13.
//
//

#import <Foundation/Foundation.h>
#import "ErrorDO.h"
#import "LocalErrorCodes.h"

#import "BaseResponse.h"
@interface HSErrorsManager : NSObject

+ (id)sharedInstance;
+ (NSString *)GetUUID;
-(NSString*)addErrorFromServer:(ErrorDO*)error  withPrevGuid:(NSString*)_guid;
-(NSString*)getErrorByGuid:(NSString*)guid;
-(NSString*)getErrorByGuidLocalized:(NSString*)guid;
-(HSServerErrorCode)getErrorCodeByGuid:(NSString*)guid;
-(BOOL)needRetryAfterErrorForGuid:(NSString*)guid;


@end

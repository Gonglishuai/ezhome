//
//  BaseResponse.h
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@interface BaseResponse : NSObject <RestkitObjectProtocol>

@property (nonatomic)         NSInteger errorCode;
@property (nonatomic, strong) NSString* errorMessage;
@property (nonatomic, strong) NSString* hsLocalErrorGuid;

+ (RKObjectMapping*)jsonMapping;

@end

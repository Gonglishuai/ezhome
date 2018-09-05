//
//  CacheTimestampResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/30/13.
//
//

#import "BaseResponse.h"
#import "RestkitObjectProtocol.h"
@interface CacheTimestampResponse : BaseResponse<RestkitObjectProtocol>

@property (nonatomic) NSInteger timestamp;

@end

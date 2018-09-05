//
//  VersionControlDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/31/13.
//
//

#import "BaseResponse.h"

@interface VersionControlDO : BaseResponse

@property(nonatomic) BOOL versionUpdateExists;
@property(nonatomic) BOOL versionUpdateRequired;
;
@end

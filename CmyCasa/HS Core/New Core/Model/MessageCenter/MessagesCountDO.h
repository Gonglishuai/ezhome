//
//  MessagesCountDO.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "BaseResponse.h"

@interface MessagesCountDO : BaseResponse

@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger featuredCount;
@property (nonatomic, assign) NSInteger otherCount;
@property (nonatomic, assign) NSInteger allCount;

@end

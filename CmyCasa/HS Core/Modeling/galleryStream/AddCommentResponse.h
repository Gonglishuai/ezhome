//
//  AddCommentResponse.h
//  Homestyler
//
//  Created by Ma'ayan on 12/4/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseResponse.h"

@class CommentDO;

@interface AddCommentResponse : BaseResponse

- (CommentDO *)getComment;

@end

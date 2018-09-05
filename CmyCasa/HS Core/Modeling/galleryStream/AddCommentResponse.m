//
//  AddCommentResponse.m
//  Homestyler
//
//  Created by Ma'ayan on 12/4/13.
//
//

#import "AddCommentResponse.h"
#import "CommentDO.h"

@interface AddCommentResponse ()

@property (nonatomic, strong) CommentDO *myComment;

@end

@implementation AddCommentResponse

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.myComment = [[CommentDO alloc] init];
    }
    
    return self;
}

+(void)initialize
{
    
}

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping *entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"cid" : @"myComment._id",
     @"timestamp" : @"myComment.strTimestamp",
     }];
    
    return entityMapping;
}


- (CommentDO *)getComment
{
    return self.myComment;
}


@end

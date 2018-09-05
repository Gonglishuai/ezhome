//
//  LikeDesignDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/11/13.
//
//

#import "LikeDesignDO.h"
#import "BaseResponse.h"

@implementation LikeDesignDO

@synthesize  designid;
@synthesize likesCount;
@synthesize isUserLiked;

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    // Add most of the mapping
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"lk" : @"likesCount",
     @"id" : @"designid",
     }];
  
    return entityMapping;
}

- (void)applyPostServerActions{  
    self.isUserLiked=YES;
    
}
-(id)init{
    self=[super init];
    self.isUserLiked=NO;
    self.localModified = NO;
    
    return self;
}

-(id)initWithDictionary:(NSDictionary*)dict{
    
    self=[super init];
    self.likesCount=[dict objectForKey:@"lk"];
    self.designid=[dict objectForKey:@"id"];
    return  self;
}

-(id)init:(NSString*) in_id andCount :(NSNumber*) count
{
    self = [super init];
    self.likesCount = count;
    self.designid= in_id;
    return  self;

}

/*
-(void) updateLikesDictionary
{
    
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:designid];
    if(likeDO)
    {
        if(likeDO.localModified == NO)
        {
            likeDO.likesCount = likesCount;
        }
    }
    else {
        [likeDict setObject: self forKey:designid];
    }
}*/

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

-(void)updateUserLikeStatus:(BOOL)isLiked{
    self.isUserLiked=isLiked;
    if(isLiked)
    {
        self.likesCount = [NSNumber numberWithInt:[likesCount intValue] + 1];
    }
    else
    {
        self.likesCount = [NSNumber numberWithInt:[likesCount intValue] - 1];
        
    }
    self.localModified = YES;

}


@end

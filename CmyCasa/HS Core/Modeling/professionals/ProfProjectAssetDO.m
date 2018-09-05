//
//  ProfProjectAssetDO.m
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import "ProfProjectAssetDO.h"
@interface ProfProjectAssetDO  ()

@property(nonatomic)NSString * localId;// used to get design id and override _id

@end

@implementation ProfProjectAssetDO

@synthesize rank;


+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"rnk" :  @"rank",
     @"ai" : @"localId",
     @"url" : @"url",
     @"t" : @"title",
     @"d" : @"description",
     @"uid" : @"uid",
     @"userphoto" : @"uthumb",
     @"pro" : @"isPro",
     @"tp" : @"type",
     @"author" : @"author"  
     
     }];
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    if (self.localId && self._id==nil) {
        self._id=self.localId;
    }
    [super applyPostServerActions];

    self.type = e2DItem;
}

-(void)updateProfessionalID:(NSString*)prid andThumbnail:(NSString*)thumbnail  andProfName:(NSString*)pname{
    self.uid = prid;
    self.uthumb=thumbnail;
    self.author=pname;
}

-(id)initWithDict:(NSDictionary*)dict andProfID:(NSString*)profid{
    self = [super initWithDict:dict];

    if (self) {
        self.isPro=YES;
        self.type=[[dict objectForKey:@"tp"] intValue];
        self.rank=[dict objectForKey:@"rnk"];
        self.uid = profid;
    }

    return self;
}

-(NSNumber*)getTotalCommentsCount{
    
    DesignDiscussionDO *dd=  [[[AppCore sharedInstance] getCommentsManager]getLoadedCommentsForDesignID:self._id];
    
    if (dd!=nil) {
        self.commentsCount=[dd getTotalCommentsCount];
    }
    
    return self.commentsCount;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}



@end

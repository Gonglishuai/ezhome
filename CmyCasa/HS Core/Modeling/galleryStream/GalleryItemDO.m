//
//  GalleryItemDO.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import "GalleryItemDO.h"
#import "DesignRO.h"

@interface GalleryItemDO  ()

@end

@implementation GalleryItemDO
@synthesize isFullyLoaded;

+ (RKObjectMapping*)jsonMapping
{

    

    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"url" : @"url",
     @"t" : @"title",
     @"d" : @"description",
     @"modified" : @"timestamp",
     @"uid" : @"uid",
     @"uthumb" : @"uthumb",
     @"pro" : @"isPro",
     @"tp" : @"type",
     @"author" : @"author",
      @"c" : @"content"
     }];
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    [super applyPostServerActions];
    if (self.type==eEmptyRoom) {
        self.type=e3DItem;
    }
}

-(id)createEmptyDesignWithType:(ItemType)tp{
    
    self.type=tp;
    
    return [super init];
}

-(id)initWithDictionary:(NSMutableDictionary*)dict{
    
    
    self=[super initWithDict:dict];
    
    if ([[dict objectForKey:@"tp"] intValue]==1 || [[dict objectForKey:@"tp"] intValue]==4 ) {
        self.type=e3DItem;
    }
    if ([[dict objectForKey:@"tp"] intValue]==2) {
      self.type=e2DItem;
    }
    if ([[dict objectForKey:@"tp"] intValue]==3) {
        self.type=eArticle;
    }
    
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

-(void)updateDesignItemWithFullData:(NSMutableDictionary*)dict{
    [super updateDesignItemWithFullData:dict];
    
}

-(NSNumber*)getTotalCommentsCount{
    
//  DesignDiscussionDO *dd=  [[[AppCore sharedInstance] getCommentsManager]getLoadedCommentsForDesignID:self._id];
//
//    if (dd!=nil) {
//        self.commentsCount=[dd getTotalCommentsCount];
//    }
    
    return self.commentsCount;
}

-(BOOL)isArticle{
    return self.type==eArticle;
}

-(BOOL)is2DDesign{
      return self.type==e2DItem;
}

-(BOOL)is3DDesign{
       return self.type==e3DItem;
}

-(void)virtualGalleryItemExtraInfo:(BOOL)richData completionBlock:(dictionaryResponseBlock)completeBlock
{
    [[DesignRO new] designGetPublicItem:self._id
                                andType:self.type
                               richData:richData
                          withTimestamp:nil
                        completionBlock:^(id serverResponse)
    {
        
        DesignGetItemResponse * response = (DesignGetItemResponse*)serverResponse;
        if (response && response.errorCode == -1)
        {
            [self updateDesignItemWithResponse:response];
            
            if(completeBlock)
                completeBlock(nil);
        } else {
            if(completeBlock)
                completeBlock(response.hsLocalErrorGuid);
        }
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completeBlock)completeBlock(errguid);
    } queue:dispatch_get_main_queue()];
}


@end

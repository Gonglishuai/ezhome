//
//  MyDesignDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import "MyDesignDO.h"
#import "DesignRO.h"


@interface MyDesignDO ()

@end

@implementation MyDesignDO
@synthesize timestamp;
@synthesize publishStatus;

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"t" : @"timestamp",
       @"u" : @"url",
       @"n" : @"title",
       @"description" : @"_description",
       @"status" : @"publishStatus"
       }];
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    [super applyPostServerActions];
    
    if ([self.title isEqual:[NSNull null]]) {
        self.title=nil;
    }
    
    self.type = e3DItem;
}

- (BOOL)isEqual:(id)other {
    
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToMyDesign:other];
}

- (BOOL)isEqualToMyDesign:(MyDesignDO*)otherMyDesign {
    
    //This method takes into account that _id is uniqe for each design
    if (self._id && otherMyDesign._id) {
        return [self._id isEqualToString:otherMyDesign._id];
    }
    return NO;
}

-(instancetype)initWithDict:(NSDictionary*)dict{
    self = [super initWithDict:dict];
    if (self) {
        NSString * profileImage= [[[UserManager sharedInstance] currentUser] userProfileImage];
        
        if (profileImage !=nil && [profileImage length]>0 && self.uthumb==nil) {
            self.uthumb=profileImage;
        }
        
        timestamp = [dict objectForKey:@"t"];
        self.publishStatus = [[dict objectForKey:@"status"] intValue];
        self.title = [dict objectForKey:@"n"];
        self._description = [dict objectForKey:@"description"];
        self.type = e3DItem;
        self.url = [dict objectForKey:@"u"];
    }
    
    return self;
}

-(MyDesignDO*)duplicate{
    MyDesignDO * d=[[MyDesignDO alloc] init];
    DesignBaseClass* base=(DesignBaseClass*)d;
    
    [base duplicateFromOther:self];
    d._description = self._description;
    d.type = self.type;
    d.timestamp = self.timestamp;
    d.publishStatus = self.publishStatus;
    
    return d;
}

-(BOOL)is3DDesign{
    return self.type==e3DItem;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

-(BOOL)isDesignPublished{
    
    return self.publishStatus==STATUS_PUBLISHED;
}

-(BOOL)isPublicOrPublished{
    
    return [self isDesignPublished] || self.publishStatus==STATUS_PUBLIC;
}

-(NSString*)getAPITimestamp{
    NSString * calltimestamp=[[[AppCore sharedInstance] getHomeManager]getTimestampForAPIKey:kCacheMyProfile];
    
    return calltimestamp;
}

-(void)virtualGalleryItemExtraInfo:(BOOL)richData completionBlock:(dictionaryResponseBlock)completeBlock
{
    NSString * calltimestamp=[self getAPITimestamp];

    [[DesignRO new] designGetPublicItem:self._id andType: self.type richData:richData withTimestamp:calltimestamp completionBlock:^(id serverResponse) {

        DesignGetItemResponse * response=(DesignGetItemResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            [self updateDesignItemWithResponse:response];
            if(completeBlock)completeBlock(nil);
        }else{
            if(completeBlock)completeBlock(response.hsLocalErrorGuid);
        }

    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];

        if(completeBlock)completeBlock(errguid);
    } queue:dispatch_get_main_queue()];
}

-(NSNumber*)getTotalCommentsCount{
    
    return self.commentsCount;
}

- (NSString *)getAutoSavedDesignReference {
    return self.autoSavedDesignRefID;
}

- (void)setupAutoSaveRef:(NSString *)designId {
    
    self.autoSavedDesignRefID = designId;
}

@end

//
//  DesignBaseClass.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import "DesignBaseClass.h"
#import "DesignGetItemResponse.h"

@interface DesignBaseClass  ()


@end

@implementation DesignBaseClass
@synthesize author;
@synthesize commentsCount;
@synthesize productsCount;
@synthesize _description;
@synthesize _id;
@synthesize title;
@synthesize uid;
@synthesize url;
@synthesize uthumb;
@synthesize type;
@synthesize isPro;
@synthesize uname;
@synthesize roomType;
@synthesize images;
@synthesize content;
@synthesize isFullyLoaded;
@synthesize backgroundImageURL;
@synthesize originalImageURL;
@synthesize editedImageURL;
@synthesize maskImageURL;

@synthesize requestIsActive;


+ (RKObjectMapping*)jsonMapping
{
  
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"_id", 
     @"lk" : @"tempLikeCount",
     @"cmt" : @"commentsCount",
     @"pcnt" : @"productsCount"
     }];
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    if (self._id==nil) {
        return;
    }
 
    LikeDesignDO*like= [[LikeDesignDO alloc] init];
    
    like.designid=self._id;
    like.likesCount=self.tempLikeCount;
    
    [[[AppCore sharedInstance] getGalleryManager]addOrUpdateLikeData:like];
 
    
}

-(void)updateDesignItemWithResponse:(DesignGetItemResponse*)response{
    
    self.uname=response.uname;
    self.roomType=response.roomType;
    self._id=response._id;
    self.commentsCount=response.commentsCount;
    self.productsCount=response.productsCount;

    self.publishStatus = response.publishStatus;
    self.timestamp = response.timestamp;

    if (self.title==nil) {
        self.title=response.title;
    }
    
    if (self.author==nil) {
        self.author=response.author;
    }
    
    if (self.uthumb==nil) {
        self.uthumb=response.uthumb;
    }
    
    if (self.uid==nil) {
        self.uid=response.uid;
    }
    if (self._description==nil) {
        self._description=response._description;
    }
    self.images=response.images;
    self.maskImageURL=([response.maskImageURL length]>0)?response.maskImageURL:nil;
    self.url=response.url;
    self.backgroundImageURL=response.backgroundImageURL;
    self.originalImageURL=response.originalImageURL;
    self.editedImageURL=response.editedImageURL;
    self.content=response.content;
    self.isFullyLoaded=YES;
    self.requestIsActive=NO;
}


-(id)initWithDict:(NSDictionary*)dict{
    self=[super init];
    [self fillDataFromDict:dict];
   
    maskImageURL = nil;
    return self;
}

-(void)fillDataFromDict:(NSDictionary*)dict{
    self.author=[dict objectForKey:@"author"];
    if (self.author==nil && [dict objectForKey:@"uname"]!=nil) {
        self.author=[dict objectForKey:@"uname"];
    }
    self.commentsCount=[dict objectForKey:@"cmt"];
    
    self.productsCount = [dict objectForKey:@"pcnt"];
    
    
    
    self._description=[dict objectForKey:@"d"];
    if ([dict objectForKey:@"id"]) {
        self._id=[dict objectForKey:@"id"]; 
    }
    
   LikeDesignDO* like= [[LikeDesignDO alloc] initWithDictionary:(NSDictionary*)dict];
   [[[AppCore sharedInstance] getGalleryManager]addOrUpdateLikeData:like];
    
    self.title=[dict objectForKey:@"t"];
    if ([self.title isEqual:[NSNull null]]) {
        self.title=nil;
        
    }

    self.uid=[dict objectForKey:@"uid"];
    self.url=[dict objectForKey:@"url"];
    
    
    self.uthumb=[dict objectForKey:@"uthumb"];
    if ([self.uthumb isEqual:[NSNull null]]) {
        self.uthumb=nil;
    }
    self.isPro=[[dict objectForKey:@"pro"] boolValue];
    self.isFullyLoaded=NO;
    self.requestIsActive=NO;
    
    if ([dict objectForKey:@"c"] && [[dict objectForKey:@"c"] isEqual:[NSNull null]]==false) {
        self.content=[dict objectForKey:@"c"];
    }

}

-(void)duplicateFromOther:(DesignBaseClass*)original{

    self.author=original.author;
    self.commentsCount=original.commentsCount;
    self.productsCount=original.productsCount;
    self.originalImageURL=original.originalImageURL;
    self.editedImageURL=original.editedImageURL;
    self.maskImageURL=original.maskImageURL;
    
    self._description=original._description;
    self._id=original._id;
    
    self.title=original.title;
    self.uid=original.uid;
    self.url=original.url;
    
    self.uthumb=original.uthumb;
    
    self.uname=original.uname;
    self.roomType=original.roomType;
    self.images=original.images;
    self.backgroundImageURL=original.backgroundImageURL;
    self.isFullyLoaded=original.isFullyLoaded;
    self.content=original.content;
    self.isPro=original.isPro;
    self.requestIsActive=original.requestIsActive;
    self.eSaveDesignStatus = original.eSaveDesignStatus;
}

-(void)updateDesignItemWithFullData:(NSMutableDictionary*)dict{
    
    self.uname=[dict objectForKey:@"uname"];
    self.roomType=[dict objectForKey:@"rt"];
    if ([self.roomType isEqual:[NSNull null]]) {
        self.roomType=nil;
    }
    if ([dict objectForKey:@"id"]) {
       self._id=[dict objectForKey:@"id"]; 
    }
    
    if (self.commentsCount==nil) {
        self.commentsCount=[dict objectForKey:@"cmt"];
    }
    self.productsCount=[dict objectForKey:@"pcnt"];
    if (self.title==nil) {
        self.title=[dict objectForKey:@"title"];
        if ([self.title isEqual:[NSNull null]]) {
            self.title=nil;
        }
    }

    if (self.author==nil) {
        self.author=[dict objectForKey:@"uname"];
    }
   
    if (self.uthumb==nil) {
        self.uthumb=[dict objectForKey:@"uthumb"];
        if ([self.uthumb isEqual:[NSNull null]]) {
            self.uthumb=nil;
        }

    }
        
    if (self.uid==nil) {
        self.uid=[dict objectForKey:@"uid"];
    }
    if (self._description==nil) {
        self._description=[dict objectForKey:@"d"];
    }
 
    NSDictionary * dict1=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self._id,[dict objectForKey:@"lk"], nil] forKeys:[NSArray arrayWithObjects:@"id",@"lk", nil]];
    
      
   LikeDesignDO*like= [[LikeDesignDO alloc] initWithDictionary:dict1];
    [[[AppCore sharedInstance] getGalleryManager]addOrUpdateLikeData:like];
    
    
    NSArray * imgs=[dict objectForKey:@"images"];
    if (imgs) {
        self.images=[NSMutableArray arrayWithArray:imgs];
        
        for (int i=0; i<[imgs count]; i++)
        {
            if (i==0) {
                
            
            //   if ([[imgs objectAtIndex:i] hasSuffix:@"i.jpg"]==YES) {
                self.originalImageURL=[imgs objectAtIndex:i];
                if (self.url==nil && [imgs count]==1) {
                    self.url=self.originalImageURL;
                }
            }
            if (i==1) {
            //if ([[imgs objectAtIndex:i] hasSuffix:@"b.jpg"]==YES) {
                self.backgroundImageURL=[imgs objectAtIndex:i];
                
            }
            if (i==2) {
            //if ([[imgs objectAtIndex:i] hasSuffix:@"f.jpg"]==YES) {
                self.editedImageURL=[imgs objectAtIndex:i];
                if (self.url==nil) {
                    self.url=[imgs objectAtIndex:i];
                }
            }
        }
    }
    if([dict objectForKey:@"mask"]  != [NSNull null]  && [[dict objectForKey:@"mask"] length] > 0 )
    {
        self.maskImageURL = [dict objectForKey:@"mask"];
        
    }
    
    self.isFullyLoaded=YES;
    if ([dict objectForKey:@"content"]!=nil && [[dict objectForKey:@"content"] isEqual:[NSNull null]]==false) {
        self.content=[dict objectForKey:@"content"];
    }
    
    self.requestIsActive=NO;
}

-(int)getLikesCountForDesign{
    
    
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self._id];

   return [likeDO.likesCount intValue];
}
-(BOOL)isUserLikesDesign{
    
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self._id];
    return likeDO.isUserLiked;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
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
-(NSNumber*)getTotalCommentsCount{
    return [NSNumber numberWithInt:0];
}

-(void)createCustomArticle{
    self.type = eArticle;
}

-(void)loadGalleryItemExtraInfo :(loadDesignBaseInfoBlock)completeBlock{
    
    if ([self requestIsActive])
        return;
        
    requestIsActive=YES;
    [self virtualGalleryItemExtraInfo:^( NSString *response) {
        
        BOOL status =response==nil;
        requestIsActive = NO;
        
        if(completeBlock)completeBlock(status);
    }];
}

-(void)virtualGalleryItemExtraInfo:(dictionaryResponseBlock)completeBlock
{
    [self virtualGalleryItemExtraInfo:YES completionBlock:completeBlock];
}

- (void)virtualGalleryItemExtraInfo:(BOOL)richData completionBlock:(dictionaryResponseBlock)completeBlock {
    // implement in sub-class
}


-(BOOL)isDesignPublished{
    
    return YES;
}

-(BOOL)isPublicOrPublished{
    
    return YES;
}

-(BOOL)isUpdateRequeredForRedesign{

    
    if (self.content==nil) {
        return NO;
        
    }else{
        NSError *error =nil;
        
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[self.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if (error!=nil|| jsonData==nil) {
            return NO;
        }
        
            NSString *jsonVersion=[jsonData objectForKey:@"version"];
    
        if (jsonVersion==nil)return NO;
        
    
    if ([jsonVersion floatValue]>[DESIGN_VERSION floatValue]) {
            return YES;
        }else{
            return NO;
        }
        
    }

    return NO;
}

-(NSString*)getAPITimestamp{
    return nil;
}


-(BOOL)isDesignBelongsToLoggedInUser{
    
    if ([[[[UserManager sharedInstance] currentUser] userID] isEqualToString:@""]) {
        return NO;
    }
    
    if (self.uid==nil || [self.uid isEqual:[NSNull null]]) {
        return NO;
    }
    
    return [self.uid isEqualToString:[[[UserManager sharedInstance] currentUser]userID]];
}

@end


//////////////////////////////
// DesignMetadata
@implementation DesignMetadata

@end

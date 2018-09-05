//
//  DesignDiscussionDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/17/13.
//
//

#import "DesignDiscussionDO.h"
#import "CommentsManager.h"
#import "NotificationNames.h"

@implementation DesignDiscussionDO

-(id)init{
    self=[super init];
    self.comments=[NSMutableArray arrayWithCapacity:0];
       return self;
}

-(id)initWithComments:(NSMutableArray*)comments forDesign:(NSString*)_did{
    self=[super init];
    
    
    self.designid=_designid;
    self.comments=comments;
    return self;
}

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping *entityMapping = [super jsonMapping];

    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"cnt"  : @"totalCount"
       }];

    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"comments" withMapping:[CommentDO jsonMapping]]];

    return entityMapping;
}

- (void)setTotalCount:(NSUInteger)totalCount {
    _totalCount = totalCount;
    _dataLoaded = YES;
}

- (void)resetCommentsResponse {
    [self.comments removeAllObjects];
}

- (void)sortCommentsByDate {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [self.comments sortUsingDescriptors:[NSArray arrayWithObject:sort]];
}

-(void)addComment:(NSString*)body withID:(NSString*)commID userName:(NSString*)uname userThumb:(NSString*)uthumb
             time:(NSDate*)_time parentID:(NSString*)pid{
    
    
    CommentDO *comm=[[CommentDO alloc] init];
    
    comm.body=body;
    comm._id=commID;
    if (uthumb) {
        comm.imageUrl=uthumb;
    }
  
    comm.displayName=uname;
    comm.timestamp=_time;
    comm.isAddCommentSend=YES;
    if (pid) {
        comm.parentID=pid;
        //find parent comment
        
        CommentDO *parent=[self getCommentByID:pid];
        
        if (parent) {
            [[parent childComments] addObject:comm];
        }
 
    }else{
        //no parent comments its a parent
        [self.comments addObject:comm];
    }
       
}


-(void)addGeneratedComment:(CommentDO*)newComment forOriginalComment:(CommentDO*)origCom withDesignItem:(DesignBaseClass*)designItem withCompletion:(addCommentUICompletionBlock)completionBlock {

    if (origCom != nil) {
        newComment.isAddCommentSend=YES;
    } else {
        newComment.isAddCommentSend=YES;
    }

    GalleryServerUtils * galleryServerUtils=[GalleryServerUtils sharedInstance];
    NSString * parentID = (origCom != nil) ? origCom._id : @"";
    NSString * parentUID = (origCom != nil) ? origCom.uid : @"";

#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_DESIGN_COMMENT_SEND];
    }
#endif
    [galleryServerUtils addComment:designItem._id :newComment.body :parentID :parentUID withComplition:^(CommentDO *comment, BOOL status) {
        if (status) {
            [newComment updateCommentWithComment:comment];
            completionBlock(YES);
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationAddCommentFinished object:nil
                                                                                               userInfo:@{@"isSuccess":@YES, kNotificationKeyItemId:designItem._id, @"designItem":designItem, @"comment":newComment}]];

        }else{
            completionBlock(NO);
        }
    }];
}


-(void)addGeneratedComment:(CommentDO*)newComment forOriginalComment:(CommentDO*)origCom withItemID:(NSString*)designItemID withCompletion:(addCommentUICompletionBlock)complitionBlock{
    
    if (origCom!=nil) {
        newComment.isAddCommentSend=YES;
    }else{
        newComment.isAddCommentSend=YES;
    }

    GalleryServerUtils * galleryServerUtils=[GalleryServerUtils sharedInstance];
    NSString * parentID=(origCom!=nil)?origCom._id:@"";
    NSString * parentUID=(origCom!=nil)?origCom.uid:@"";
    
    [galleryServerUtils addComment:designItemID :newComment.body :parentID :parentUID withComplition:^(CommentDO *comment, BOOL status) {
            //found comment and response was successfull
            if (status)
            {
//                CommentDO * parentComment= [self getCommentByID:parentID];
//
//
//                if ( parentComment==nil)
//                     parentComment=[self getLatestTempComment];
//
//                if (parentComment)
                [newComment updateCommentWithComment:comment];
                     
                complitionBlock(true);
            
            }else{
                //failed
//                CommentDO * parentComment= [self getCommentByID:parentID];
//                if (parentComment==nil)
//                     parentComment=[self getLatestTempComment];
//
//                if (parentComment) {
//                    [parentComment updateCommentResponseFailed];
//                }
                
//                [self.comments removeObject:newComment];
                
                complitionBlock(false);
            }
    }];
}

-(CommentDO*)getLatestTempCommentCreated{
    for (int i=0; i<[self.comments count]; i++) {
        
        if ([[self.comments objectAtIndex:i] isTempComment] ) {
            return  [self.comments objectAtIndex:i];
        }
    }
    return nil;
}

-(CommentDO*)getLatestTempComment{
    for (int i=0; i<[self.comments count]; i++) {
        
        if ([[self.comments objectAtIndex:i] isTempComment] && [[self.comments objectAtIndex:i] isAddCommentSend]) {
            return  [self.comments objectAtIndex:i];
        }
    }
    return nil;
}

-(void)clearTempCommentsOnCancel{
    
    for (int i=0; i<[self.comments count]; i++) {
        
        if ([[self.comments objectAtIndex:i] isTempComment]) {
            [self.comments removeObjectAtIndex:i];
            i--;
            
        }else
        {
            [[self.comments objectAtIndex:i] clearTempCommentsOnCancel];
        }
    }
}

-(void)addTempComment:(CommentDO*)comment{
    [self.comments insertObject:comment atIndex:0];
    self.totalCount += 1;
//    [self.comments addObject:comment];
}

-(void)removeTempComment:(CommentDO*)comment{
    [self.comments removeObject:comment];
    self.totalCount -= 1;
    if (self.totalCount < 0) {
        self.totalCount = 0;
    }
}

-(NSNumber*)getTotalCommentsCount{
    
    int total=0;
    
    //count comments but ignore the temp ones
    
    for (int i=0; i<[self.comments count]; i++) {
        CommentDO * comm=[self.comments objectAtIndex:i];
        if ([[comm childComments]count]==0 && comm.isTempComment) {
            total+=[comm getNumberOfRealComments];
        }else
            total+=1+[comm getNumberOfRealComments];
        
    }
    
    return [NSNumber numberWithInt:total];
}

-(CommentDO *)getCommentByID:(NSString*)commID{
    if (commID==nil) {
        return nil;
    }
    for (int i=0;i< [self.comments count] ; i++) {
        
        CommentDO * com=[self.comments objectAtIndex:i] ;
        if (com._id!=nil && [[com _id] isEqualToString:commID]) {
            return [self.comments objectAtIndex:i];
        }
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}
@end

//
//  CommentDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/14/13.
//
//

#import "CommentDO.h"

@implementation CommentDO
@synthesize  body;
@synthesize  _id;
@synthesize  timestamp;
@synthesize strTimestamp;

@synthesize  imageUrl;
@synthesize  displayName;
@synthesize  uid;


@synthesize  replyLevel;
@synthesize parentID;
@synthesize childComments;

@synthesize tempComment;
@synthesize isTempComment;

@synthesize dicAuthor;
@synthesize dicReply;

#define VERIFY_FIELD(field) if (field == (NSObject *) [NSNull null]) (field = nil)

-(id)init{
    self=[super init];
    self.childComments=[NSMutableArray arrayWithCapacity:0];
    
    return self;
}
-(id)initWithDictionary:(NSMutableDictionary*)dict{
    /*
     
     {
     "body": "Where is the request??",
     "id": "CCH5W06HDH18X0K",
     "timestamp": "2013-03-04 09:06:34",
     "author": {
     "imageUrl": null,
     "displayName": "test987 test987",
     "id": "1736"
     },
     "inReplyTo": null,
     },
     */
    self.childComments=[NSMutableArray arrayWithCapacity:0];
    
    self.body=([dict objectForKey:@"body"]==[NSNull null])?nil:[dict objectForKey:@"body"];
    
    
    self._id=([dict objectForKey:@"id"]==[NSNull null])?nil:[dict objectForKey:@"id"];
    
    
     
     
    
    NSString * tmsp=([dict objectForKey:@"timestamp"]==[NSNull null])?nil:[dict objectForKey:@"timestamp"];
    
    if (tmsp!=nil) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd kk:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];

        self.timestamp=[formatter dateFromString:tmsp];
    }
 
    
    if ([dict objectForKey:@"author"] && [dict objectForKey:@"author"]!=[NSNull null]) {
        self.imageUrl=([[dict objectForKey:@"author"] objectForKey:@"imageUrl"]==[NSNull null])?nil:
                        [[dict objectForKey:@"author"] objectForKey:@"imageUrl"];
       
        self.displayName=([[dict objectForKey:@"author"] objectForKey:@"displayName"]==[NSNull null])?nil:
                        [[dict objectForKey:@"author"] objectForKey:@"displayName"];
        
        self.uid=([[dict objectForKey:@"author"] objectForKey:@"id"]==[NSNull null])?nil:
                        [[dict objectForKey:@"author"] objectForKey:@"id"];
    }
    
    
    
    if ([[dict objectForKey:@"inReplyTo"] isEqual:[NSNull null]]==true) {
        self.replyLevel=0;
    }else{
        self.replyLevel=1;
        self.parentID=[[dict objectForKey:@"inReplyTo"]objectForKey:@"id"];
                    
    }
    return  self;
}

-(void)updateCommentResponseFailed{
    
    self.isAddCommentSend=NO;
    
    for (int i=0; i<[[self childComments] count]; i++) {
        if ([[[self childComments] objectAtIndex:i] isAddCommentSend]) {
            [[[self childComments]objectAtIndex:i] setIsAddCommentSend:NO];
        }
    }
    
}
-(void)updateCommentResponse:(NSDictionary*)dict{
    
    if (self.isAddCommentSend==NO) {
        for (int i=0; i<[[self childComments] count]; i++) {
            if ([[[self childComments] objectAtIndex:i] isAddCommentSend]) {
                [[[self childComments]objectAtIndex:i]updateCommentResponse:dict];
                
            }
        }
    }else{
        self._id=[dict objectForKey:@"cid"];
        self.strTimestamp=[dict objectForKey:@"timestamp"];
    }
    
    
    
    self.isAddCommentSend=NO;
    self.isTempComment=NO;
}

- (void)updateCommentWithComment:(CommentDO *)comm
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (comm._id != nil)
    {
        [dic setObject:comm._id forKey:@"cid"];
    }
    if (comm.strTimestamp != nil)
    {
        [dic setObject:comm.strTimestamp forKey:@"timestamp"];
    }
    
    [self updateCommentResponse:dic];
}

-(void)sortChildCommentsBydate{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [self.childComments sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}


-(int)indexOfTempComment{
    
    for (int i=0; i<[self.childComments count]; i++) {
        if ([[self.childComments objectAtIndex:i] isTempComment]) {
            return i;
        }
    }
    
    
    return  -1;
}

-(void)clearTempCommentsOnCancel{
    
    for (int i=0; i<[self.childComments count]; i++) {
        
        if ([[self.childComments objectAtIndex:i] isTempComment]) {
            [self.childComments removeObjectAtIndex:i];
            i--;
            
        }
    }
}
-(int)getNumberOfRealComments{
    int count=0;
    
    for (int i=0; i<[self.childComments count]; i++) {
        
        if ([[self.childComments objectAtIndex:i] isTempComment]==FALSE) {
            // [self.childComments removeObjectAtIndex:i];
            count++;
            
        }
    }
    
    return count;
    
}
-(int)getNumberOfTempComments{
    int count=0;
    
    for (int i=0; i<[self.childComments count]; i++) {
        
        if ([[self.childComments objectAtIndex:i] isTempComment]) {
           // [self.childComments removeObjectAtIndex:i];
            count++;
            
        }
    }
    
    return count;
}

-(void)setIsTempComment:(BOOL)isempComment{
    isTempComment=isempComment;
}

#pragma mark - Json Parsing Methods

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping *entityMapping = [RKObjectMapping mappingForClass:[CommentDO class]];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"body" : @"body",
     @"id" : @"_id",
     @"timestamp" : @"strTimestamp",
     @"author" : @"dicAuthor",
     @"inReplyTo" : @"dicReply",
     }];
    
    return entityMapping;
}

- (void)proccessMetadata
{
    self.childComments = [NSMutableArray arrayWithCapacity:0];
    
    VERIFY_FIELD(self.body);
    VERIFY_FIELD(self._id);
    VERIFY_FIELD(self.strTimestamp);
    VERIFY_FIELD(self.dicAuthor);
    VERIFY_FIELD(self.parentID);
    VERIFY_FIELD(self.dicReply);
    
    if (self.strTimestamp != nil)
    {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd kk:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        
        self.timestamp=[formatter dateFromString:self.strTimestamp];
    }

    if (self.dicAuthor != nil)
    {
        self.imageUrl = [self.dicAuthor objectForKey:@"imageUrl"];
        VERIFY_FIELD(self.imageUrl);
        
        self.displayName = [self.dicAuthor objectForKey:@"displayName"];
        VERIFY_FIELD(self.displayName);
        
        self.uid = [self.dicAuthor objectForKey:@"id"];
        VERIFY_FIELD(self.uid);
    }
    
    if ((self.dicReply != nil) && (![self.dicReply objectForKey:[NSNull null]]))
    {
        self.replyLevel = 1;

        self.parentID = [self.dicReply objectForKey:@"id"];
        VERIFY_FIELD(self.parentID);
        
        NSDictionary* parentAuthor = [self.dicReply objectForKey:@"author"];
        VERIFY_FIELD(parentAuthor);
        
        if (parentAuthor != nil && (![parentAuthor objectForKey:[NSNull null]])) {
            self.parentDisplayName = [parentAuthor objectForKey:@"displayName"];
            VERIFY_FIELD(self.parentDisplayName);
            
            self.parentUID = [parentAuthor objectForKey:@"id"];
            VERIFY_FIELD(self.parentUID);
        }
    }
    else
    {
        self.replyLevel = 0;
    }
}

@end

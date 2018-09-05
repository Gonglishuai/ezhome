//
//  DesignDiscussionDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/17/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseResponse.h"
#import "CommentDO.h"

@class DesignBaseClass;

@interface DesignDiscussionDO : BaseResponse

-(id)initWithComments:(NSMutableArray*)comments forDesign:(NSString*)_did;

@property (nonatomic, strong) NSString * designid;

@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic) NSUInteger totalCount;

@property (nonatomic) BOOL dataLoaded;

@property (nonatomic) int loadedCount; //TODO : SERGEY add by PAGE 

- (void)resetCommentsResponse;
- (void)sortCommentsByDate;

-(void)addComment:(NSString*)body withID:(NSString*)commID userName:(NSString*)uname userThumb:(NSString*)uthumb
             time:(NSDate*)_time parentID:(NSString*)pid;


-(NSNumber*)getTotalCommentsCount;
-(CommentDO *)getCommentByID:(NSString*)commID;

typedef void (^ addCommentUICompletionBlock)(BOOL);

-(void)addGeneratedComment:(CommentDO*)newComment forOriginalComment:(CommentDO*)origCom withDesignItem:(DesignBaseClass*)designItem withCompletion:(addCommentUICompletionBlock)completionBlock;
-(void)addGeneratedComment:(CommentDO*)newComment forOriginalComment:(CommentDO*)origCom withItemID:(NSString*)designItemID withCompletion:(addCommentUICompletionBlock)completionBlock;

-(void)addTempComment:(CommentDO*)comment;
-(void)removeTempComment:(CommentDO*)comment;

-(CommentDO*)getLatestTempComment;
-(CommentDO*)getLatestTempCommentCreated;
-(void)clearTempCommentsOnCancel;
@end

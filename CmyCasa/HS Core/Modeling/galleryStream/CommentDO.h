//
//  CommentDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/14/13.
//
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface CommentDO : NSObject <NSCoding>


@property(nonatomic, strong) NSString * body;
@property(nonatomic, strong) NSString * _id;
@property(nonatomic, strong) NSDate * timestamp;
@property(nonatomic, strong) NSString * strTimestamp;
@property(nonatomic, strong) NSString * imageUrl;
@property(nonatomic, strong) NSString * displayName;
@property(nonatomic, strong) NSString * uid;
@property(nonatomic) NSInteger replyLevel;
@property(nonatomic, strong) NSString * parentID;
@property(nonatomic, strong) NSString * parentDisplayName;
@property(nonatomic, strong) NSString * parentUID;
@property(nonatomic, strong) NSMutableArray * childComments;
@property(nonatomic)BOOL isAddCommentSend;
@property(nonatomic)BOOL isTempComment;
@property(nonatomic, strong)CommentDO * tempComment;
@property(nonatomic, strong) NSDictionary *dicAuthor;
@property(nonatomic, strong) NSDictionary *dicReply;

-(void)clearTempCommentsOnCancel;
-(id)initWithDictionary:(NSMutableDictionary*)dict;
-(void)updateCommentResponse:(NSDictionary*)dict;
- (void)updateCommentWithComment:(CommentDO *)comm;
-(void)updateCommentResponseFailed;
-(int)indexOfTempComment;

-(int)getNumberOfRealComments;
-(int)getNumberOfTempComments;

+ (RKObjectMapping *)jsonMapping;
- (void)proccessMetadata;

@end

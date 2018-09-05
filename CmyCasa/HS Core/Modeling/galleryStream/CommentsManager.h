//
//  CommentsManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/14/13.
//
//

#import <Foundation/Foundation.h>
#import "CommentDO.h"
#import "BaseManager.h"

@class DesignDiscussionDO;

static  NSString * CommentsForDesignReadyNotification =@"CommentsForDesignReadyNotification";
static  NSString * CommentsForDesignFailedNotification =@"CommentsForDesignFailedNotification";

@interface CommentsManager : BaseManager <NSCoding>

-(DesignDiscussionDO *)getLoadedCommentsForDesignID:(NSString*)designid;
-(DesignDiscussionDO *)createNewDiscussion:(NSString*)designID;
-(void)getCommentsForDesignID:(NSString*)designid offset:(NSUInteger)page;
-(void)clearTempcommentsFromDiscussions;

@property(nonatomic)NSMutableDictionary * designComments;


@end

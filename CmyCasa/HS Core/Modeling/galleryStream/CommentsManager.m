//
//  CommentsManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/14/13.
//
//

#import "CommentsManager.h"
#import "GalleryServerUtils.h"
#import "CommentDO.h"
#import "NotificationNames.h"

@implementation CommentsManager

-(id)init{
    self = [super init];
    
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCommentsFinishedNotification:)
                                                 name:kNotificationGetCommentsFinished
                                               object:nil];

        self.designComments=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    return self;
}

-(void)getCommentsForDesignID:(NSString*)designid offset:(NSUInteger)page {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GalleryServerUtils sharedInstance] getComments:designid offset:page];
    });
}

-(DesignDiscussionDO *)getLoadedCommentsForDesignID:(NSString*)designid{
    
    return [self.designComments objectForKey:designid];
}

-(DesignDiscussionDO *)createNewDiscussion:(NSString*)designID{
    
   DesignDiscussionDO*  designDisc=[[DesignDiscussionDO alloc] init];
    
    designDisc.designid=designID;
    
    [self.designComments setObject:designDisc forKey:designID];
    
    return  designDisc;
}


- (void)getCommentsFinishedNotification:(NSNotification *)notification
{
    BOOL isSuccess = NO;

    [[[notification userInfo] objectForKey:@"isSuccess"] getValue:&isSuccess];

    if (isSuccess) {
        NSString * designid=[[notification userInfo] objectForKey:@"designid"];

        DesignDiscussionDO *dd = [[notification userInfo] objectForKey:@"result"];

        if (dd.comments != nil) {
            for (NSUInteger i = 0; i < dd.comments.count; i++) {
                CommentDO * comm = [dd.comments objectAtIndex:i];
                [comm proccessMetadata];
            }
            [dd sortCommentsByDate];
        } else {
            dd = [[DesignDiscussionDO alloc] init];
        }

        dd.designid = designid;

        [self.designComments setObject:dd forKey:designid];

        [[NSNotificationCenter defaultCenter] postNotificationName:CommentsForDesignReadyNotification object:designid];
    } else {
        NSString * designid=[[notification userInfo] objectForKey:@"designid"];
        [[NSNotificationCenter defaultCenter] postNotificationName:CommentsForDesignFailedNotification object:designid];
    }
}

-(void)clearTempcommentsFromDiscussions{
    
    for (NSString * key in [self.designComments allKeys]) {
        DesignDiscussionDO*  designDisc=[self.designComments objectForKey:key];
        [designDisc clearTempCommentsOnCancel];
    }
}


@end

//
//  CommentsRO.m
//  Homestyler
//
//  Created by Ma'ayan on 12/4/13.
//
//

#import "CommentsRO.h"
#import "AddCommentResponse.h"
#import "DesignDiscussionDO.h"

@implementation CommentsRO

+ (void)initialize
{
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionAddComment] withMapping:[AddCommentResponse jsonMapping]];
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetComments] withMapping:[DesignDiscussionDO jsonMapping]];
}

//"v":"{{VERSION}}","t":"{{TOKEN}}","s":"{{SESSIONID}}","itm":"{{ITEM}}", "txt":"{{BODY}}", "pid":"{{PARENTID}}","ts":"{{TS}}"
- (void)addComment:(CommentDO *)comment forItem:(NSString *)itemId withcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
   // NSDictionary *objToken  = [self generateToken:YES];
    //NSString *paramToken = [objToken objectForKey:@"Token"]; //maayan: commented this out because it looks like rest kit handles the token in the "withToken" parameter
    //NSString *paramTime = [objToken objectForKey:@"Time"];
    NSString *paramSessionId = [[UserManager sharedInstance] getSessionId];
    
    NSMutableDictionary *params = [@{/*@"t" : paramToken, */@"s" : paramSessionId, @"itm" : itemId, @"txt" : comment.body, @"pid" : comment.parentID/*, @"ts" : paramTime*/,@"rid" : comment.parentUID ? comment.parentUID : @""} mutableCopy];
    
    [self postWithAction:[[ConfigManager sharedInstance] actionAddComment] params:params withHeaders:NO withToken:YES completionBlock:^(id serverResponse)
     {
         AddCommentResponse* response = serverResponse;
         
         response.getComment.parentID = comment.parentID;
         
         if ([response errorCode] == -1)
         {
             if (completion != nil)
             {
                 if ([response getComment] != nil)
                 {
                     completion([response getComment]);
                 }
             }
         }
         else
         {
             failure(nil);
         }
     } failureBlock:failure];
}


//ttp://api.alpha.homestyler.com/hsmweb/api/comment/getcomments/?id={{ID}}
- (void)getCommentsForItem:(NSString *)itemId timeString:(NSString *)timeStr offset:(NSUInteger)page withcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;

    if (!itemId) {
        //bug fix
        failure(nil);
        NSLog(@"got here with itemId = nil");
        return;
    }
    
    NSMutableDictionary *params = [@{@"id" : itemId} mutableCopy];
    [params setObject:@"50" forKey:@"limit"];
    [params setObject:@(page) forKey:@"offset"];
    if (timeStr != nil)
    {
        [params setObject:timeStr forKey:@"tss"];
    }
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetComments] params:params withHeaders:NO completionBlock:^(id serverResponse)
     {
         DesignDiscussionDO* response = serverResponse;
         
         //This is a fix for server side issue ignoring errorCode 125- asset not found
         
         if ( [response errorCode] == 125) {
             [response resetCommentsResponse];
         }
         
         if ([response errorCode] == -1 || [response errorCode] == 125)
         {
             if (completion != nil)
             {
                 completion(response);
             }
         }
         else
         {
             failure(nil);
         }
     } failureBlock:failure];
}


@end

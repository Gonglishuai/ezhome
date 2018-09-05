 //
//  GalleryServerUtils.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/15/13.
//
//

#import "GalleryServerUtils.h"
#import "NotificationAdditions.h"
#import "NSString+JSONHelpers.h"
#import "ProtocolsDef.h"
#import "FlurryDefs.h"
#import "MD5Categories.h"
#import "ConfigManager.h"
#import "NSString+UrlParams.h"
#import "NSMutableString+UrlParams.h"
#import "NSString+Contains.h"
#import "BaseRO.h"
#import "NotificationNames.h"
#import "CommentsRO.h"
#import "ImageFetcher.h"

@interface GalleryServerUtils ()
{
    NSOperationQueue* _imageQueue;
    BOOL _layoutsLoaded;
    NSString * currentLocale;
}

@end

@implementation GalleryServerUtils

@synthesize cloudCache;

static GalleryServerUtils *sharedInstance = nil;

+ (GalleryServerUtils *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[GalleryServerUtils alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        
        currentLocale= [[NSLocale preferredLanguages] objectAtIndex:0];
        _layoutsLoaded=NO;
        _imageQueue = [[NSOperationQueue alloc] init];
        _imageQueue.maxConcurrentOperationCount=10;
       
        cloudCache=[CloudFrontCacheMap loadCustomObject];
        if (cloudCache==nil) {
            cloudCache=[[CloudFrontCacheMap alloc]initWithDict:[[ConfigManager sharedInstance]getMainConfigDict] ];
            [cloudCache saveCustomObject];
        }
        
    }
    return self;
}



- (BOOL)isLayoutsLoaded{
    return _layoutsLoaded;
}

- (void) getComments:(NSString*) itemID offset:(NSUInteger)page {
    
    HSMDebugLog(@"getComments request sent");
    
    NSString* unixUtcDateTimeStr = nil;
    
    if([[cloudCache commentsCacheMap] objectForKey:itemID]!=nil)
    {
        NSDate * createDate=[[cloudCache commentsCacheMap] objectForKey:itemID];
        NSDate * now=[NSDate date];
        NSTimeInterval intrev=[[cloudCache getCommentsCacheTimeoutMins] intValue]*60;
        NSDate * expdate=[createDate dateByAddingTimeInterval:intrev];
        
        if ([now compare:expdate]!=NSOrderedDescending ) {
            
            double timeInterval = [now timeIntervalSince1970];
            timeInterval = floor(timeInterval);
            unixUtcDateTimeStr =[NSString stringWithFormat:@"%.0lf", timeInterval];            
        }else{
            [[cloudCache commentsCacheMap] removeObjectForKey:itemID];
            [cloudCache saveCustomObject];
        }        
    }
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_ITEM_LIST];
    }
#endif
    
    [[CommentsRO new] getCommentsForItem:itemID timeString:unixUtcDateTimeStr offset:(NSUInteger)page withcompletionBlock:^ (id serverResponse){
         
         DesignDiscussionDO *designDiscussion = (DesignDiscussionDO *) serverResponse;
         
         [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationGetCommentsFinished object:nil userInfo:@{ @"isSuccess" : @YES, @"designid" : itemID, @"result" : designDiscussion}]];
         
     } failureBlock:^ (NSError *error){
         HSMDebugLog(@")getCommentsFinished error= %@\"",[error description]);
         
         [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationGetCommentsFinished object:nil userInfo:@{ @"isSuccess" : @NO,  @"designid" : itemID}]];
         
     } queue:(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))];
}

- (void) addComment:(NSString*)itemID :(NSString*)body :(NSString*)parentID :(NSString*)parentUID withComplition:(addCommentCompletionBlock)completeBlock{
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
//        [HSFlurry logEvent: FLURRY_ADD_COMMENT  withParameters:[NSDictionary dictionaryWithObject:itemID forKey:@"item ID"]];
        
    }
#endif
    
    //remember the design id for with user added comment to overcome the cloud from caching issue
    [[cloudCache commentsCacheMap] setObject:[NSDate date] forKey:itemID];
    [cloudCache saveCustomObject];
    
    HSMDebugLog(@"addComment request sent");
    
    //send addComment request
    CommentDO *comment = [[CommentDO alloc] init];
    comment.body = body;
    comment.parentID = parentID;
    comment.parentUID = parentUID;
    
    [[CommentsRO new] addComment:comment forItem:itemID withcompletionBlock:^ (id serverResponse)
     {
         if (completeBlock)
         {
             CommentDO *comm = (CommentDO *) serverResponse;
             completeBlock(comm, YES);
         }

     } failureBlock:^ (NSError *error)
     {
         if (completeBlock)
         {
             completeBlock(nil, NO);
         }

         if (error != nil)
         {
             HSMDebugLog(@")addCommentRequestFinished error= %@\"",[error description]);
         }
         
     } queue:(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))];
}

- (Boolean) addComment:(NSString*) itemID :(NSString*) body :(NSString*) parentID{
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_ADD_COMMENT  withParameters:[NSDictionary dictionaryWithObject:itemID forKey:@"item ID"]];
    }
#endif
    
    //remember the design id for with user added comment to overcome the cloud from caching issue
    [[cloudCache commentsCacheMap] setObject:[NSDate date] forKey:itemID];
    [cloudCache saveCustomObject];

    body=[body JSONString:body];
    
	HSMDebugLog(@"addComment request sent");
    
    //send addComment request
    CommentDO *comment = [[CommentDO alloc] init];
    comment.body = body;
    comment.parentID = parentID;
    
    [[CommentsRO new] addComment:comment forItem:itemID withcompletionBlock:^ (id serverResponse)
     {
         CommentDO *comm = (CommentDO *) serverResponse;
         
         [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationAddCommentFinished object:nil userInfo:@{@"isSuccess" : @YES, @"comment": comm}]];
         
     } failureBlock:^ (NSError *error)
     {
         if (error != nil)
         {
             HSMDebugLog(@")addCommentRequestFinished error= %@\"",[error description]);
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationAddCommentFinished object:nil userInfo:@{ @"isSuccess" : @NO}]];
         
     } queue:(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))];
    
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_ITEM_LIST];
    }
#endif
    
    return false;
}

-(void)loadImageFromUrl:(UIImageView*)currentImage url:(NSString*)url{
    NSLog(@"URL - %@",url);
    
    //load design image
    CGSize designSize = currentImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: url ? url : @"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : currentImage
                          };
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta){
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                currentImage.image = image;
                currentImage.contentMode = UIViewContentModeScaleAspectFill;
            });
        }
    }];
}

@end

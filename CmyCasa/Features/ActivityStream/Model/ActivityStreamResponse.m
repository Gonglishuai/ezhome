//
//  ActivityStreamResponseObject.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/23/13.
//
//

#import "ActivityStreamDO.h"
#import "ActivityStreamResponse.h"
#import "LikeDesignDO.h"
#define ACTIVITY_TYPE_FOLLOW_KEY            @"FOLLOW"
#define ACTIVITY_TYPE_COMMENT_KEY           @"COMMENT"
#define ACTIVITY_TYPE_LIKE_KEY              @"LIKE"
#define ACTIVITY_TYPE_FEATURE_KEY           @"FEATURE"
#define ACTIVITY_TYPE_PUBLISH_KEY           @"PUBLISH"

#define ACTIVITY_ASSET_TYPE_3D_KEY         (1)
#define ACTIVITY_ASSET_TYPE_2D_KEY         (2)
#define ACTIVITY_ASSET_TYPE_ARTICLE_KEY    (3)


///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ActivityStreamResponse()

// Checks if an activity is legal. All legality logic
// is contained in this function
- (BOOL)isActivityLegal:(ActivityStreamDO*)activity;

/* Uncomment below to enable like filtering and aggregation */
//- (BOOL)isLikeDuplicate:(ActivityStreamDO*)activity itemCollection:(NSArray*)itemCollection;

@end


///////////////////////////////////////////////////////
//               IMPLEMENTATION                      //
///////////////////////////////////////////////////////

@implementation ActivityStreamResponse


+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addPropertyMapping: [RKRelationshipMapping relationshipMappingFromKeyPath:@"activities"
                                                                                   toKeyPath:@"activities"
                                                                                 withMapping:[ActivityStreamDO jsonMapping]]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{@"lastRead" : @"lastRead"}];
    
    return entityMapping;
}


- (void)applyPostServerActions
{
    NSMutableArray *validActivities = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.activitiesSinceLastRead = 0;
    for (ActivityStreamDO *item in self.activities)
    {
        
        // If activity name is not recognized we cannot process the activity
        // so we reject it
        if (item.activityName == nil)
            continue;
        
        // Convert asset type key to asset type enum
        item.assetType = eEmptyRoom;
        if (ACTIVITY_ASSET_TYPE_3D_KEY == [item.assetTypeString intValue])
            item.assetType = e3DItem;
        else if (ACTIVITY_ASSET_TYPE_2D_KEY == [item.assetTypeString intValue])
            item.assetType = e2DItem;
        else if (ACTIVITY_ASSET_TYPE_ARTICLE_KEY == [item.assetTypeString intValue])
            item.assetType = eArticle;
        
        // Convert Activity name to corresponding activity type enum
        item.activityType = eActivityNone;
        if ([item.activityName isEqualToString:ACTIVITY_TYPE_FOLLOW_KEY])
            item.activityType = eActivityFollow;
        else if ([item.activityName isEqualToString:ACTIVITY_TYPE_COMMENT_KEY])
            item.activityType = eActivityComment;
        else if ([item.activityName isEqualToString:ACTIVITY_TYPE_LIKE_KEY])
            item.activityType = eActivityLike;
        else if ([item.activityName isEqualToString:ACTIVITY_TYPE_FEATURE_KEY])
            
        {
         //   item.activityType = eActivityFeatured;
            if (e3DItem == item.assetType)
                item.activityType = eActivityFeatured;
            else if (e2DItem == item.assetType)
                item.activityType = eActivityProfessional;
            else
                item.activityType = eActivityArticle;
        }
        else if ([item.activityName isEqualToString:ACTIVITY_TYPE_PUBLISH_KEY])
        {
            if (e3DItem == item.assetType)
                item.activityType = eActivityPublish;
            else if (e2DItem == item.assetType)
                item.activityType = eActivityProfessional;
            else
                item.activityType = eActivityArticle;
        }
        

            
        // Check for legality of the action based on the logic inisActivityLegal:activity
        if (![self isActivityLegal:item])
            continue;
        
        // Check if this activity has been read by the user. If not increase corresponding
        // counter to provide the user with the number of unread activities
     //   if (item.timeStamp > self.lastRead)
          
        
        if ([item.timeStamp compare:self.lastRead] == NSOrderedDescending) {
           // NSLog(@"date1 is later than date2");
              self.activitiesSinceLastRead++;
        }
        
       
        
/* Uncomment below to enable like filtering and aggregation */
        
//        if (eActivityLike == item.activityType)
//        {
//            if ([self isLikeDuplicate:item itemCollection:validActivities])
//                continue;
//            else
//                item.likeCountInCurrentStream = 0;
//        }
        
        [validActivities addObject:item];
        
           LikeDesignDO *likeDO = [[LikeDesignDO alloc]init:item.assetID andCount:[NSNumber numberWithInt:[item.heartCount intValue]]];
            [[GalleryStreamManager sharedInstance] addOrUpdateLikeData:likeDO];
        
        
    }
    
    self.activities = [validActivities mutableCopy];
}

- (BOOL)isActivityLegal:(ActivityStreamDO*)activity
{
    if (activity.ownerID == nil)
        return NO;
    
    // For Comment/Featured/Like/Article an assetId must be present
    // This happens because of difference between environments
    if ( activity.assetID == nil && (activity.activityType == eActivityComment || activity.activityType == eActivityLike ||
        activity.activityType == eActivityFeatured || activity.activityType == eActivityArticle || activity.activityType == eActivityProfessional) )
        return NO;
    
    return YES;
}

/* Uncomment below to enable like filtering and aggregation */

//- (BOOL)isLikeDuplicate:(ActivityStreamDO*)activity itemCollection:(NSArray*)itemCollection
//{
//    for (ActivityStreamDO *item in itemCollection)
//    {
//        if (eActivityLike == item.activityType && item.assetID == activity.assetID)
//        {
//            item.likeCountInCurrentStream++;
//            return YES;
//        }
//    }
//    
//    return NO;
//}

@end

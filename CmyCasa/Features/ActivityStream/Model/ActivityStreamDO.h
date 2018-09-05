//
//  ActivityStreamDO.h
//  Homestyler

//
// This Data Object represnts an activity item retrieved
// by the GetNewsFeed API to allow the users to preview the
// recent activity which relates to them
//
// Created by Avihay Assouline on 12/23/13.
//
//

#import "BaseRO.h"
#import "DesignBaseClass.h"

///////////////////////////////////////////////////////
//                  ENUMS                            //
///////////////////////////////////////////////////////
typedef enum activity_type_t {
    eActivityNone = 0,
    eActivityFeatured,      // Activity 1: Design is featured in Design stream
    eActivityLike,          // Activity 2: Someone liked your design
    eActivityComment,       // Activity 3: Someone commented on your design or any item you…
    eActivityFollow,        // Activity 4: You have a new follower
    eActivityArticle,       // Activity 5: A new article is available
    eActivityWelcome,       // Activity 6: Welcome activity - associated
    eActivityPublish,       // Activity 7: Publish activity
    eActivityProfessional   // Activity 5: A new photo was published by a professional
} ActivityType;

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ActivityStreamDO : NSObject  <RestkitObjectProtocol>

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *activityName;
@property (nonatomic) ActivityType activityType;

// The owner is the user which the action was performed on
@property (strong, nonatomic) NSString *ownerID;
@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSString *ownerImageURL;

// The actor is the user which performed the action
@property (strong, nonatomic) NSString *actorID;
@property (strong, nonatomic) NSString *actorName;
@property (strong, nonatomic) NSString *actorImageURL;

// The asset can be an item to display inside the stream
@property (strong, nonatomic) NSString *assetID;
@property (strong, nonatomic) NSString *assetImageURL;
@property (strong, nonatomic) NSString *assetTitle;
@property (strong, nonatomic) NSString *assetText;
@property (strong, nonatomic) NSString *assetTypeString;
@property (nonatomic) ItemType assetType;

/* Uncomment below to enable like filtering and aggregation */
// Store the count of times that in the current ActivityStream, this item was liked
//@property (nonatomic) NSInteger        likeCountInCurrentStream;

// Heart Count == number of likes.
@property (strong, nonatomic) NSString *heartCount;
@property (strong, nonatomic) NSString *commentCount;

// The time stamp when this activity was performed
@property (strong, nonatomic) NSDate *timeStamp;

// The last read time stamp indicates when did the user
// last access the activity stream. This is used to highlight the unread
// items
@property (strong, nonatomic) NSDate *lastRead;
@end

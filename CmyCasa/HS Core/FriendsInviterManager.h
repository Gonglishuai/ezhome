//
//  FriendsInviterManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/8/13.
//
//

#import "BaseManager.h"
#import <AddressBookUI/AddressBookUI.h>


static NSString* const FRIENDS_SEARCH_RESPONSE_NEED_INVITE = @"need_invite";
static NSString* const FRIENDS_SEARCH_RESPONSE_NEED_FOLLOW = @"need_follow";
static NSString* const FRIENDS_SEARCH_RESPONSE_NEED_UNFOLLOW = @"need_unfollow";
static NSString* const FRIENDS_SEARCH_RESPONSE_INVITED = @"already_invited";


typedef void(^AddressBookAccessBlock)(BOOL granted);

typedef enum SearchRequestTypes{
    
    kSearchRequestFreeText=0,
    kSearchRequestContactList=1,
    
}SearchRequestType;

@interface FriendsInviterManager : NSObject

@property (nonatomic,strong) NSMutableDictionary * searchResults;


-(void)checkForAddressBookAccessWithComplition:(AddressBookAccessBlock)completion
                                         queue:(dispatch_queue_t)queue;

-(NSInteger)getNumberOfResultsFlat;

-(NSArray*)getSearchResultsForSection:(NSInteger)section
                           withFilter:(NSString*)filter;

-(NSArray*)getSearchResultsForSection:(NSInteger)section;

-(NSArray *)getAddressBookContactsWithEmails;

-(void)resetSearchResults;

-(BOOL)isSearchResultsAfterFilterExists:(NSString*)filter;

-(BOOL)isUserHaveAddressBookContacts;

-(void)updateFollowingStatesAfterFollowChange:(NSString*)userId isFollow:(BOOL)isFollowing;

-(void)searchAddressFriendsOnServerWithCompletion:(HSCompletionBlock)completion
                                            queue:(dispatch_queue_t)queue;

-(void)searchFacebookFriendsWithCompletion:(HSCompletionBlock)completion
                                     queue:(dispatch_queue_t)queue;

-(void)searchFreeText:(NSString*)text
       withCompletion:(HSCompletionBlock)completion
                queue:(dispatch_queue_t)queue;

-(void)inviteFriendToJoinHomestylerViaEmail:(NSString*)email
                             withCompletion:(HSCompletionBlock)completion
                                      queue:(dispatch_queue_t)queue;

-(void)inviteFriendToJoinHomestylerViaFacebook:(NSString*)facebookId
                                withCompletion:(HSCompletionBlock)completion
                                         queue:(dispatch_queue_t)queue;


-(NSArray*)getAllResultsFlat;

-(void)parseSearchResults:(id)serverResponse;

-(void)clearSearchResultsFromSelfUser;

-(NSMutableArray*)subtractFollowingFriends:(NSMutableArray*)people;

-(NSMutableArray*)subtractNotFollowingFriends:(NSMutableArray*)people;

-(void)searchFacebookFriendsWithCompletionInternal:(HSCompletionBlock)completion
                                             queue:(dispatch_queue_t)queue;

@end

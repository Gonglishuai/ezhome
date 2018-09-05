    //
//  FriendsInviterManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/8/13.
//
//

#import "FriendsInviterManager.h"
#import "FindFriendsRO.h"
#import "AddrBookFriendDO.h"
#import "FindFriendsResponse.h"
#import "HelpersRO.h"

@implementation FriendsInviterManager

static FriendsInviterManager * sharedInstance = nil;

-(void)dealloc{
    NSLog(@"dealloc - FriendsInviterManager");
}

#pragma mark- UI Helpers
-(NSArray*)getAllResultsFlat{
    NSMutableArray* results=[NSMutableArray arrayWithCapacity:0];
    
    for (NSString * key  in [[self searchResults] allKeys]) {
        
        NSArray * ar = [[self searchResults] objectForKey:key];
        [results addObjectsFromArray:ar];
       
    }
    
    return [results copy];
}

-(NSInteger)getNumberOfResultsFlat{
    
    NSInteger results=0;
    
    for (NSString * key  in [[self searchResults] allKeys]) {
        NSArray * ar = [[self searchResults] objectForKey:key];
        
        if (ar && [ar isKindOfClass:[NSArray class]]) {
            results+=[ar count];
        }
    }
    
    return results;
}

-(BOOL)isSearchResultsAfterFilterExists:(NSString*)filter{
    
    NSArray * results = [self getAllResultsFlat];
    
    if (!results) {
        return NO;
    }
    
    if (filter==nil || [filter length]==0) {
        return [results count]>0;
    }
    
    NSPredicate *preda = [NSPredicate predicateWithFormat:
                          @" fullName contains[cd] %@",filter];
    
    NSArray *filteredArray =[results filteredArrayUsingPredicate:preda];
    
    return [filteredArray count]>0;
}

-(NSArray*)getSearchResultsForSection:(NSInteger)section withFilter:(NSString*)filter{
    NSArray * results = [self getSearchResultsForSection:section];
    
    if (!results) {
        return [NSArray array];
    }
    
    if (filter==nil || [filter length]==0) {
        return results;
    }
    
    NSPredicate *preda = [NSPredicate predicateWithFormat:
                          @" fullName contains[cd] %@",filter];
    
    
  
    NSArray *filteredArray =[results filteredArrayUsingPredicate:preda];
    
    return filteredArray;
}

-(NSArray*)getSearchResultsForSection:(NSInteger)section{
    
    if ([[[self searchResults] allKeys] count]==0) {
       return [NSArray array]; 
    }
    
    if (section > [[[self searchResults] allKeys] count]) {
        return [NSArray array];
    }
    
    
    NSMutableArray * lists = [NSMutableArray arrayWithCapacity:4];
    
    
    if ([[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_UNFOLLOW]) {
         [lists addObject:[[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_UNFOLLOW]];
    }
    if ([[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_FOLLOW]) {
         [lists addObject: [[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_FOLLOW]];
    }
    if ([[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_INVITED]) {
         [lists addObject: [[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_INVITED]];
    }
    if ([[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE]) {
         [lists addObject: [[self searchResults] objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE]];
    }
    
    if (section<[lists count]) {
        return [lists objectAtIndex:section];
    }
 
    return [NSArray array];
}

-(NSMutableArray*)subtractFollowingFriends:(NSMutableArray*)people{
    
    NSMutableArray * following=[NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray* userFollowingList=[[[HomeManager sharedInstance] userFollowingList] mutableCopy];
    
    for (int i=0; i<[userFollowingList count]; i++) {
        for (int j=0; j<[people count]; j++) {
            UserBaseFriendDO *  fr=[people objectAtIndex:j];
            if ([fr compareFriendToFollowingUser:[userFollowingList objectAtIndex:i]]) {
                fr.currentStatus=kFriendHSFollowing;
                [following addObject:fr];
                [userFollowingList removeObjectAtIndex:i--];
                break;
            }
            
        }
        
    }
    //mark objects as following
 
    for (int i=0; i<[following count]; i++) {
        [[following objectAtIndex:i] setCurrentStatus:kFriendHSFollowing];
    }
    return following;
}
-(NSMutableArray*)subtractNotFollowingFriends:(NSMutableArray*)people{
    //1. copy all users as following
    NSMutableArray * notFollowing=[people mutableCopy];
    NSMutableArray* userFollowingList=[[[HomeManager sharedInstance] userFollowingList] mutableCopy];
    
    //2. loop through all items if user is followed remove from notFollowing array
    for (int i=0; i<[userFollowingList count]; i++) {
        for (int j=0; j<[notFollowing count]; j++) {
            UserBaseFriendDO *  fr=[notFollowing objectAtIndex:j];
            if ([fr compareFriendToFollowingUser:[userFollowingList objectAtIndex:i]]) {
                 [notFollowing removeObjectAtIndex:j--];
            }
        }
    }
    
    //mark objects as not following
 
    for (int i=0; i<[notFollowing count]; i++) {
        [[notFollowing objectAtIndex:i] setCurrentStatus:kFriendHSNotFollowing];
    }
    
    return notFollowing;
}

#pragma mark Data parsers

-(void)parseSearchResults:(id)serverResponse{
    if (![self searchResults]) {
        [self setSearchResults: [NSMutableDictionary dictionaryWithCapacity:0]];
    }
    
    FindFriendsResponse * response=(FindFriendsResponse*)serverResponse;
    
    NSArray * needInvite=[[response unknown] copy];
    
    if (needInvite && [needInvite count]>0) {
       
        [[self searchResults] setObject:needInvite forKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE];
        
    }
    
    NSArray * following = [self subtractFollowingFriends:[response users]];
    if (following && [following count]>0)
        [[self searchResults] setObject:following forKey:FRIENDS_SEARCH_RESPONSE_NEED_UNFOLLOW];
    
    NSArray * notfollowing = [self subtractNotFollowingFriends:[response users]];
    if (notfollowing && [notfollowing count]>0)
        [[self searchResults] setObject:notfollowing forKey:FRIENDS_SEARCH_RESPONSE_NEED_FOLLOW];
    
    
    NSArray * invited=[[response invited] copy];
    if (invited && [invited count]>0)
    {
       
        [[self searchResults] setObject:invited forKey:FRIENDS_SEARCH_RESPONSE_INVITED];
    }
}

-(void)parseSearchResultsAddressBook:(id)serverResponse withInitialData:(NSArray*)people{
    if (![self searchResults]) {
        [self setSearchResults:[NSMutableDictionary dictionaryWithCapacity:0]];
    }
    
    NSMutableArray * mutPeople=[NSMutableArray arrayWithArray:[people copy]];
    
    FindFriendsResponse * response=(FindFriendsResponse*)serverResponse;
    
    NSArray * needInvite=[[response unknown] copy];
    NSArray * following = [self subtractFollowingFriends:[response users]];
    NSArray * notfollowing = [self subtractNotFollowingFriends:[response users]];
    NSArray * invited=[[response invited] copy];
   

    NSMutableArray *_needInv=[NSMutableArray array];
    NSMutableArray *_invited=[NSMutableArray array];
    
    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:[mutPeople count]];
    for (int i=0; i<[mutPeople count]; i++) {
        AddrBookFriendDO * friend=[mutPeople objectAtIndex:i];
        [dict setObject:friend forKey:friend.hashedEmail];
    }

    if (needInvite && [needInvite count]>0) {
       
        for (int i=0; i<[needInvite count]; i++) {
            AddrBookFriendDO * r1=[needInvite objectAtIndex:i];
            AddrBookFriendDO * friend=[dict objectForKey:r1.email];
            friend.currentStatus=kFriendNotHomestyler;
            if (friend) {
                [_needInv addObject:friend];
            }
        }
        
        [[self searchResults] setObject:_needInv forKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE];
    }
    
    if (invited && [invited count]>0)
    {
        for (int i=0; i<[invited count]; i++) {
            AddrBookFriendDO * r1=[invited objectAtIndex:i];
            AddrBookFriendDO * friend=[dict objectForKey:r1.email];
            friend.currentStatus=kFriendInvited;
            if (friend) {
                [_invited addObject:friend];
            }
            
        }
    
        [[self searchResults] setObject:_invited forKey:FRIENDS_SEARCH_RESPONSE_INVITED];

    }
    
     if (following && [following count]>0)
        [[self searchResults] setObject:following forKey:FRIENDS_SEARCH_RESPONSE_NEED_UNFOLLOW];
    
    if (notfollowing && [notfollowing count]>0)
        [[self searchResults] setObject:notfollowing forKey:FRIENDS_SEARCH_RESPONSE_NEED_FOLLOW];
}

-(void)clearSearchResultsFromSelfUser{
    
    if ([self searchResults]==nil) {
        return;
    }
    
    NSString * loggedInUserID=[[[UserManager sharedInstance] currentUser]userID];
    if (loggedInUserID) {
        
        for (NSString * key  in [[self searchResults] allKeys]) {
            NSArray * ar=[[self searchResults] objectForKey:key];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id != %@", loggedInUserID];
            NSMutableArray *filteredArray = [[ar filteredArrayUsingPredicate:predicate] mutableCopy];
            if (filteredArray && [filteredArray count]>0) {
                [[self searchResults] setObject:filteredArray forKey:key];
            }else{
                [[self searchResults] removeObjectForKey:key];
            }
            
        }
    }
}

-(void)resetSearchResults{
    [[self searchResults] removeAllObjects];
}

-(void)updateFollowingStatesAfterFollowChange:(NSString*)userId isFollow:(BOOL)isFollowing{
    
    if (!self.searchResults || userId==nil) {
        return;
    }
    
    NSArray * results;
    //IsFollowing means now it started following
    if (isFollowing==FALSE) {
        results = [self.searchResults objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_UNFOLLOW];
    }else{
        results = [self.searchResults objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_FOLLOW];
        
    }
    
    for (int i=0; i<[results count]; i++) {
        UserBaseFriendDO *bf=[results objectAtIndex:i];
        
        if ([[bf _id] isEqualToString:userId]) {
            bf.currentStatus=(isFollowing==true)?kFriendHSFollowing:kFriendHSNotFollowing;
            break;
        }
    }
}

#pragma mark- Address Book actions
- (void)checkForAddressBookAccessWithComplition:(AddressBookAccessBlock)completion queue:(dispatch_queue_t)queue
{
    // iOS6
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL,NULL);
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if(error)
            {
                dispatch_async(queue, ^{
                    completion(NO);
                });
            }
            else
            {
                dispatch_async(queue, ^{
                    completion(YES);
                });
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        dispatch_async(queue, ^{
            completion(YES);
        });
    }
    else
    {
        dispatch_async(queue, ^{
            completion(NO);
        });
    }
}

-(BOOL)isUserHaveAddressBookContacts{
    
    return [[self getAddressBookContactsWithEmails] count]!=0;
}

-(NSArray *)getAddressBookContactsWithEmails{
    
    NSMutableArray * emailContacts=[NSMutableArray arrayWithCapacity:0];
    ABAddressBookRef m_addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
    CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
    NSMutableDictionary * tempDict=[NSMutableDictionary dictionaryWithCapacity:0];
    
    for (int i=0;i<nPeople;i++) {
         ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
       //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            
            AddrBookFriendDO * friend=[[AddrBookFriendDO alloc] initWithContactFromAddressBook:ref];
           
            if (![tempDict objectForKey:[friend hashedEmail]]&& friend.email && [friend.email isStringValidEmail]) {
                [emailContacts addObject:friend];
                [tempDict setObject:@"" forKey:[friend hashedEmail]];
            }
        }
    }
    
  return [emailContacts copy];
}

#pragma mark- Server searches
-(void)searchAddressFriendsOnServerWithCompletion:(HSCompletionBlock)completion
                                            queue:(dispatch_queue_t)queue{
    [self resetSearchResults];
    if(![[HomeManager sharedInstance] isInitializedFollowingList]){
        
        [[HomeManager sharedInstance] getMyFollowingWithCompletion:^{
            
            //call original method again
            [self searchAddressFriendsOnServerWithCompletion:completion queue:queue];
            
        } failureBlock:^(NSError *error) {
            
        } queue:queue];
       
        return;
    }
   
    //create request dictionary that will be moved to json array
    NSMutableDictionary * searcDict=[NSMutableDictionary dictionaryWithCapacity:0];
  
    //get address contacts with emails only
    NSArray * people = [self getAddressBookContactsWithEmails];
    
    NSMutableArray * arraySearch=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<[people count]; i++) {
        
        if ([[people objectAtIndex:i] hashedEmail]) {
                [arraySearch addObject:@{@"e":[[people objectAtIndex:i] hashedEmail],@"n": @""}];
                
        }     
    }
    
    [searcDict setObject:arraySearch forKey:@"users"];
    [searcDict setObject:[NSNumber numberWithInt:kSearchRequestContactList] forKey:@"type"];
    
    if (arraySearch==nil && [arraySearch count]==0) {
        
        
        NSString * erMessage=@"";
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
        
        return;
    }
    
    [[FindFriendsRO new] findUserByEmail:searcDict completionBlock:^(id serverResponse) {
        
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            [self parseSearchResultsAddressBook:serverResponse withInitialData:people];
            
            [self clearSearchResultsFromSelfUser];
            
            if(completion)completion(serverResponse,nil);
        }else{
            if(completion)completion(nil,response.hsLocalErrorGuid);
        }

    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    } queue:queue];
}

-(void)searchFacebookFriendsWithCompletionInternal:(HSCompletionBlock)completion
                                     queue:(dispatch_queue_t)queue
{
    if(![[HomeManager sharedInstance] isInitializedFollowingList]){
        
        [[HomeManager sharedInstance] getMyFollowingWithCompletion:^{
            
            //call original method again
            [self searchFacebookFriendsWithCompletionInternal:completion queue:queue];
            
        } failureBlock:^(NSError *error) {
            
        } queue:queue];
        
        return;
    }
    
    
//    NSString * accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
//    if(!accessToken)
//    {
//        if(completion)
//            completion(nil,nil);
//
//        return ;
//    }
    
//    [[FindFriendsRO new] findFacebookFriends:accessToken withCompletionBlock:^(id serverResponse) {
//        
//        BaseResponse * response=(BaseResponse*)serverResponse;
//        if (response && response.errorCode==-1) {
//            [self parseSearchResults:serverResponse];
//            [self clearSearchResultsFromSelfUser];
//            
//            if(completion)completion(serverResponse,nil);
//        }else{
//            if(completion)completion(nil,response.hsLocalErrorGuid);
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//        NSString * erMessage = [error localizedDescription];
//        NSString *errguid =  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
//        
//        if(completion)completion(nil,errguid);
//        
//    } queue:queue];
}

-(void)searchFacebookFriendsWithCompletion:(HSCompletionBlock)completion
                                     queue:(dispatch_queue_t)queue{
    
    [self resetSearchResults];
    
    [self searchFacebookFriendsWithCompletionInternal:completion queue:queue];
}

-(void)searchFreeText:(NSString*)text withCompletion:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue{
    
    [self resetSearchResults];
    
    //create request dictionary that will be moved to json array
    
    NSMutableDictionary * searcDict=[NSMutableDictionary dictionaryWithCapacity:0];
    
    
    BOOL isEmail=[text isStringValidEmail];
    NSDictionary * searchObject=nil;
  
    if (isEmail) {
        NSString * hashedEmail=[HelpersRO encodeMD5:[text lowercaseString]];
        searchObject=@{@"e":hashedEmail,@"n": @""};
     }else{
        searchObject=@{@"e":@"",@"n": text};
         
    }
    
    NSArray * arraySearch=[NSArray arrayWithObject:searchObject];
    
    [searcDict setObject:arraySearch forKey:@"users"];
    [searcDict setObject:[NSNumber numberWithInt:kSearchRequestFreeText] forKey:@"type"];
    
    void (^simpleBlock)(id serverResponse)= ^(id serverResponse){
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            [self parseSearchResults:serverResponse];
            
            if ([self getNumberOfResultsFlat]==0 && isEmail) {
                //no results found, add the searched object
                UserBaseFriendDO * bff=[[UserBaseFriendDO alloc] init];
                bff.email=(isEmail)?text:nil;
                bff.firstName=text;//(isEmail)?nil:text;
                bff.currentStatus=kFriendNotHomestyler;
                bff.socialFriendType=kSocialFriendNotSocial;
                NSArray * results=[NSArray arrayWithObject:bff];
                if (!self.searchResults) {
                    self.searchResults=[NSMutableDictionary dictionaryWithCapacity:0];
                }
                [self.searchResults setObject:results forKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE];
            }else{
                if ([self.searchResults  objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE]) {
                    NSArray* items=[self.searchResults objectForKey:FRIENDS_SEARCH_RESPONSE_NEED_INVITE];
                    for (int i=0; i<[items count]; i++) {
                        UserBaseFriendDO * bff=[items objectAtIndex:i];
                        bff.email=(isEmail)?text:nil;
                        bff.firstName=text;
                        bff.currentStatus=kFriendNotHomestyler;
                        bff.socialFriendType=kSocialFriendNotSocial;
                    }
                }
            }
            
            [self clearSearchResultsFromSelfUser];
            
            if(completion)completion(serverResponse,nil);
        }else{
            if(completion)completion(nil,response.hsLocalErrorGuid);
        }

    };
    
    if (isEmail) {
    [[FindFriendsRO new] findUserByEmail:searcDict completionBlock:^(id serverResponse) {
       
        simpleBlock(serverResponse);
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
        
    } queue:queue];

    }else{

        [[FindFriendsRO new] findUserByName:searcDict completionBlock:^(id serverResponse) {
            
            simpleBlock(serverResponse);
  
        } failureBlock:^(NSError *error) {
            NSString * erMessage=[error localizedDescription];
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            
            if(completion)completion(nil,errguid);
        } queue:queue];
    }
}

-(void)inviteFriendToJoinHomestylerViaEmail:(NSString*)email
                             withCompletion:(HSCompletionBlock)completion
                                      queue:(dispatch_queue_t)queue{
    
    NSString * hashedEmail=[HelpersRO encodeMD5:[email lowercaseString]];
    [[FindFriendsRO new] invitationSentViaEmail:hashedEmail completionBlock:^(id serverResponse) {
        
        
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response && response.errorCode==-1) {
             if(completion)completion(serverResponse,nil);
        }else{
            if(completion)completion(nil,response.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    } queue:dispatch_get_main_queue()];
}

-(void)inviteFriendToJoinHomestylerViaFacebook:(NSString*)facebookId
                                withCompletion:(HSCompletionBlock)completion
                                         queue:(dispatch_queue_t)queue{

    [[FindFriendsRO new] invitationSentViaFacebook:facebookId completionBlock:^(id serverResponse) {
        
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            if(completion)completion(serverResponse,nil);
        }else{
            if(completion)completion(nil,response.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    } queue:dispatch_get_main_queue()];
}

@end

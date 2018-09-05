//
//  ProfsManager.h
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfessionalFilterDO.h"
#import "ProfFilterNames.h"
#import "BaseManager.h"
#import "ProfessionalDO.h"
#import "ProfProjectAssetDO.h"


typedef void(^FollowProfessionalsBlock)(NSMutableArray * professionals);
typedef void(^FinishStatusBlock)(BOOL status);

@interface ProfsManager : BaseManager <NSCoding>


+ (ProfsManager *)sharedInstance;

/*-(NSMutableArray*)getProffessionalListByFilter:(NSString*)_selectedProfessionKey
                                  withLocation:(NSString*)_selectedLocationKey
                                    startingAt:(int)startIndex withLimit:(int)limit;
*/

- (void)getProffessionalListByFilter:(NSString*)_selectedProfessionKey
            withLocation:(NSString*)_selectedLocationKey
            startingAt:(int)startIndex
            withLimit:(int)limit
            completionBlock:(HSCompletionBlock)completion
            queue:(dispatch_queue_t)queue;


- (void)getFollowedProfessionalsByUserId:(NSString*)userId
                              startingAt:(int)startIndex
                               withLimit:(int)limit
                         completionBlock:(HSCompletionBlock)completion
                                   queue:(dispatch_queue_t)queue;


- (void)getProffesionalByID:(NSString*)profid
                       completionBlock:(HSCompletionBlock)completion
                                 queue:(dispatch_queue_t)queue;

- (void) updateMyFollowedProfessionalsWithCompletionBlock:(HSCompletionBlock)completion
                                                    queue:(dispatch_queue_t)queue;

@property(nonatomic) BOOL initialFollowedProfessionalDataLoaded;

@property(nonatomic)NSMutableArray * followedProfessionals;
- (void)logout;


- (void) clearFollowingData;
- (void) updateMyFollowedProfessionalsLocaly:(NSMutableArray*)profs;


-(void)getUserFollowedProfessionalsWithFinishBlock:(FinishStatusBlock)finishBlock;



- (void)followProfessional:(NSString*) professionalId
                           followStatus:(BOOL) isFollow
                           completionBlock:(HSCompletionBlock)completion
                           queue:(dispatch_queue_t)queue;

- (BOOL) isProfessionalFollowed:(NSString*)profId;
- (ProfProjectAssetDO*)findDesignInProfessionalsByID:(NSString*)designID;


- (void)getProffesionalFiltersWithCompletionBlock:(void (^)(ProfFilterNames *filterNames))completion;




@end

//
//  ProfsManager.m
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import "ProfsManager.h"
#import "ProfessionalRO.h"
#import "ProfessionalsResponse.h"
#import "ProfessionalFilterResponse.h"

static NSString* const kCacheFollowingProfessionals = @"follow_professionals";

static ProfsManager *sharedInstance = nil;

@interface ProfsManager ()

@property(nonatomic) NSMutableDictionary* _followDictionary;
@property(nonatomic) NSMutableArray * professionalsList;
@property(nonatomic) NSMutableDictionary * professionalsFilters;
@property(atomic)ProfFilterNames * profFilters;
-(void)removeFollowedProfessional:(NSString*)professionalId;
-(ProfessionalDO *)getStoredProfessionalByIDInternal:(NSString*)profid;
-(int)getStoredProfessionalIndexByIDInternal:(NSString*)profid withFilter:(ProfessionalFilterDO*)filter;
- (void)getProffesionalByIDInternal:(NSString*)profid
                    completionBlock:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue;

@end

@implementation ProfsManager

+ (ProfsManager *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[ProfsManager alloc] init];
    });
    
    return sharedInstance;
}


-(id)init{
    self=[super init];
    self.initialFollowedProfessionalDataLoaded=YES;
    self.professionalsFilters=[NSMutableDictionary dictionaryWithCapacity:0];
    self.professionalsList=[NSMutableArray arrayWithCapacity:0];
    self._followDictionary = [[NSMutableDictionary alloc] init];
    self.followedProfessionals=[NSMutableArray arrayWithCapacity:0];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    return self;
}

-(void)logout{
    self.initialFollowedProfessionalDataLoaded=NO;
    [self clearFollowingData];
}

#pragma mark- Class functionality
- (void)getProffessionalListByFilter:(NSString*)_selectedProfessionKey
                        withLocation:(NSString*)_selectedLocationKey
                          startingAt:(int)startIndex
                           withLimit:(int)limit
                     completionBlock:(HSCompletionBlock)completion
                               queue:(dispatch_queue_t)queue{
    BOOL needServerCall=YES;
    
    //create filter key
    NSString * key=@"";
    
    if (_selectedProfessionKey==nil && _selectedLocationKey==nil)
        key=@"all_profs";
    if (_selectedLocationKey==nil && _selectedProfessionKey!=nil)
        key=[NSString stringWithFormat:@"%@_null",_selectedProfessionKey];
    if (_selectedLocationKey!=nil && _selectedProfessionKey==nil)
        key=[NSString stringWithFormat:@"null_%@",_selectedLocationKey];
    if (_selectedLocationKey!=nil && _selectedProfessionKey!=nil)
        key=[NSString stringWithFormat:@"%@_%@",_selectedProfessionKey,_selectedLocationKey];
    
    ProfessionalFilterDO * profFilter=[self.professionalsFilters objectForKey:key];
    if (profFilter!=nil && [profFilter.startIndex intValue]==startIndex && [profFilter.count intValue]==limit) {
        needServerCall=NO;
    }
    
    NSString* filtersStr = @"[]";
    //{\"key\":\"loc\", \"val\":\"1\"},{\"key\":\"prof\", \"val\":\"2\"}
    if (_selectedProfessionKey != nil && _selectedLocationKey != nil) {
        filtersStr = [NSString stringWithFormat:@"[{\"key\":\"loc\", \"val\":\"%@\"},{\"key\":\"prof\", \"val\":\"%@\"}]", _selectedLocationKey, _selectedProfessionKey];
    }
    //{\"key\":\"loc\", \"val\":\"1\"}
    else if (_selectedProfessionKey == nil && _selectedLocationKey != nil) {
        filtersStr = [NSString stringWithFormat:@"[{\"key\":\"loc\", \"val\":\"%@\"}]", _selectedLocationKey];
    }
    //{\"key\":\"prof\", \"val\":\"2\"}
    else if (_selectedProfessionKey != nil && _selectedLocationKey == nil) {
        filtersStr = [NSString stringWithFormat:@"[{\"key\":\"prof\", \"val\":\"%@\"}]", _selectedProfessionKey];
    }
    
    if (needServerCall) {
        if (_selectedLocationKey==nil && _selectedProfessionKey!=nil) {
            needServerCall=NO;
        }
        
        ProfessionalFilterDO * profFilter=[[ProfessionalFilterDO alloc] initWithStartIndex:startIndex withLimit:limit forProfKey:_selectedProfessionKey forLocKey:_selectedLocationKey];
        
        [[ProfessionalRO new] getProfessionalsByFilter:filtersStr startIdx:startIndex resultsCount:limit completionBlock:^(id serverResponse) {
            
            
            ProfessionalsResponse * respProfs=(ProfessionalsResponse*)serverResponse;
            
            if ( respProfs.errorCode==-1) {
                
                
                for (int i=0; i<[respProfs.professionals count]; i++) {
                    ProfessionalDO * prof=[respProfs.professionals objectAtIndex:i];
                    
                    int prevIndex=[self getStoredProfessionalIndexByIDInternal:prof._id withFilter:profFilter];
                    if (prevIndex!=-1) {
                        [ profFilter.professionals replaceObjectAtIndex:prevIndex withObject:prof];
                    }else
                    {
                        [ profFilter.professionals addObject:prof];
                    }
                }
                
                [self.professionalsFilters setObject:profFilter forKey:key];
                
                
                if(completion) completion(serverResponse,nil);
                
            }else{
                if(completion) completion(nil,respProfs.hsLocalErrorGuid);
            }
            
        } failureBlock:^(NSError *error) {
            NSString * erMessage=[error localizedDescription];
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            
            if(completion)completion(nil,errguid);
            
        } queue:queue];
        
    }else{
        
        ProfessionalsResponse * respProfs=[[ProfessionalsResponse alloc]init];
        
        if (profFilter) {
            respProfs.professionals=[profFilter professionals];
            if(completion) completion(respProfs,nil);
        }else{
            
            NSString * erMessage=@"";
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_GENERIC_ERROR] withPrevGuid:nil];
            
            if(completion)completion(nil,errguid);
        }
    }
}

- (void)getProffesionalByIDInternal:(NSString*)profid
                    completionBlock:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue{
    
    
    
    [[ProfessionalRO new] getProfessionalById:profid completionBlock:^(id serverResponse) {
        
        ProfessionalsResponse * respProf=(ProfessionalsResponse*)serverResponse;
        
        if ( respProf.errorCode==-1) {
            
            
            ProfessionalFilterDO * pf=nil;
            if ([self.professionalsFilters objectForKey:@"orphan_profs"]==nil) {
                
                pf =[[ProfessionalFilterDO alloc] initWithStartIndex:0 withLimit:-1 forProfKey:@"orphan" forLocKey:@"profs"];
                [self.professionalsFilters setObject:pf forKey:@"orphan_profs"];
            }else{
                pf=[self.professionalsFilters objectForKey:@"orphan_profs"];
            }
            
            //update the filter with professional data
            [pf.professionals addObject:respProf.currentProfessional];
            
            if(completion) completion(serverResponse,nil);
            
            
        }else{
            if(completion) completion(nil,respProf.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
        
    } queue:dispatch_get_main_queue()];
}

- (void)getProffesionalByID:(NSString*)profid
            completionBlock:(HSCompletionBlock)completion
                      queue:(dispatch_queue_t)queue{
    
    if (profid==nil) {
        
        if(completion) completion(nil,@"");
        return;
    }
    
    for(NSString * key in [self.professionalsFilters allKeys])
    {
        ProfessionalFilterDO * profFilter=[self.professionalsFilters objectForKey:key];
        
        for (int i=0; i<[profFilter.professionals count]; i++) {
            if ([[[profFilter.professionals objectAtIndex:i] _id] isEqualToString:profid]) {
                ProfessionalDO * prof=[profFilter.professionals objectAtIndex:i];
                ProfessionalsResponse * response=[[ProfessionalsResponse alloc]init];
                response.currentProfessional=prof;
                if (prof.isExtraInfoLoaded) {
                    if(completion) completion(response,nil);
                    
                    return;
                    // return prof;
                }else{
                    [self getProffesionalByIDInternal:profid completionBlock:completion queue:queue];
                    return;
                }
                
                
            }
        }
        
    }
    
    [self getProffesionalByIDInternal:profid completionBlock:completion queue:queue];
}

- (BOOL) isProfessionalFollowed:(NSString*)profId; {
    @synchronized (self) {
        return ([self._followDictionary valueForKey:profId] != nil);
    }
}

- (void)followProfessional:(NSString*) professionalId
              followStatus:(BOOL) isFollow
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue{
    
    [[ProfessionalRO new] followProfessional:professionalId followStatus:isFollow completionBlock:^(id serverResponse) {
        
        BaseResponse * respProfs=(BaseResponse*)serverResponse;
        
        if ( respProfs.errorCode==-1) {
            
            //update local storage
            
            if (isFollow) {
                [self._followDictionary setObject:@"" forKey:professionalId];
                ProfessionalDO * p=[self getStoredProfessionalByIDInternal:professionalId];
                if (p!=nil) {
                    [self.followedProfessionals addObject:p];
                    p.likesCount=[NSNumber numberWithInt:[p.likesCount intValue]+1];
                }
            }
            else {
                [self._followDictionary removeObjectForKey:professionalId];
                [self removeFollowedProfessional:professionalId];
                ProfessionalDO * p=[self getStoredProfessionalByIDInternal:professionalId];
                if (p!=nil) {
                    p.likesCount=[NSNumber numberWithInt:[p.likesCount intValue]-1];
                }
            }
            
            if(completion) completion(serverResponse,nil);
        }else{
            if(completion) completion(nil,respProfs.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    } queue:queue];
}

-(void)removeFollowedProfessional:(NSString*)professionalId{
    
    for (int i=0; i<[self.followedProfessionals count]; i++) {
        if ([[[self.followedProfessionals objectAtIndex:i] _id] isEqualToString:professionalId]) {
            [self.followedProfessionals removeObjectAtIndex:i];
            i--;
        }
    }
}

-(ProfessionalDO *)getStoredProfessionalByIDInternal:(NSString*)profid{
    for(NSString * key in [self.professionalsFilters allKeys])
    {
        ProfessionalFilterDO * profFilter=[self.professionalsFilters objectForKey:key];
        
        for (int i=0; i<[profFilter.professionals count]; i++) {
            if ([[[profFilter.professionals objectAtIndex:i] _id
                  ]isEqualToString:profid]) {
                return [profFilter.professionals objectAtIndex:i];
            }
        }
        
    }
    return nil;
}

-(int)getStoredProfessionalIndexByIDInternal:(NSString*)profid  withFilter:(ProfessionalFilterDO*)filter{
    
    for (int i=0; i<[filter.professionals count]; i++) {
        if ([[[filter.professionals objectAtIndex:i] _id
              ]isEqualToString:profid]) {
            return i;
        }
    }
    return -1;
}

- (void) updateMyFollowedProfessionalsLocaly:(NSMutableArray*)profs {
    if (profs == nil) return;
    
    
    [self._followDictionary removeAllObjects];
    
    [self.followedProfessionals removeAllObjects];
    
    for(NSDictionary* professional in profs) {
        [self._followDictionary setObject:@"" forKey:[professional objectForKey:@"id"]];
        ProfessionalDO * prf=[[ProfessionalDO alloc] initWithDict:professional];
        
        [prf updateAdditionalInfoAboutProf:professional];
        [self.followedProfessionals addObject:prf];
    }
}

-(void)clearFollowingData{
    [self._followDictionary removeAllObjects];
    [self.followedProfessionals removeAllObjects];
}

-(void)updateMyFollowedProfessionalsWithCompletionBlock:(HSCompletionBlock)completion
                                                  queue:(dispatch_queue_t)queue {
    
    NSString * userId=[[[[UserManager sharedInstance]currentUser]userID]copy];
    if (!userId) {
        return ;
    }
    
    // return;
    [self getFollowedProfessionalsByUserId:userId startingAt:0 withLimit:300 completionBlock:^(id serverResponse, id error) {
        
        if (error) {
            
            if (completion) {
                completion(nil,error);
            }
            
        }else{
            
            ProfessionalsResponse * resp=(ProfessionalsResponse*)serverResponse;
            [self._followDictionary removeAllObjects];
            [self.followedProfessionals removeAllObjects];
            [self.followedProfessionals addObjectsFromArray:resp.professionals];
            
            for (int i=0; i<[resp.professionals count]; i++ ) {
                ProfessionalDO * prf=[resp.professionals objectAtIndex:i];
                [self._followDictionary setObject:@"" forKey:prf._id];
            }
            
            if (completion) {
                completion(resp,nil);
            }
        }
        self.initialFollowedProfessionalDataLoaded=YES;
        
    } queue:queue];
}

-(void)getUserFollowedProfessionalsWithFinishBlock:(FinishStatusBlock)finishBlock
{
    
    //1. Check if inital data exists, not exists load it
    
    if (self.initialFollowedProfessionalDataLoaded==NO) {
        //sync call
        
        [self updateMyFollowedProfessionalsWithCompletionBlock:^(id serverResponse, id error) {
            
            if (finishBlock)
            {
                finishBlock(error==nil);
            }
        } queue:dispatch_get_main_queue()];
    }else{
        //async call
        NSString * userId=[[[UserManager sharedInstance] currentUser] userID];
        
        //2. Check with Cache Inspector if we have timestamp
        [self checkCacheValidationForUser:userId forAction:kCacheFollowingProfessionals withCompleteBlock:^(BOOL needRefresh) {
            
            if (needRefresh)
            {
                // Restkit takes us back to the main thread, do the loading in another thread
                
                [self updateMyFollowedProfessionalsWithCompletionBlock:^(id serverResponse, id error) {
                    
                    if (finishBlock)
                    {
                        finishBlock(error==nil);
                    }
                    
                    
                } queue:dispatch_get_main_queue()];
            }
            else
            {
                if(finishBlock) finishBlock(YES);
            }
            
        } failureBlock:^(NSError* error) {
            finishBlock(NO);
        }  queue:dispatch_get_main_queue()];
        
    }
}

-(ProfProjectAssetDO*)findDesignInProfessionalsByID:(NSString*)designID{
    
    for(NSString * key in [self.professionalsFilters allKeys])
    {
        ProfessionalFilterDO * profFilter=[self.professionalsFilters objectForKey:key];
        
        for (int i=0; i<[profFilter.professionals count]; i++) {
            ProfessionalDO * pr=[profFilter.professionals objectAtIndex:i];
            ProfProjectAssetDO * psdo=[pr findDesignInProfProjectsByID:designID];
            if (psdo!=nil) {
                return psdo;
            }
        }
        
    }
    
    return  nil;
}

- (void)getProffesionalFiltersWithCompletionBlock:(void (^)(ProfFilterNames *filterNames))completion
{
    if (self.profFilters != nil)
    {
        if (completion)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                           {
                               completion(self.profFilters);
                           });
        }
        
        return;
    }
    
    [[ProfessionalRO new] getProfFiltersWithCompletionBlock:^ (id serverResponse)
     {
         if (serverResponse != nil)
         {
             BOOL isSuccess = ([(BaseResponse*)serverResponse errorCode] == -1);
             
             if (isSuccess)
             {
                 ProfessionalFilterResponse *response = (ProfessionalFilterResponse *) serverResponse;
                 NSArray * combos = [response getCombos];
                 
                 if ([combos count] > 0)
                 {
                     ProfFilterNames *fNames = [[ProfFilterNames alloc] initWithDict:combos];
                     self.profFilters = fNames;
                     
                     if (self.profFilters != nil)
                     {
                         if (completion)
                         {
                             completion(self.profFilters);
                         }
                         return; //success
                     }
                 }
             }
             else
             {
                 HSMDebugLog(@"getProffesionalFiltersWithCompletionBlock error - %ld", (long)[(BaseResponse*)serverResponse errorCode]);
             }
         }
         else
         {
             //if error has occured
             if (completion)
             {
                 completion(nil);
             }
             
             HSMDebugLog(@"getProffesionalFiltersWithCompletionBlock error - server response is nil");
         }
     } failureBlock:^ (NSError *error)
     {
         if (completion)
         {
             completion(nil);
         }
         
         HSMDebugLog(@"getProffesionalFiltersWithCompletionBlock error - failure: %@", error.debugDescription);
         
     } queue:(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))];
    
    return;
}

- (void)getFollowedProfessionalsByUserId:(NSString*)userId
                              startingAt:(int)startIndex
                               withLimit:(int)limit
                         completionBlock:(HSCompletionBlock)completion
                                   queue:(dispatch_queue_t)queue
{
    [[ProfessionalRO new] getProfessionalsByUser:userId startIdx:startIndex resultsCount:limit completionBlock:^(id serverResponse) {
        ProfessionalsResponse * respProfs=(ProfessionalsResponse*)serverResponse;
        
        if ( respProfs.errorCode==-1) {
            if(completion) completion(serverResponse,nil);
        }else{
            if(completion) completion(nil,respProfs.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
        
    } queue:queue];
}

-(void)initializeMyTimestamps:(NSString*)ts{
    NSMutableDictionary * tmpDict = [self.cachedTimestamps mutableCopy];
    [tmpDict setObject:ts forKey:kCacheFollowingProfessionals];
    [self setCachedTimestamps:tmpDict];
}

@end













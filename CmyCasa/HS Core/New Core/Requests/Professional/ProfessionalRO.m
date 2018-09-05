//
//  ProfessionalRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "ProfessionalRO.h"
#import "ProfessionalsResponse.h"
#import "ProfessionalFilterResponse.h"

@implementation ProfessionalRO
+ (void)initialize
{
   
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] GET_PROFS_URL]
                                    withMapping:[ProfessionalsResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] GET_PROFESSIONALS_URL]
                                    withMapping:[ProfessionalsResponse jsonMapping]];
    
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] GET_PROF_BY_ID_URL]
                                    withMapping:[ProfessionalsResponse jsonMapping]];
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] FOLLOW_PROF_URL]
                                    withMapping:[BaseResponse jsonMapping]];
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetProfsFilter]
                                    withMapping:[ProfessionalFilterResponse jsonMapping]];    
}



- (void)getProfessionalsByFilter:(NSString*)filtersStr
                        startIdx:(int)startIdx
                    resultsCount:(int)resultsCount
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue{
    
  

    
 
    
    
    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:0];
    
    [dict setObject:[NSNumber numberWithInt:startIdx] forKey:@"offset"];
    [dict setObject:[NSNumber numberWithInt:resultsCount] forKey:@"limit"];
    [dict setObject:filtersStr forKey:@"f"];
    
    self.requestQueue=queue;

    

    [self getObjectsForAction:[[ConfigManager sharedInstance] GET_PROFS_URL]
                       params:dict
                  withHeaders:NO
              completionBlock:completion 
               failureBlock:failure];
    
    
}





-(void)getProfessionalById:(NSString*)profID
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue{
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
        
        NSArray * objs=[NSArray arrayWithObjects:profID, nil];
        NSArray * keys=[NSArray arrayWithObjects:@"prof_id", nil];
        
//        [HSFlurry logEvent:FLURRY_PROFESIONAL_BY_ID withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        
        
    }
#endif
   
    
    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:0];
    

    [dict setObject:profID forKey:@"id"];
    self.requestQueue=queue;
    

    
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] GET_PROF_BY_ID_URL]
                       params:dict
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
    
    
    
}

- (void)getProfessionalsByUser:(NSString*)userID
                      startIdx:(int)startIdx
                  resultsCount:(int)resultsCount
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue
{
    
    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:0];
    


    [dict setObject:[NSNumber numberWithInt:startIdx] forKey:@"offset"];
    [dict setObject:[NSNumber numberWithInt:resultsCount] forKey:@"limit"];
    [dict setObject:userID forKey:@"id"];
    
    self.requestQueue=queue;
    

    
   
    [self getObjectsForAction:[[ConfigManager sharedInstance] GET_PROFESSIONALS_URL]
                       params:dict
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
}

- (void)getProfFiltersWithCompletionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue
{

    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:0];
    
     
    self.requestQueue=queue;
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetProfsFilter]
                       params:dict
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
}



-(void)followProfessional:(NSString*)professionalId
             followStatus:(Boolean)isFollow
          completionBlock:(ROCompletionBlock)completion
             failureBlock:(ROFailureBlock)failure
                    queue:(dispatch_queue_t)queue{
    
    
    
    self.requestQueue=queue;
    
    NSString* strIsLike = @"true";
    if(!isFollow)strIsLike = @"false";
    
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:professionalId forKey:@"proId"];
    [params setObject:strIsLike forKey:@"follow"];
    
    
    [self postWithAction:[[ConfigManager sharedInstance]FOLLOW_PROF_URL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];

    
    
    
}
@end

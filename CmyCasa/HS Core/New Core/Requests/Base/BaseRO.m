//
//  BaseRO.m
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import <CommonCrypto/CommonDigest.h>

#import "BaseRO.h"
#import "HelpersRO.h"
#import "HSAFHTTPClient.h"
#import "UserManager.h"
#import "PackageManager.h"

#define TEMP_TOKEN_SECRET   @"secret"
#define MAX_RETRIES         (3)

@interface BaseRO ()

- (void)addDefaultParams:(NSMutableDictionary*)params;

@end

@implementation BaseRO

#pragma mark - Class methods

+(RKObjectManager*)managerForAction:(ApiAction*)actionType withBaseUrl:(NSURL*)baseURL andTimeout:(NSInteger)timeout{
    
    RKObjectManager *manager = [actionType getManagerForSelfAction];
    
    NSArray * responses=nil;
    
    if (manager) {
        responses=[manager responseDescriptors];
    }
    
    HSAFHTTPClient *client=[HSAFHTTPClient clientWithBaseURL:baseURL];
    client.HStimeoutInterval=timeout;
    
    manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    [manager.HTTPClient registerHTTPOperationClass:[AFRKJSONRequestOperation class]];
    [manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [manager setRequestSerializationMIMEType:RKMIMETypeFormURLEncoded];
    
    if (responses && [responses count]>0)
    {
        [manager addResponseDescriptorsFromArray:responses];
        for (RKResponseDescriptor* respDesc in [manager responseDescriptors])
        {
            respDesc.baseURL = baseURL;
        }
    }
    
    return manager;
}

+ (void)addResponseDescriptor:(RKResponseDescriptor *)descriptor andApiAction:(ApiAction *)pattern
{

    if (pattern.isServerV2)
    {
        if (pattern.isServerV2 && pattern.isCloud)
        {
            [[AppCore httpRKManagerV2] addResponseDescriptor:descriptor];
        }
        if (pattern.isServerV2 && !pattern.isCloud)
        {
            [[AppCore httpCloudlessRKManagerV2] addResponseDescriptor:descriptor];
        }
        return;
    }
    
    if (pattern.isCloud && pattern.isHttps) {
        [[AppCore httpsRKManager] addResponseDescriptor:descriptor];
    }
    if (pattern.isCloud && pattern.isHttps==NO) {
        [[AppCore httpRKManager] addResponseDescriptor:descriptor];
    }
    if (pattern.isCloud==NO && pattern.isHttps==NO) {
        [[AppCore httpCloudlessRKManager] addResponseDescriptor:descriptor];
    }
    if (pattern.isCloud==NO && pattern.isHttps==YES) {
        [[AppCore httpsCloudlessRKManager] addResponseDescriptor:descriptor];
    }

}

+ (void)addResponseDescriptorForPathPattern:(ApiAction*)pattern
                                withMapping:(RKMapping*)mapping
{
    @synchronized (self) {
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                pathPattern:pattern.action
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        if (pattern.action == nil) {
            return;
        }
        
        if (pattern.isServerV2)
        {
            if (pattern.isServerV2 && pattern.isCloud)
            {
                [[AppCore httpRKManagerV2] addResponseDescriptor:responseDescriptor];
            }
            if (pattern.isServerV2 && !pattern.isCloud)
            {
                [[AppCore httpCloudlessRKManagerV2] addResponseDescriptor:responseDescriptor];
            }
            return;
        }
        
        if (pattern.isCloud && pattern.isHttps) {
            [[AppCore httpsRKManager] addResponseDescriptor:responseDescriptor];
        }
        if (pattern.isCloud && pattern.isHttps==NO) {
            [[AppCore httpRKManager] addResponseDescriptor:responseDescriptor];
        }
        if (pattern.isCloud==NO && pattern.isHttps==NO) {
            [[AppCore httpCloudlessRKManager] addResponseDescriptor:responseDescriptor];
        }
        if (pattern.isCloud==NO && pattern.isHttps==YES) {
            [[AppCore httpsCloudlessRKManager] addResponseDescriptor:responseDescriptor];
        }
        if (pattern.isSSOServer == YES) {
            [[AppCore httpSSORKManager] addResponseDescriptor:responseDescriptor];
        }
    }
}

+ (NSString*)sessionId
{
    return [[UserManager sharedInstance] getSessionId];
}

#pragma mark - Public methods

- (void)getObjectsForAction:(ApiAction*)action
                     params:(NSMutableDictionary*)params
                withHeaders:(BOOL)headers
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
{
    
    
    int currentTry = 1;
    
    if (action.retryCallsDisabled) {
        currentTry = 99;
    }
    
    [self getObjectsForAction:action
                       params:params
                  withHeaders:headers
              completionBlock:completion
                 failureBlock:failure
                    currRetry:currentTry];
}

- (void)postWithAction:(ApiAction*)action
                params:(NSMutableDictionary*)params
           withHeaders:(BOOL)headers
             withToken:(BOOL)token
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
{
    
    int currentTry = 1;
    
    if (action.retryCallsDisabled) {
        currentTry = 99;
    }
    
    [self postWithAction:action
                  params:params
             withHeaders:headers
               withToken:token
         completionBlock:completion
            failureBlock:failure
               currRetry:currentTry];
    
    
}

- (void)putWithAction:(ApiAction*)action
               params:(NSMutableDictionary*)params
          withHeaders:(BOOL)headers
            withToken:(BOOL)token
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure
{
    
    int currentTry = 1;
    
    if (action.retryCallsDisabled) {
        currentTry = 99;
    }
    
    [self putWithAction:action
                 params:params
            withHeaders:headers
              withToken:token
        completionBlock:completion
           failureBlock:failure
              currRetry:currentTry];
}


- (void)deleteWithAction:(ApiAction*)action
                  params:(NSMutableDictionary*)params
             withHeaders:(BOOL)headers
               withToken:(BOOL)token
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure{
    
    int currentTry = 1;
    
    if (action.retryCallsDisabled) {
        currentTry = 99;
    }
    
    [self deleteWithAction:action
                    params:params
               withHeaders:headers
                 withToken:token
           completionBlock:completion
              failureBlock:failure
                 currRetry:currentTry];
}

#pragma mark - Private Methods

- (void)getObjectsForAction:(ApiAction*)action
                     params:(NSMutableDictionary*)params
                withHeaders:(BOOL)headers
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                  currRetry:(NSUInteger)currRetry
{
    NSDictionary *originalParams = [params copy];
    
    // Add request headers if needed
    if (!params) {
        params = [NSMutableDictionary new];
    }
    if (headers) {
        [self addHeaders:params];
    }
    
    [self addDefaultParams:params];
    
    // store params for retry call
    if(params)
        self.tempRequestParams=[params mutableCopy];
    
    // Validate queue
    if (!self.requestQueue) {
        self.requestQueue = dispatch_get_main_queue();
    }
    
    RKObjectManager *rman = [action getManagerForSelfAction];
    
    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    for (NSString *param in [originalParams allKeys])
    {
        if ([param isEqualToString:@"c"] ||     // Parameter "c" is passed for GetProductsByCategoryID
            [param isEqualToString:@"itm"] ||   // Parameter "itm" is passed for GetItem
            [param isEqualToString:@"ft"])      // Parameter "ft" is passed for Design Stream / Empty rooms
        {
            [paramsDict setObject:[originalParams objectForKey:param] forKey:param];
            break;
        }
    }
    
    NSString* JSONString = [[PackageManager sharedInstance] getResponseForAPI:action.action
                                                                 andArguments:paramsDict];
    
    if(JSONString && ![ConfigManager isAnyNetworkAvailable])
    {
        NSError* error;
        NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error)
            return;
        
        //_objectManager is RKObjectManager instance
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in rman.responseDescriptors) {
            if ([descriptor.pathPattern isEqualToString:action.action])
                [mappingsDictionary setObject:descriptor.mapping forKey:@""];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError)
        {
            // Process response
            id responseGeneral= [self processResponse:[mapper mappingResult].array];
            
            BaseResponse* response=(BaseResponse*) responseGeneral;
            
            if (response.errorCode == -1) {
                dispatch_async(self.requestQueue, ^{
                    if(completion)
                        completion(responseGeneral);
                });
            }
        }
        return;
    }
    
    
    // Get, default serialization type is json
    [rman getObjectsAtPath:[action.action stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                parameters:params
                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                       
                       // Process response
                       id responseGeneral= [self processResponse:mappingResult.array];
                       
                       BaseResponse* response=(BaseResponse*) responseGeneral;
                       
                       
                       if (response.errorCode==-1) {
                           dispatch_async(self.requestQueue, ^{
                               if(completion)completion(responseGeneral);
                           });
                       }
                       else
                       {
                           //check error and if retry needed
                           //or silent login needed
                           
                           ErrorDO * hserror=[[ErrorDO alloc]initErrorWithDetails:response.errorMessage withErrorCode:(int)response.errorCode];
                           NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:hserror withPrevGuid:nil];
                           
                           response.hsLocalErrorGuid=errguid;
                           if (hserror.needSilentLogin && currRetry==1) {
                               
                               [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
                                   
                                   BaseResponse * response=(BaseResponse*)serverResponse;
                                   if (error==nil && response!=nil && response.errorCode==-1) {
                                       [self getObjectsForAction:action
                                                          params:params
                                                     withHeaders:headers
                                                 completionBlock:completion
                                                    failureBlock:failure
                                                       currRetry:currRetry + 1];
                                   }else
                                   {
                                       dispatch_async(self.requestQueue, ^{
                                           if(completion)completion(responseGeneral);
                                       });
                                   }
                                   
                               } queue:self.requestQueue];
                               
                               return;
                           }
                           
                           if (hserror.needRetry == YES && currRetry < MAX_RETRIES) {
                               
                               [self getObjectsForAction:action
                                                  params:params
                                             withHeaders:headers
                                         completionBlock:completion
                                            failureBlock:failure
                                               currRetry:currRetry + 1];
                               
                               return ;
                           }
                           
                           dispatch_async(self.requestQueue, ^{
                               if(completion)completion(responseGeneral);
                           });
                           
                       }
                       
                   }
                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                       // Process failure
                       
                       // Add error handling
                       if (currRetry < MAX_RETRIES) {
                           [self getObjectsForAction:action
                                              params:params
                                         withHeaders:headers
                                     completionBlock:completion
                                        failureBlock:failure
                                           currRetry:currRetry + 1];
                       }
                       else
                       {
                           dispatch_async(self.requestQueue, ^{
                               if(failure)failure(error);
                           });
                       }
                   }];
}


-(void)postWithActionAndMultiPartImages:(ApiAction*)action
                             uploadData:(NSMutableDictionary*)uploadImages
                                 params:(NSMutableDictionary*)params
                            withHeaders:(BOOL)headers
                              withToken:(BOOL)token
                        completionBlock:(ROCompletionBlock)completion
                           failureBlock:(ROFailureBlock)failure
{
    
    int currentTry = 1;
    
    if (action.retryCallsDisabled) {
        currentTry = 99;
    }
    
    [self postWithActionAndMultiPartImages:action
                                uploadData:uploadImages
                                    params:params
                               withHeaders:headers
                                 withToken:token
                           completionBlock:completion
                              failureBlock:failure
                                 currRetry:currentTry];
    
}

-(void)postWithActionAndMultiPartImages:(ApiAction*)action
                             uploadData:(NSMutableDictionary*)uploadImages
                                 params:(NSMutableDictionary*)params
                            withHeaders:(BOOL)headers
                              withToken:(BOOL)token
                        completionBlock:(ROCompletionBlock)completion
                           failureBlock:(ROFailureBlock)failure
                              currRetry:(NSUInteger)currRetry{
    
    
    // Request headers are optional. Only add if they are requested
    if (headers)
        [self addHeaders:params];
    
    // Token is optional. Only add if it is requested
    if (token)
        [self addToken:params];
    
    // The default parameters are defined for all requests
    [self addDefaultParams:params];
    
    // Validate queue
    if (!self.requestQueue) {
        self.requestQueue = dispatch_get_main_queue();
    }
    
    // store params for retry call
    self.tempRequestParams = [params mutableCopy];
    
    RKObjectManager *objectManager = [action getManagerForSelfAction];
    
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:action.action
                                                                      parameters:params
                                                       constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData)
                                    {
                                        
                                        for (NSString * key in [uploadImages allKeys]) {
                                            
                                            [formData appendPartWithFileData:uploadImages[key]
                                                                        name:key
                                                                    fileName:@"file"
                                                                    mimeType:@"application/octet-stream"];
                                        }
                                        
                                    }];
    
    
    RKObjectRequestOperation *operation =
    [objectManager objectRequestOperationWithRequest:request
                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         
         
         // Process response
         id responseGeneral= [self processResponse:mappingResult.array];
         
         BaseResponse* response=(BaseResponse*) responseGeneral;
         
         if (response.errorCode==-1) {
             dispatch_async(self.requestQueue, ^{
                 if(completion)completion(responseGeneral);
             });
             
         }else{
             //check error and if retry needed
             //or silent login needed
             
             ErrorDO * hserror = [[ErrorDO alloc]initErrorWithDetails:response.errorMessage withErrorCode:(int)response.errorCode];
             NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:hserror withPrevGuid:nil];
             response.hsLocalErrorGuid=errguid;
             
             if (hserror.needSilentLogin && currRetry==1) {
                 
                 [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
                     
                     BaseResponse * response=(BaseResponse*)serverResponse;
                     if (error==nil && response!=nil && response.errorCode==-1) {
                         [self postWithActionAndMultiPartImages:action
                                                     uploadData:uploadImages
                                                         params:params
                                                    withHeaders:headers
                                                      withToken:token
                                                completionBlock:completion
                                                   failureBlock:failure
                                                      currRetry:currRetry+1];
                     }else
                     {
                         dispatch_async(self.requestQueue, ^{
                             if(completion)completion(responseGeneral);
                         });
                     }
                     
                 } queue:self.requestQueue];
                 
                 
                 return;
             }
             
             if (hserror.needRetry==YES && currRetry<MAX_RETRIES) {
                 
                 [self postWithActionAndMultiPartImages:action
                                             uploadData:uploadImages
                                                 params:params
                                            withHeaders:headers
                                              withToken:token
                                        completionBlock:completion
                                           failureBlock:failure
                                              currRetry:currRetry+1];
                 
                 
                 
                 return ;
             }
             
             
             
             dispatch_async(self.requestQueue, ^{
                 if(completion)completion(responseGeneral);
             });
             
         }
         
         
         
         
         // Success handler.
         NSLog(@"%@", [mappingResult firstObject]);
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         // Error handler.
         
         
         
         if ( currRetry<MAX_RETRIES) {
             [self postWithActionAndMultiPartImages:action
                                         uploadData:uploadImages
                                             params:params
                                        withHeaders:headers
                                          withToken:token
                                    completionBlock:completion
                                       failureBlock:failure
                                          currRetry:currRetry+1];
             
         }else
             dispatch_async(self.requestQueue, ^{
                 if(failure)failure(error);
             });
         
         
     }];
    
    [objectManager enqueueObjectRequestOperation:operation];
}

- (void)deleteWithAction:(ApiAction*)action
                  params:(NSMutableDictionary*)params
             withHeaders:(BOOL)headers
               withToken:(BOOL)token
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
               currRetry:(NSUInteger)currRetry
{
    // Add request headers if needed
    if (headers)
        [self addHeaders:params];
    
    if (token)
        [self addToken:params];
    
    [self addDefaultParams:params];
    
    //validate queue
    if (!self.requestQueue) {
        self.requestQueue = dispatch_get_main_queue();
    }
    
    // store params for retry call
    self.tempRequestParams = [params mutableCopy];
    
    RKObjectManager *manager = [action getManagerForSelfAction];
    
    
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    //delete
    [manager deleteObject:nil
                     path:[action.action stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
               parameters:params
                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                      // Process response
                      id responseGeneral= [self processResponse:mappingResult.array];
                      
                      BaseResponse* response=(BaseResponse*) responseGeneral;
                      
                      if (response.errorCode==-1) {
                          dispatch_async(self.requestQueue, ^{
                              if(completion)completion(responseGeneral);
                          });
                          
                      }else{
                          //check error and if retry needed
                          //or silent login needed
                          ErrorDO * hserror = [[ErrorDO alloc] initErrorWithDetails:response.errorMessage withErrorCode:(int)response.errorCode];
                          NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:hserror withPrevGuid:nil];
                          response.hsLocalErrorGuid=errguid;
                          
                          if (hserror.needSilentLogin && currRetry==1) {
                              
                              [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
                                  BaseResponse * response=(BaseResponse*)serverResponse;
                                  if (error==nil && response!=nil && response.errorCode==-1) {
                                      [self deleteWithAction:action
                                                   params:params
                                              withHeaders:headers
                                                withToken:token
                                          completionBlock:completion
                                             failureBlock:failure
                                                currRetry:currRetry + 1];
                                  }else{
                                      dispatch_async(self.requestQueue, ^{
                                          if(completion)completion(responseGeneral);
                                      });
                                  }
                              } queue:self.requestQueue];
                              return;
                          }
                          
                          if (hserror.needRetry==YES && currRetry<MAX_RETRIES) {
                              
                              [self deleteWithAction:action
                                           params:params
                                      withHeaders:headers
                                        withToken:token
                                  completionBlock:completion
                                     failureBlock:failure
                                        currRetry:currRetry + 1];
                              return ;
                          }
                          
                          dispatch_async(self.requestQueue, ^{
                              if(completion)completion(responseGeneral);
                          });
                          
                      }
                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      if ( currRetry<MAX_RETRIES) {
                          [self deleteWithAction:action
                                       params:params
                                  withHeaders:headers
                                    withToken:token
                              completionBlock:completion
                                 failureBlock:failure
                                    currRetry:currRetry + 1];
                      }else
                          dispatch_async(self.requestQueue, ^{
                              if(failure)failure(error);
                          });
                  }];
}

- (void)putWithAction:(ApiAction*)action
                   params:(NSMutableDictionary*)params
                  headers:(NSDictionary *)headers
                withToken:(BOOL)token
          completionBlock:(ROCompletionBlock)completion
             failureBlock:(ROFailureBlock)failure
{
    NSDictionary * defaultHeaders = [[action getManagerForSelfAction] defaultHeaders];

    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [defaultHeaders setValue:obj forKey:key];
    }];

    [self putWithAction:action params:params withHeaders:NO withToken:token completionBlock:completion failureBlock:failure];
}

- (void)putWithAction:(ApiAction*)action
               params:(NSMutableDictionary*)params
          withHeaders:(BOOL)headers
            withToken:(BOOL)token
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure
            currRetry:(NSUInteger)currRetry
{
    // Add request headers if needed
    if (headers)
        [self addHeaders:params];
    
    if (token)
        [self addToken:params];
    
    [self addDefaultParams:params];
    
    //validate queue
    if (!self.requestQueue) {
        self.requestQueue = dispatch_get_main_queue();
    }
    
    // store params for retry call
    self.tempRequestParams = [params mutableCopy];
    
    
    RKObjectManager *manager = [action getManagerForSelfAction];
    
    
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Put
    [manager putObject:nil
                  path:[action.action stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
            parameters:params
               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                   // Process response
                   id responseGeneral= [self processResponse:mappingResult.array];
                   
                   // TODO:
                   if ([mappingResult.array count]==0) {
                       BaseResponse* temp = [BaseResponse new];
                       temp.errorCode = -1;
                       responseGeneral = temp;
                    }
                   
                   BaseResponse* response=(BaseResponse*) responseGeneral;

                   if (response.errorCode==-1) {
                       dispatch_async(self.requestQueue, ^{
                           if(completion)completion(responseGeneral);
                       });
                       
                   }else{
                       //check error and if retry needed
                       //or silent login needed
                       ErrorDO * hserror = [[ErrorDO alloc] initErrorWithDetails:response.errorMessage withErrorCode:(int)response.errorCode];
                       NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:hserror withPrevGuid:nil];
                       response.hsLocalErrorGuid=errguid;
                       
                       if (hserror.needSilentLogin && currRetry==1) {
                           
                           [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
                               BaseResponse * response=(BaseResponse*)serverResponse;
                               if (error==nil && response!=nil && response.errorCode==-1) {
                                   [self putWithAction:action
                                                params:params
                                           withHeaders:headers
                                             withToken:token
                                       completionBlock:completion
                                          failureBlock:failure
                                             currRetry:currRetry + 1];
                               }else{
                                   dispatch_async(self.requestQueue, ^{
                                       if(completion)completion(responseGeneral);
                                   });
                               }
                           } queue:self.requestQueue];
                           return;
                       }
                       
                       if (hserror.needRetry==YES && currRetry<MAX_RETRIES) {
                           
                           [self putWithAction:action
                                        params:params
                                   withHeaders:headers
                                     withToken:token
                               completionBlock:completion
                                  failureBlock:failure
                                     currRetry:currRetry + 1];
                           return ;
                       }
                       
                       dispatch_async(self.requestQueue, ^{
                           if(completion)completion(responseGeneral);
                       });
                       
                   }
               } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                   if ( currRetry<MAX_RETRIES) {
                       [self putWithAction:action
                                    params:params
                               withHeaders:headers
                                 withToken:token
                           completionBlock:completion
                              failureBlock:failure
                                 currRetry:currRetry + 1];
                   }else
                       dispatch_async(self.requestQueue, ^{
                           if(failure)failure(error);
                       });
                   
                   
               }];
}

- (void)postWithAction:(ApiAction*)action
                params:(NSMutableDictionary*)params
           withHeaders:(BOOL)headers
             withToken:(BOOL)token
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
             currRetry:(NSUInteger)currRetry
{
    // Add request headers if needed
    if (headers)
        [self addHeaders:params];
    
    if (token)
        [self addToken:params];
    
    if (action != [[ConfigManager sharedInstance] getSSOLogin])
        [self addDefaultParams:params];
    
    //validate queue
    if (!self.requestQueue) {
        self.requestQueue=dispatch_get_main_queue();
    }
    
    // store params for retry call
    self.tempRequestParams=[params mutableCopy];
    
    
    RKObjectManager *manager=[action getManagerForSelfAction];
    
    
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Post
    [manager
     postObject:nil
     path:[action.action stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
     parameters:params
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         // Process response
         id responseGeneral= [self processResponse:mappingResult.array];
         
         BaseResponse* response=(BaseResponse*) responseGeneral;
         
         if (response.errorCode==-1) {
             dispatch_async(self.requestQueue, ^{
                 if(completion)completion(responseGeneral);
             });
             
         }else{
             //check error and if retry needed
             //or silent login needed
             
             ErrorDO * hserror = [[ErrorDO alloc]initErrorWithDetails:response.errorMessage withErrorCode:(int)response.errorCode];
             NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:hserror withPrevGuid:nil];
             response.hsLocalErrorGuid=errguid;
             
             if (hserror.needSilentLogin && currRetry==1) {
                 
                 [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
                     
                     BaseResponse * response=(BaseResponse*)serverResponse;
                     if (error==nil && response!=nil && response.errorCode==-1) {
                         [self postWithAction:action
                                       params:params
                                  withHeaders:headers
                                    withToken:token
                              completionBlock:completion
                                 failureBlock:failure
                                    currRetry:currRetry + 1];
                     }else
                     {
                         dispatch_async(self.requestQueue, ^{
                             if(completion)completion(responseGeneral);
                         });
                     }
                     
                 } queue:self.requestQueue];
                 
                 
                 return;
             }
             
             if (hserror.needRetry==YES && currRetry<MAX_RETRIES) {
                 
                 [self postWithAction:action
                               params:params
                          withHeaders:headers
                            withToken:token
                      completionBlock:completion
                         failureBlock:failure
                            currRetry:currRetry + 1];
                 
                 
                 
                 return ;
             }
             
             
             
             dispatch_async(self.requestQueue, ^{
                 if(completion)completion(responseGeneral);
             });
             
         }
         
         
     }
     failure:^(RKObjectRequestOperation *operation, NSError *error) {
         
         
         if ( currRetry<MAX_RETRIES) {
             [self postWithAction:action
                           params:params
                      withHeaders:headers
                        withToken:token
                  completionBlock:completion
                     failureBlock:failure
                        currRetry:currRetry + 1];
         }else
             dispatch_async(self.requestQueue, ^{
                 if(failure)failure(error);
             });
         
         
     }];
}

#pragma mark - Helpers

- (void)addHeaders:(NSMutableDictionary*)params
{
    if ([[UserManager sharedInstance] getSessionId] != nil)
    {
        [params setValuesForKeysWithDictionary:@{@"s" : [[UserManager sharedInstance] getSessionId]}];    // Language
    }
    
}

- (void)addDefaultParams:(NSMutableDictionary*)params
{
    
    //hotfix for ffd made by tomer
    if ([params objectForKey:@"l"]) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * currentLocale = [defaults objectForKey:@"lang_symbole"];
    
    if (!currentLocale)
        currentLocale = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if ([currentLocale isEqualToString:@"pt"]) {
        currentLocale = @"pt-br";
    }
    
    //Tom: Temp fix for server bug. Should be removed when the server knows how to deal with "en" value
    if ([currentLocale isEqualToString:@"en"]) {
        currentLocale = @"en_US";
    }
    
    if ([currentLocale containsString:@"zh-Hans"]) {
        currentLocale = @"zh_CN";
    }
    
    [params setValuesForKeysWithDictionary:@{
                                             @"v" : @"1.4",             /*@"v" : API_VERSION,*/ // Version
                                             @"l" : currentLocale}];    // Language
    
}

- (void)addToken:(NSMutableDictionary*)params
{
    
    NSDictionary* tokenDict = [self generateToken:YES];
    [params setValuesForKeysWithDictionary:@{@"t" : tokenDict[@"Token"],    // Token
                                             @"ts" : tokenDict[@"Time"]}];  // Timestamp;
    
    
}

- (id)processResponse:(NSArray*)responseObjects
{
    // Apply Post Server Actions if needed
    for (id<RestkitObjectProtocol> currResponseObject in responseObjects)
    {
        if ([currResponseObject respondsToSelector:@selector(applyPostServerActions)])
        {
            [currResponseObject applyPostServerActions];
        }
    }
    
    
    // Check there is only one object
    if (responseObjects.count == 1)
    {
        return responseObjects[0];
    }
    else
    {
        return    responseObjects;
        
    }
    
}


- (void)processFailure:(NSError*)error
             currRetry:(NSUInteger)currRetry
            retryBlock:(void(^)())retry
      withFailureBlock:(ROFailureBlock)failure
{
    NSLog(@"Finished Retry #%lu", (unsigned long)currRetry);
    if (currRetry < MAX_RETRIES)
    {
        retry();
    }
    else
    {
        if (failure)
        {
            failure(error);
        }
    }
}



- (NSDictionary*)generateToken:(Boolean)useSessionId {
    
    NSDate* roundedDateTime = [HelpersRO getCurrentRoundedDateTime];
    
    double timeInterval = [roundedDateTime timeIntervalSince1970];
    timeInterval = floor(timeInterval);
    NSString* unixUtcDateTimeStr =[NSString stringWithFormat:@"%.0lf", timeInterval];
    
    NSString* tokenStr = nil;
    
    if ([[UserManager sharedInstance] getSessionId] == nil) {
        tokenStr = [NSString stringWithFormat:@"%@%@", unixUtcDateTimeStr, TEMP_TOKEN_SECRET];
    }
    else {
        tokenStr = [NSString stringWithFormat:@"%@%@", unixUtcDateTimeStr, [[UserManager sharedInstance]getSessionId]];
    }
    
    tokenStr = [HelpersRO encodeSHA256:tokenStr];
    tokenStr = [HelpersRO encodeSHA256:tokenStr];
    tokenStr = [HelpersRO encodeSHA256:tokenStr];
    tokenStr = [HelpersRO encodeSHA256:tokenStr];
    
    // Returns token & time
    return @{@"Time" : unixUtcDateTimeStr,
             @"Token" : tokenStr};
}


@end

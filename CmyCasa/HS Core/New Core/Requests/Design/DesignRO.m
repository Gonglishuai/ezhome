//
//  DesignRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "DesignRO.h"
#import "SaveDesignRequestObject.h"
#import "MD5Categories.h"
#import "SaveDesignResponse.h"
#import "ProductResponse.h"
#import "NSString+Contains.h"

#define SAVE_DESIGN_OS_TYPE 1  //1- ios 2- android

@implementation DesignRO
+(void)initialize{
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] DUPLICATE_DESIGN_URL]
                                    withMapping:[DesignDuplicateResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] CHANGE_DESIGN_STATUS_URL]
                                    withMapping:[BaseResponse jsonMapping]];
  
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] CHANGE_DESIGN_METADATA_URL]
                                    withMapping:[BaseResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getProductListForItems]
                                    withMapping:[ProductResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getPrivateGalleryItemURL]
                                    withMapping:[DesignGetItemResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getGalleryItemURL]
                                    withMapping:[DesignGetItemResponse jsonMapping]];
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] addLikeURL]
                                    withMapping:[BaseResponse jsonMapping]];
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] SAVE_DESIGN_URL]
                                    withMapping:[SaveDesignResponse jsonMapping]];

    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetAssetLikes]
                                    withMapping:[FollowResponse jsonMapping]];

}

- (void)designDuplicate:(NSString*)designID
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue{
    
    
    self.requestQueue=queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:designID forKey:@"id"];
    
    [self postWithAction:[[ConfigManager sharedInstance]DUPLICATE_DESIGN_URL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
}

- (void)designChangeStatus:(NSString*)designID
                 newStatus:(DesignStatus) status
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    if (!designID) {
        
        if ( failure!=Nil) {
            NSError * error = [NSError errorWithDomain:@"Invalid design" code:-10 userInfo:nil];
            failure(error);
        }
        
        return;
    }
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:designID forKey:@"id"];
    [params setObject:[NSNumber numberWithInt:status] forKey:@"status"];
    
    [self postWithAction:[[ConfigManager sharedInstance]CHANGE_DESIGN_STATUS_URL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}

- (void)designChangeMetadata:(NSString*)designID
                    newTitle:(NSString*) title
              newDescription:(NSString*)desc
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:designID forKey:@"id"];
    [params setObject:title forKey:@"title"];
    [params setObject:desc forKey:@"description"];
    
    [self postWithAction:[[ConfigManager sharedInstance]CHANGE_DESIGN_METADATA_URL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
}

- (void)designGetPrivateItem:(NSString*)designID
                     andType:(ItemType)itemType
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue{
    

    self.requestQueue = queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:designID forKey:@"itm"];
    [params setObject:[NSNumber numberWithInt:itemType] forKey:@"tp"];
    [params setObject:@"ios" forKey:@"dt"];

    
    
    [self postWithAction:[[ConfigManager sharedInstance] getPrivateGalleryItemURL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
    
}


-(void)productListForItems:(NSArray*)uniqueItemList
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[ConfigManager getTenantIdName] forKey:@"tenant"];
    [params setObject:uniqueItemList forKey:@"productIds"];
    [params setObject:@"en" forKey:@"language"];
    
    [self postWithAction:[[ConfigManager sharedInstance] getProductListForItems]
                  params:params
             withHeaders:NO
               withToken:NO
         completionBlock:completion
            failureBlock:failure];
}

- (void)designGetPublicItem:(NSString*)designID
                    andType:(ItemType)itemType
                   richData:(BOOL)richData
              withTimestamp:(NSString*)timestamp
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                      queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    if (designID != nil)
    {
        [params setObject:designID forKey:@"itm"];
    }
    [params setObject:[NSNumber numberWithInt:itemType] forKey:@"tp"];
    [params setObject:@"ios" forKey:@"dt"];
    
    if (timestamp) {
        [params setObject:timestamp forKey:@"tkill"];
    }

    [params setObject:@(richData) forKey:@"rich"];

    NSString * sessionId = [[UserManager sharedInstance] getSessionId];
    if (![NSString isNullOrEmpty:sessionId]) {
        [params setObject:sessionId forKey:@"sk"];
    }

    [self getObjectsForAction:[[ConfigManager sharedInstance] getGalleryItemURL]
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
}

-(void)designLike:(NSString*)designID
          isLiked:(BOOL)like
  completionBlock:(ROCompletionBlock)completion
     failureBlock:(ROFailureBlock)failure
            queue:(dispatch_queue_t)queue{
    
    if (designID==nil) {
        failure(nil);
        return;
    }
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSArray * objs=[NSArray arrayWithObjects:designID,[NSNumber numberWithBool:like], nil];
        NSArray * keys=[NSArray arrayWithObjects:@"item ID",@"isLike", nil];
//        [HSFlurry logEvent:FLURRY_LIKE withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
     
    }
#endif
    
    
    
 
    self.requestQueue=queue;
    
    NSString* strIsLike = @"true";
    if(!like)strIsLike = @"false";
    
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:designID forKey:@"itm"];
    [params setObject:strIsLike forKey:@"like"];
 
    
    [self postWithAction:[[ConfigManager sharedInstance]addLikeURL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}




- (void) saveDesign:(SaveDesignRequestObject*)designObject completionBlock:(ROCompletionBlock)completion
       failureBlock:(ROFailureBlock)failure
              queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
   
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:(designObject.name)?designObject.name:@"" forKey:@"n"];
    [params setObject:designObject.json forKey:@"json"];
    [params setObject:designObject.roomType forKey:@"rt"];
    [params setObject:(designObject.isPublished ? @"1" : @"0") forKey:@"status"];
    [params setObject:(designObject._description)?designObject._description:@"" forKey:@"d"];
    [params setObject:(designObject.parentId)?designObject.parentId:[NSNull null] forKey:@"o"];
    [params setObject:[NSNumber numberWithInt:SAVE_DESIGN_OS_TYPE] forKey:@"appt"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [params setObject:version forKey:@"appv"];
    
    if (!designObject.isNewDesign) {
        [params setObject:designObject.designId forKey:@"sid"];
    }

    float qualityLevel=0.9;
    
    NSMutableDictionary * imagesDataDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (designObject.originalImage) {
       UIImage *initial = [UIImage imageWithCGImage:[designObject.originalImage CGImage] scale:[designObject.originalImage scale] orientation:UIImageOrientationUp];
        NSData* initialRep = UIImageJPEGRepresentation([initial scaleToFitLargestSide:1024], qualityLevel);
        // [request setData:initialRep forKey:@"initial"];
        [params setObject:[initialRep md5InBase64] forKey:@"initialMD5"];
        [imagesDataDict setObject:initialRep forKey:@"initial"];
    }
   
    if (designObject.editedImage) {
        UIImage *background = [UIImage imageWithCGImage:[designObject.editedImage CGImage] scale:[designObject.editedImage scale] orientation:UIImageOrientationUp];
        NSData* backgroundRep = UIImageJPEGRepresentation([background scaleToFitLargestSide:1024], qualityLevel);
        //
        [params setObject:[backgroundRep md5InBase64] forKey:@"backgroundMD5"];
        // backgroundRep = nil;
        [imagesDataDict setObject:backgroundRep forKey:@"background"];
    }
    
    if (designObject.imageWithFurnitures) {
       UIImage *final = [UIImage imageWithCGImage:[designObject.imageWithFurnitures CGImage] scale:[designObject.imageWithFurnitures scale] orientation:UIImageOrientationUp];
        NSData* finalRep = UIImageJPEGRepresentation([final scaleToFitLargestSide:1024], qualityLevel);
        [params setObject:[finalRep md5InBase64] forKey:@"finalMD5"];
        // finalRep = nil;
        [imagesDataDict setObject:finalRep forKey:@"final"];
    }
    
    UIImage* maskImage = nil;
    if(designObject.in_maskImage)
    {
        maskImage = [UIImage imageWithCGImage:[designObject.in_maskImage CGImage] scale:[designObject.in_maskImage scale] orientation:UIImageOrientationUp];
        
        NSData* maskRep = UIImagePNGRepresentation([maskImage scaleToFitLargestSide:1024]);
        //
        [params setObject:[maskRep md5InBase64] forKey:@"maskMD5"];
        [imagesDataDict setObject:maskRep forKey:@"mask"];
    }
    
    [self postWithActionAndMultiPartImages:[[ConfigManager sharedInstance]SAVE_DESIGN_URL]
                                uploadData:imagesDataDict
                                    params:params
                               withHeaders:YES
                                 withToken:YES
                           completionBlock:completion
                              failureBlock:failure];
}

- (void)getAssetLikes:(NSString*)assetId
             withType:(AssetItemType)assetItemType
               offset:(NSInteger)offset
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure
                queue:(dispatch_queue_t)queue {

    self.requestQueue = queue;

    if ([NSString isNullOrEmpty:assetId]) {
        if (failure != nil) {
            failure(nil);
        }
        return;
    }

    NSMutableDictionary * params = [@{@"assetId":assetId, @"type":[NSNumber numberWithInt:assetItemType], @"offset":@(offset), @"limit":@(100)} mutableCopy];

    NSString * sessionId = [[UserManager sharedInstance] getSessionId];
    if (![NSString isNullOrEmpty:sessionId]) {
        [params setObject:sessionId forKey:@"s"];
    }

    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetAssetLikes]
                       params:params
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
}

@end







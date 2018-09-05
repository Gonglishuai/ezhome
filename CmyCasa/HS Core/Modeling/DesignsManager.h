//
//  DesignsManager.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 10/29/14.
//


#import <Foundation/Foundation.h>
#import "SavedDesign.h"
#import "BaseManager.h"
#import "BaseRO.h"
#import "UserProfile.h"
#import "SavedDesign.h"

#define SavedDesignsPath @"saved_designs"


@interface DesignsManager : BaseManager <NSCoding>

@property (nonatomic, strong) SavedDesign * workingDesign;          // holds the current working design (only one)
@property (nonatomic, strong) NSMutableArray * designsArray;        // holds only MyDesignDO obj (autosave file, offline files and server files)
@property (nonatomic, strong) NSMutableArray * designsMapIdsArray;  // holds dictionaries of each item store  on the device (autosave file and offline files)
@property (nonatomic, assign) NSTimeInterval autoSaveInterval;      // holds the autosave interval time
@property (nonatomic, strong) NSMutableArray *productInfoArray;     // hold the prduct info for each model in the current design
@property (nonatomic, strong) NSTimer *autosaveTimer;               // auto save time
@property (nonatomic, strong) dispatch_queue_t designManagerQueue;  // working queue
@property (nonatomic, assign) BOOL isSyncWorking;

+ (DesignsManager *)sharedInstance;

- (void)saveDesignOnServer:(BOOL)overideRequested
                  isPublic:(BOOL)isPublic
                 withTitle:(NSString*)dTitle
            andDescription:(NSString*)desc
               andRoomType:(NSString*)roomType
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;

-(void)deleteDesign:(NSString*)_id
    completionBlock:(HSCompletionBlock)completion
              queue:(dispatch_queue_t)queue;

-(void)duplicateDesign:(NSString*)_id
       completionBlock:(HSCompletionBlock)completion
                 queue:(dispatch_queue_t)queue;

-(void)changeDesignMetadata:(NSString*)designId
                           :(NSString*)title
                           :(NSString*)description
            completionBlock:(HSCompletionBlock)completion
                      queue:(dispatch_queue_t)queue;

-(void)changeDesignStatus:(NSString*)designId
                   status:(DesignStatus)status
          completionBlock:(HSCompletionBlock)completion
                    queue:(dispatch_queue_t)queue;

-(void)updateDesignMetadataLocally:(NSString*)roomType
                   withDescription:(NSString*)desc
                     publishStatus:(DesignStatus)pstatus
                          withJson:(NSString*)json
                          andTitle:(NSString*)title
                         forDesign:(NSString*)designId;

- (void)getDesignLikes:(NSString*)assetId
                offset:(NSInteger)offset
        withCompletion:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue;

- (BOOL)likeDesign:(DesignBaseClass*)item :(BOOL) bIsLiked :(UIViewController*) senderView  :(BOOL) usePushDelegate withCompletionBlock:(ROCompletionBlock)completion;

-(MyDesignDO*)findDesignByID:(NSString*)designID;
-(void)fillWithDesigns:(NSMutableArray*)designs;
-(NSInteger)getNumberOfOfflineDesign;
-(void)performAutoSavingAsync;
-(void)performAutosaveOperation;
-(MyDesignDO *)generateDesignDOFromSavedDesign:(SavedDesign *)design;
-(SavedDesign*)generateDesignDOFromMyDesignDO:(NSString*)uniqueId;
-(void)disregardCurrentAutoSaveObject;
-(void)sendSavedDesignOnSilentMode;
-(BOOL)isThereDesignCreatedDueToCrash;
-(void)startAutoSave;
-(void)stopAutoSaveTimer;
-(void)resumeAutoSaveTimer;
-(void)printMapFile;
-(void)deleteMapFile;
-(void)deleteAllFiles;
-(void)getMetadataForDesignModels;
-(SavedDesign*)workingDesign;

@end

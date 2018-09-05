//
//  DesignsManager.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 10/29/14.
//
//

#import "DesignsManager.h"
#import "SaveDesignRequestObject.h"
#import "DesignRO.h"
#import "SaveDesignResponse.h"
#import "NotificationNames.h"
#import "NSString+Contains.h"
#import "ModelsHandler.h"

//#import "HSFlurry.h"

#define NULL_OR_EMPTY_ERROR_CODE    -2000
#define DEFULT_TIME_SECOND             15
#define SERVER_RESPOND_NO_ERROR        -1
#define RETRY_DELAY                   5.0
#define SYNC_AFTER_SECOND              10
#define WORKING_DESIGN              @"WD"
#define OFFLINE_DESIGN              @"OD"
#define REMOVE_DESIGN               @"RD"

#define MAP_FILE @"/DesignsFolder/design_mapped_ids.map"

@interface DesignsManager ()
{
    NSMutableDictionary * tempLikeDict;
}

@end

@implementation DesignsManager

@synthesize workingDesign = _workingDesign;

static DesignsManager *sharedInstance = nil;

+ (DesignsManager *)sharedInstance {
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[DesignsManager alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.designManagerQueue = dispatch_queue_create("com.autodesk.app.design.queue", DISPATCH_QUEUE_CONCURRENT);
        
        self.designsArray = [NSMutableArray arrayWithCapacity:0];
        
        self.isSyncWorking = NO;

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/DesignsFolder"];
        NSError *error = nil;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        // Check for internet connection
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusChanged)
                                                     name:@"NetworkStatusChanged"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userStatusChanged)
                                                     name:@"UserStatusChanged"
                                                   object:nil];
        
         dispatch_async(dispatch_get_main_queue(), ^{
             [self performSelector:@selector(startSync) withObject:nil afterDelay:SYNC_AFTER_SECOND];
         });
    }

    return self;
}

- (MyDesignDO *)generateDesignDOFromSavedDesign:(SavedDesign *)design
{
    MyDesignDO *mdesign = [MyDesignDO new];
    
    mdesign.content = [design jsonString];
    
    if ([mdesign.content rangeOfString:@"matrix"].location == NSNotFound)
    {
        NSLog(@"Bad formed loaded design");
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd HH:mm"
                                                                 options:0
                                                                  locale:[NSLocale currentLocale]]];
    mdesign.type = e3DItem;
    mdesign.isFullyLoaded = YES;
    mdesign._id = design.designID;
    mdesign.roomType = [NSNumber numberWithInt:[design.designRoomType intValue]];
    mdesign._description = design.designDescription;
    
    mdesign.title = [NSString stringWithFormat:@"%@%@", [dateFormatter stringFromDate: design.autosaveDate],
                     (design.name)?[NSString stringWithFormat:@"-%@",design.name]:@""];
    
    [mdesign setupAutoSaveRef:design.autoSaveUniqueID];
    return mdesign;
}

- (SavedDesign*)generateDesignDOFromMyDesignDO:(NSString*)uniqueId{
    return [self loadDesignFromDiskForId:uniqueId];
}

#pragma mark - AutoSave Logic
/*
 * Override the getter of working design, incase we hold previos working design
 * we need to remove it first than save the new one.
 */
-(void)setWorkingDesign:(SavedDesign *)workingDesign{
    
    // case we start application from crashed, popup appear and user choose not to redesign
    // now he start new design so we need to clean the pervious design from disk and remove the current working
    // design
    if (self.workingDesign) {
        [self disregardCurrentAutoSaveObject];
    }
    
    _workingDesign = workingDesign;
}

-(SavedDesign*)workingDesign{
    return _workingDesign;
}

/*
 * By calling this method we start the autosave logic
 * define new unique id to the our working design
 */
- (void)startAutoSave
{
    if ([ConfigManager isDesginManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"START AUTOSAVE LOGIC");
        HSMDebugLog(@"================================================================================================");
    }
    
    self.workingDesign.autoSaveUniqueID = [[ServerUtils sharedInstance] generateGuid];
    
    [self resumeAutoSaveTimer];
}

/*
 * By calling this method you can stop autosave cycle, by invalidate the cycle timer
 */
- (void)stopAutoSaveTimer
{
    if ([ConfigManager isDesginManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"STOP AUTOSAVE LOGIC");
        HSMDebugLog(@"================================================================================================");
    }
    
    [self.autosaveTimer invalidate];
    self.autosaveTimer = nil;
}

/*
 *  when given valid working design, run autosave operation on background thread
 */
- (void)performAutoSavingAsync
{
    if (self.workingDesign) {
        dispatch_async(self.designManagerQueue, ^{
            [self performAutosaveOperation];
        });
    }
}

/*
 * Save the current working design to disk
 */
- (void)performAutosaveOperation
{
    @synchronized(self)
    {
        if ([ConfigManager isDesginManagerLogActive]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"PERFORM AUTOSAVE");
            HSMDebugLog(@"NUMBER OF MODELS :%lu",(unsigned long)self.workingDesign.models.count);
            HSMDebugLog(@"WORKING DESIGN UNIQUE ID :%@",self.workingDesign.autoSaveUniqueID);
            HSMDebugLog(@"MAPPING DESIGN UNIQUE ID ARRAY COUNT :%lu",(unsigned long)[self.designsMapIdsArray count]);
            HSMDebugLog(@"================================================================================================");
        }

        
        //get copy of current working design
        self.workingDesign.autosaveDate = [NSDate date];
        
        [self saveDesignToDisk:self.workingDesign
                        fileId:self.workingDesign.autoSaveUniqueID
                          type:WORKING_DESIGN];
    }
    
}

/*
 *  init valid timer and call performAutoSavingAsync operation every autoSaveInterval
 */
- (void)resumeAutoSaveTimer
{
    if ([ConfigManager isDesginManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"RESUME AUTOSAVE");
        HSMDebugLog(@"================================================================================================");
    }
    
    if (![self.autosaveTimer isValid])
    {
        if (self.autoSaveInterval <= 0) {
            self.autoSaveInterval = DEFULT_TIME_SECOND;
        }
        
        self.autosaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval
                                                              target:self
                                                            selector:@selector(performAutoSavingAsync)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

/*
 * Save the current working design to disk and update design map
 */
- (void)saveDesignToDisk:(SavedDesign*)saveDesignObj fileId:(NSString*)fileId type:(NSString*)type
{
    @synchronized(self)
    {
        //store the current unique id
        [self updateMappedArray:fileId type:type];
        
        NSString * fileName = [self filePathForData:fileId];
        
        NSDate *start = [NSDate date];
        SavedDesign* copyObj = [saveDesignObj copy];
        BOOL res = [NSKeyedArchiver archiveRootObject:copyObj toFile:fileName];
        NSDate *end = [NSDate date];
        
        if ([ConfigManager isDesginManagerLogActive]) {
            if (res) {
                double ellapsedSeconds = [end timeIntervalSinceDate:start];
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"SAVE SUCCSESS DESIGN, UNIQUE ID :%@  TIME: %f" ,fileId  ,ellapsedSeconds)
                HSMDebugLog(@"================================================================================================");
            }else{
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"SAVE FAILED DESIGN UNIQUE ID :%@" ,fileId);
                HSMDebugLog(@"================================================================================================");
            }
        }
    }
}

/*
 * Remove working design from disk and update design map
 */
- (void)removeDesignFromDisk:(NSString*)fileId {//type:(NSString*)type{
    
    NSString * fileName = [self filePathForData:fileId];
    NSDate * start = [NSDate date];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:fileName];
    NSError * error;
    
    if(exists == YES){
        [fm removeItemAtPath:fileName error:&error];
    }
    
    NSDate * end = [NSDate date];
    double ellapsedSeconds = [end timeIntervalSinceDate:start];
    
    if ([ConfigManager isDesginManagerLogActive]) {
        if (exists) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"SUCCSESS TO REMOVE DESIGN FROM DISK UNIQUE ID :%@" ,fileId);
            HSMDebugLog(@"================================================================================================");
        }else{
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"FAILED TO REMOVE DESIGN FROM DISK UNIQUE ID :%@" ,fileId);
            HSMDebugLog(@"================================================================================================");
        }
        
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"TOTAL TIME REMOVE: %f", ellapsedSeconds);
        HSMDebugLog(@"================================================================================================");
    }
}

/*
 * Load working design from disk
 */
- (SavedDesign*)loadDesignFromDiskForId:(NSString*)uniqueId{
    __block SavedDesign *savedDesign = nil;
    
    dispatch_sync(self.designManagerQueue, ^{
        
        if (uniqueId) {
            NSString * fileName = [self filePathForData: uniqueId];
            
            NSDate * start = [NSDate date];
            savedDesign = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
            
            NSDate * end = [NSDate date];
            double ellapsedSeconds = [end timeIntervalSinceDate:start];
            
            if ([ConfigManager isDesginManagerLogActive]) {
                if (savedDesign) {
                    HSMDebugLog(@"================================================================================================");
                    HSMDebugLog(@"SUCCSESS TO LOAD DESIGN UNIQUE ID :%@ TOTAL TIME: %f" ,uniqueId, ellapsedSeconds);
                    HSMDebugLog(@"================================================================================================");
                }else{
                    HSMDebugLog(@"================================================================================================");
                    HSMDebugLog(@"FAILED TO LOAD DESIGN UNIQUE ID :%@ TOTAL TIME: %f" ,uniqueId , ellapsedSeconds);
                    HSMDebugLog(@"================================================================================================");
                }
            }
        }
    });
    
    return savedDesign;
}

/*
 * Load working design from disk
 */
- (void)loadWorkingDesignFromDisk{
    dispatch_sync(self.designManagerQueue, ^{
        
        NSString * workingDesignUniqueId = [self loadDesignUniqeIdByType:WORKING_DESIGN];
        if (workingDesignUniqueId) {
            NSString * fileName = [self filePathForData: workingDesignUniqueId];
            
            NSDate * start = [NSDate date];
            SavedDesign *savedDesign = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
            
            if (savedDesign) {
                self.workingDesign.UniqueID = workingDesignUniqueId;
                self.workingDesign = savedDesign;
            }
            else
            {
                self.workingDesign = nil;
            }
            
            NSDate * end = [NSDate date];
            double ellapsedSeconds = [end timeIntervalSinceDate:start];
            
                if ([ConfigManager isDesginManagerLogActive]) {
                    if (savedDesign) {
                        HSMDebugLog(@"================================================================================================");
                        HSMDebugLog(@"SUCCSESS TO LOAD WORKING DESIGN FROM DISK UNIQUE ID :%@ TOTAL TIME REMOVE: %f" ,self.workingDesign.autoSaveUniqueID, ellapsedSeconds);
                        HSMDebugLog(@"================================================================================================");
                    }else{
                        HSMDebugLog(@"================================================================================================");
                        HSMDebugLog(@"FAILED TO LOAD WORKING DESIGN FROM DISK UNIQUE ID :%@ TOTAL TIME REMOVE: %f" ,self.workingDesign.autoSaveUniqueID, ellapsedSeconds);
                        HSMDebugLog(@"================================================================================================");
                    }
                }
        }else{
            if ([ConfigManager isDesginManagerLogActive]) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"THERE IS NO WORKING DESIGN TO LOAD");
                HSMDebugLog(@"================================================================================================");
            }
        }
    });
}

/*
 * disregard the current working design from memory and remove it from disk and
 * from the array that holds all design obj
 */
- (void)disregardCurrentAutoSaveObject
{
    [self stopAutoSaveTimer];
    
    //remove object from disk
    NSString * workingDesignUniqueId = [self loadDesignUniqeIdByType:WORKING_DESIGN];
    if (workingDesignUniqueId) {
        //remove object from disk
        [self removeDesignFromDisk:workingDesignUniqueId];
        
        //update map array
        [self updateMappedArray:workingDesignUniqueId type:REMOVE_DESIGN];
    }else{
        if ([ConfigManager isDesginManagerLogActive]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"NO WORRKING DESIGN APPEAR IN MAP");
            HSMDebugLog(@"================================================================================================");
        }
    }
    
    
    //remove from design array if exits
    for (MyDesignDO * design in self.designsArray) {
        if (design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
            //that mean that we have autoSaved object in the last place on our array.
            //and we need to remove it
                [self.designsArray removeObject:design];
                //remove from memory
                self.workingDesign = nil;
            
                if ([ConfigManager isDesginManagerLogActive]) {
                    HSMDebugLog(@"================================================================================================");
                    HSMDebugLog(@"DISREGARD AUTOSAVE");
                    HSMDebugLog(@"================================================================================================");
                }
            break;
        }
    }
    
    [sharedInstance printMapFile];
}

#pragma mark - MAP ARRAY Function
/*
 * update the mapped array
 * 1. no working design -> recived wd -> add wd
 * 2. we got working design -> recived wd -> remove wd -> add working wd
 * 3. we got working design -> recived od -> remove wd -> add working od
 * 3. we got working design -> recived rd -> remove wd 
 */
-(void)updateMappedArray:(NSString*)uniqueId type:(NSString*)type{
    //create array of dict that define which obj it mapped
    if (!self.designsMapIdsArray) {
        self.designsMapIdsArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    if (![self checkIfMappingArrayContainWorkingDesign]) {
        //1. no working design -> recived wd -> add wd
        
        //case of no wd
        if ([type isEqualToString:WORKING_DESIGN]) {
            [dict setValue:WORKING_DESIGN forKey:@"type"];
            [dict setValue:uniqueId forKey:@"unique-id"];
            [self addDictToMappedArray:dict];
        }
    }else{
        if ([type isEqualToString:WORKING_DESIGN]) {
            // 2. we got wd -> recived wd -> remove wd -> add working new wd
            
            [self removeDictFromMappedArrayById:uniqueId type:WORKING_DESIGN];
            
            //case of working design
            if ([type isEqualToString:WORKING_DESIGN]) {
                [dict setValue:WORKING_DESIGN forKey:@"type"];
                [dict setValue:uniqueId forKey:@"unique-id"];
                [self addDictToMappedArray:dict];
            }
        }else if([type isEqualToString:REMOVE_DESIGN]){
             [self removeDictFromMappedArrayById:uniqueId type:WORKING_DESIGN];
            
        }else{
            //3. we go wd -> recived od -> remove wd -> add working od
            
            [self removeDictFromMappedArrayById:uniqueId type:OFFLINE_DESIGN];
            
            //case of offline design
            if ([type isEqualToString:OFFLINE_DESIGN]) {
                [dict setValue:OFFLINE_DESIGN forKey:@"type"];
                [dict setValue:uniqueId forKey:@"unique-id"];
                [self addDictToMappedArray:dict];
            }
        }
    }
    
    if ([ConfigManager isDesginManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"MAPPING DESIGN UNIQUE ID ARRAY COUNT :%lu",(unsigned long)[self.designsMapIdsArray count]);
        HSMDebugLog(@"\nDESIGN PRINT MAP \n%@", self.designsMapIdsArray ? self.designsMapIdsArray : @"");
        HSMDebugLog(@"================================================================================================");
    }
}

/*
 * By calling this method, you can remove specific item from the mapping array by id
 * type define if the item you want to remove is working design or offline design
 */
-(void)removeDictFromMappedArrayById:(NSString*)uniqueId type:(NSString*)type{

    @synchronized(self)
    {
        if ([type isEqualToString:WORKING_DESIGN]) {
            //case that we got new wd, need to remove perv wd
            
            // 1. remove old wd id from array
            for (NSDictionary * dict in self.designsMapIdsArray ) {
                if ([[dict objectForKey:@"type"] isEqualToString:WORKING_DESIGN]) {
                    [self.designsMapIdsArray removeObject:dict];
                    break;
                }
            }
            
        }else{
            
            //case that we got new od, if ids are equal need to remove old wd
            for (NSDictionary * dict in self.designsMapIdsArray ) {
                if ([[dict objectForKey:@"type"] isEqualToString:WORKING_DESIGN]) {
                    if ([[dict objectForKey:@"unique-id"] isEqualToString:uniqueId]) {
                        [self.designsMapIdsArray removeObject:dict];
                        break;
                    }
                }
            }
            
            // case we need just to remove the specific unique id
            for (NSDictionary * dict in self.designsMapIdsArray ) {
                if ([[dict objectForKey:@"unique-id"] isEqualToString:uniqueId]) {
                    [self.designsMapIdsArray removeObject:dict];
                    break;
                }
            }
        }
        
        NSString * fileName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:MAP_FILE];
        [NSKeyedArchiver archiveRootObject:self.designsMapIdsArray toFile:fileName];
    }
}

/*
 * By calling this method, you can add specific item to the mapping array
 */
-(void)addDictToMappedArray:(NSDictionary*)dict{
    
    @synchronized(self)
    {
        [self.designsMapIdsArray addObject:dict];
        
        NSString * fileName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:MAP_FILE];
        [NSKeyedArchiver archiveRootObject:self.designsMapIdsArray toFile:fileName];
    }
}

/*
 * By calling this method, you can check if mapping array containing working design
 */
-(BOOL)checkIfMappingArrayContainWorkingDesign {
    @synchronized(self)
    {
        for (NSDictionary * dict  in self.designsMapIdsArray) {
            if ([[dict objectForKey:@"type"] isEqualToString:WORKING_DESIGN]) {
                return YES;
            }
        }
        return NO;
    }
}

/*
 * By calling this method, load design by givving unique id
 */
-(NSString*)loadDesignUniqeIdByType:(NSString*)type {
    
    @synchronized(self)
    {
        NSString * uniqeId = nil;
        NSString * fileName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:MAP_FILE];
        self.designsMapIdsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        
        if ([ConfigManager isDesginManagerLogActive]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"MAPPING DESIGN UNIQUE ID ARRAY COUNT :%lu",(unsigned long)[self.designsMapIdsArray count]);
            HSMDebugLog(@"\nDESIGN PRINT MAP \n%@", self.designsMapIdsArray ? self.designsMapIdsArray : @"");
            HSMDebugLog(@"================================================================================================");
        }
        
        if (self.designsMapIdsArray) {
            for (NSDictionary * dict in self.designsMapIdsArray) {
                if ([[dict objectForKey:@"type"] isEqualToString:WORKING_DESIGN]) {
                    uniqeId = [dict objectForKey:@"unique-id"];
                    break;
                }
            }
        }
        
        return uniqeId;
    }
}

/*
 * Load working design unique id
 * if exist load the saved design
 * if success return yes else return no
 */
- (BOOL)isThereDesignCreatedDueToCrash {
    
    [self loadWorkingDesignFromDisk];
    
    if (self.workingDesign) {
        return YES;
    }
    
    return NO;
}

/*
 * Create file path for given file name
 */
- (NSString *)filePathForData:(NSString *)data
{
    NSString *filename = [NSString stringWithFormat:@"/DesignsFolder/%@.so", data];
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}

/*
 * Create SaveDesignRequestObject 
 * parameters:
 * savedDesign: saved Design object itself created by the ui class
 * isPublic: describe if the saved design obj is puclic or not
 * shouldOverideDesign: let the server know if this is new desin or old design that need to be overwrite
 */
-(SaveDesignRequestObject*)generateSaveDesignRequestObject:(SavedDesign*)savedDesign isPublic:(BOOL)isPublic shouldOverideDesign:(BOOL)shouldOverideDesign{
    SaveDesignRequestObject * saveRequest = [[SaveDesignRequestObject alloc] initWithDesignObject:savedDesign];
    saveRequest.isPublished = isPublic;
    saveRequest.isNewDesign = shouldOverideDesign;
    saveRequest.json = [savedDesign jsonString];
    
    return saveRequest;
}

/*
 * Validation of the SaveDesignRequestObject before sending to server
 */
-(BOOL)validateSaveDesignObject:(SaveDesignRequestObject*)designObject
{
    if (!designObject || [NSString isNullOrEmpty:designObject.json] || [NSString isNullOrEmpty:designObject.name]) {
        return NO;
    }
    
    return YES;
}

/*
 * Send Analitics
 */
-(void)sendAnalitics:(BOOL)isPublic shouldOverideDesign:(BOOL)shouldOverideDesign{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        if (shouldOverideDesign) {
            NSArray * objs=[NSArray arrayWithObjects:(isPublic==true)?@"public":@"private", nil];
            NSArray * keys=[NSArray arrayWithObjects: @"design_publish",nil];
//            [HSFlurry logEvent:FLURRY_DESIGN_SAVED withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }else{
            NSArray * objs=[NSArray arrayWithObjects:(isPublic==true)?@"public":@"private", nil];
            NSArray * keys=[NSArray arrayWithObjects: @"design_publish",nil];
//            [HSFlurry logEvent:FLURRY_DESIGN_RESAVED withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }
    }
#endif
}

#pragma mark - Server Actions on Design
/*
 * By calling this method, if network avilable this function send the working design to server 
 * if network is offline this function save the saved object to dosk
 */
- (void)saveDesignOnServer:(BOOL)overideRequested
                  isPublic:(BOOL)isPublic
                 withTitle:(NSString*)dTitle
            andDescription:(NSString*)desc
               andRoomType:(NSString*)roomType
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue
{
    //stop the autsave time
    [self stopAutoSaveTimer];
    
    __block SavedDesign *savedDesign = nil;
    __block BOOL shouldOverideDesign = NO;
    
    if ([ConfigManager isAnyNetworkAvailable]) {
        
        savedDesign = self.workingDesign;
        savedDesign.designRoomType = roomType;
        savedDesign.designDescription = desc;
        savedDesign.name = dTitle;
        savedDesign.isPublic = isPublic;
        
        if (savedDesign.saveReminder) {
            [[savedDesign saveReminder] resetCounters];
        }
        
        shouldOverideDesign = (savedDesign.designID == nil);
        
        //force save as new design if design is from my designs and was published
        if (overideRequested == NO || savedDesign.mustSaveAsNewDesign) {
            shouldOverideDesign = YES;
        }
        
        __block SaveDesignRequestObject * sdro = [self generateSaveDesignRequestObject:savedDesign
                                                                              isPublic:isPublic
                                                                   shouldOverideDesign:shouldOverideDesign];
        
        if (![self validateSaveDesignObject:sdro]) {
            if(completion) {
                NSString * errorCode = [NSString stringWithFormat:@"%d", NULL_OR_EMPTY_ERROR_CODE];
                completion(nil, errorCode);
            }
            return;
        }

        ROCompletionBlock complitionBlock = ^(id serverResponse) {
            
            SaveDesignResponse * saveResponse = (SaveDesignResponse*)serverResponse;
            
            if (saveResponse.errorCode == SERVER_RESPOND_NO_ERROR) {
                
                if (shouldOverideDesign) {
                    savedDesign.designID = saveResponse.designID;
                    savedDesign.publicDesignID = savedDesign.designID;
                    savedDesign.mustSaveAsNewDesign = NO;
                }else {
                    [self updateDesignMetadataLocally:roomType
                                      withDescription:savedDesign.designDescription
                                        publishStatus:isPublic
                                             withJson:sdro.json
                                             andTitle:dTitle
                                          andFinalUrl:saveResponse.urlFinal
                                           andBackUrl:saveResponse.urlBack
                                           andInitUrl:saveResponse.urlInitial
                                           andMaskUrl:saveResponse.urlMask
                                            forDesign:savedDesign.designID];
                }
                
                [self.workingDesign updateCachedImage:saveResponse];
                [[[GalleryServerUtils sharedInstance] cloudCache] generateRequestTimestampForDesignID:savedDesign.designID];
                [[[GalleryServerUtils sharedInstance] cloudCache] saveCustomObject];
                
                //will force My designs reload
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:kNotificationMyHomeDesignsNeedRefresh object:nil userInfo:nil]];
                
                if (completion)
                    completion(serverResponse,nil);
            }else{
                if (completion) {
                    NSString * errorCode = [NSString stringWithFormat:@"%ld", (long)saveResponse.errorCode];
                    completion(nil, errorCode);
                }
            }
            
            // remove autosave from working design
            [self disregardCurrentAutoSaveObject];
        };
        
        ROFailureBlock failure = ^(NSError *error) {
            NSString * erMessage =[ error localizedDescription];
            NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            if(completion)
                completion(nil, errguid);
            
            // remove autosave from working design
            [self disregardCurrentAutoSaveObject];
        };
        
        //analytics
        [self sendAnalitics:isPublic shouldOverideDesign:shouldOverideDesign];
        /////////////////////////////////////////////////////////////////////
        //
        //          ONLINE
        //
        /////////////////////////////////////////////////////////////////////
        
        /////////////////////////////////////////////////////////////////////
        // API CALL SEND SAVED DESIGN TO SERVER
        /////////////////////////////////////////////////////////////////////
        
        [[DesignRO new] saveDesign:sdro
                   completionBlock:complitionBlock
                      failureBlock:failure
                             queue:queue];
    }else{
        //offline
        
        //we genrate new uniqeid if user dicided to save the same design again
        if (!overideRequested)
        {
            self.workingDesign.autoSaveUniqueID = [[ServerUtils sharedInstance] generateGuid];
            [self updateMappedArray: self.workingDesign.autoSaveUniqueID type:WORKING_DESIGN];
        }
        
        savedDesign = self.workingDesign;
        savedDesign.designRoomType = roomType;
        savedDesign.designDescription = desc;
        savedDesign.name = dTitle;
        savedDesign.isPublic = isPublic;
        
        /////////////////////////////////////////////////////////////////////
        //
        //          OFFLINE
        //
        /////////////////////////////////////////////////////////////////////
        [self saveDesignToDisk:self.workingDesign
                        fileId:self.workingDesign.autoSaveUniqueID
                          type:OFFLINE_DESIGN];
        
        //we need to mimik the response of the server
        //we store the autoSaveUniqueID inside the designID field
        self.workingDesign.designID = self.workingDesign.autoSaveUniqueID;
        self.workingDesign.mustSaveAsNewDesign = NO;
        
        //will force My designs reload
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
         [NSNotification notificationWithName:kNotificationMyHomeDesignsNeedRefresh object:nil userInfo:nil]];
        
        if (completion)
            completion(nil,nil);
    }
}

/*
 * By calling this method, the application send all offline object to server in the background
 */
-(void)sendSavedDesignOnSilentMode{
    
    if ([ConfigManager isAnyNetworkAvailable]     &&
        [[UserManager sharedInstance] isLoggedIn] &&
        !self.isSyncWorking) {
        
        self.isSyncWorking = YES;
        NSString * offlineDesignUniqueId = [self getFirstOfflineDesignIdAvialeable];
        if (offlineDesignUniqueId) {
            SavedDesign * offlineDesign = [self loadDesignFromDiskForId:offlineDesignUniqueId];
            
            [offlineDesign loadDataIntoUIImagesForAutosaves];
            
            if (!offlineDesign) {
                
                if ([ConfigManager isDesginManagerLogActive]) {
                    HSMDebugLog(@"================================================================================================");
                    HSMDebugLog(@"CANT LOAD OFFLINE DESIGN FOR UNIQUE ID: %@", offlineDesignUniqueId);
                    HSMDebugLog(@"================================================================================================");
                }
                
                //updade the map file
                [self removeDictFromMappedArrayById:offlineDesignUniqueId type:OFFLINE_DESIGN];
                
                //try again for next id in map file
                [self performSelector:@selector(sendSavedDesignOnSilentMode)
                           withObject:nil
                           afterDelay:RETRY_DELAY];
                return;
            }
            
            __block SaveDesignRequestObject * sdro = [self generateSaveDesignRequestObject:offlineDesign
                                                                                  isPublic:offlineDesign.isPublic
                                                                       shouldOverideDesign:YES];
            
            if (![self validateSaveDesignObject:sdro]) {
                if ([ConfigManager isDesginManagerLogActive]) {
                    HSMDebugLog(@"================================================================================================");
                    HSMDebugLog(@"ERROR REQUEST: %@", [NSString stringWithFormat:@"%d", NULL_OR_EMPTY_ERROR_CODE]);
                    HSMDebugLog(@"================================================================================================");
                }
            }
            
            ROCompletionBlock complitionBlock = ^(id serverResponse) {
                
                SaveDesignResponse * saveResponse = (SaveDesignResponse*)serverResponse;
                if (saveResponse.errorCode == SERVER_RESPOND_NO_ERROR) {
                    if ([ConfigManager isDesginManagerLogActive]) {
                        HSMDebugLog(@"================================================================================================");
                        HSMDebugLog(@"SYNC DESIGNID: %@", saveResponse.designID);
                        HSMDebugLog(@"================================================================================================");
                    }
                }
                
                self.isSyncWorking = NO;
                
                //remove from disk
                [self removeDesignFromDisk:offlineDesignUniqueId];
                
                //remove form mapping array
                [self removeDictFromMappedArrayById:offlineDesignUniqueId type:OFFLINE_DESIGN];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(sendSavedDesignOnSilentMode)
                               withObject:nil
                               afterDelay:RETRY_DELAY];
                });
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DesignManagerSyncCycleComplete" object:nil];
            };
            
            ROFailureBlock failure = ^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(sendSavedDesignOnSilentMode)
                               withObject:nil
                               afterDelay:RETRY_DELAY];
                });
            };
            
            /////////////////////////////////////////////////////////////////////
            // API CALL SEND SAVED DESIGN TO SERVER
            /////////////////////////////////////////////////////////////////////
            [[DesignRO new] saveDesign:sdro
                       completionBlock:complitionBlock
                          failureBlock:failure
                                 queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        }else{
            self.isSyncWorking = NO;
            if ([ConfigManager isDesginManagerLogActive]) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"NOTHING TO SYNC");
                HSMDebugLog(@"================================================================================================");
            }
        }
    }else{
        if ([ConfigManager isDesginManagerLogActive]) {
            
            if (![ConfigManager isAnyNetworkAvailable]) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"CANT SYNC - NO NETWORK");
                HSMDebugLog(@"================================================================================================");
            }
            
            if (![[UserManager sharedInstance] isLoggedIn]) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"CANT SYNC - USER NOT LOGIN");
                HSMDebugLog(@"================================================================================================");
            }
            
            if (self.isSyncWorking) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"CANT SYNC - SYNC PROSSES IS ALREADY WORKING");
                HSMDebugLog(@"================================================================================================");
            }
        }
    }
}

/*
 * By calling this method, the return value is the unique id of the first offline design
 */
-(NSString*)getFirstOfflineDesignIdAvialeable{
    NSString * designUniqueId = nil;
    for (NSDictionary * dict in self.designsMapIdsArray) {
        if ([[dict objectForKey:@"type"] isEqualToString:OFFLINE_DESIGN]) {
           designUniqueId = [dict objectForKey:@"unique-id"];
            break;
        }
    }
    return designUniqueId;
}

/*
 * By calling this method, the return value is the total of offline design object in the mapping array
 */
-(NSInteger)getNumberOfOfflineDesign{
    NSInteger designCount = 0;
    for (NSDictionary * dict in self.designsMapIdsArray) {
        if ([[dict objectForKey:@"type"] isEqualToString:OFFLINE_DESIGN]) {
            designCount++;
        }
    }
    return designCount;
}

/*
 * Delete Design by calling the change design status api call with param "delete"
 */
-(void)deleteDesign:(NSString*)designId
    completionBlock:(HSCompletionBlock)completion
              queue:(dispatch_queue_t)queue{
    
    if ([ConfigManager isAnyNetworkAvailable:YES] == NO) {
        
        NSString * erMessage = @"";
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_NO_NETWORK] withPrevGuid:nil];
        
        if(completion)
            completion(nil,errguid);
        
        return ;
    }
    
    [self changeDesignStatus:designId status:STATUS_DELETED completionBlock:^(id serverResponse, id error) {
        
        BaseResponse * response = (BaseResponse*)serverResponse;
        
        if (response && response.errorCode == SERVER_RESPOND_NO_ERROR) {
            
            MyDesignDO * myDesignDO = [self findDesignByID:designId];
            
            if (myDesignDO) {
                [self.designsArray removeObject:myDesignDO];
            }
            
            if(completion){
                completion(serverResponse,nil);
            }
        }else{
            if(completion){
                completion(nil,response.hsLocalErrorGuid);
            }
        }
    } queue:queue];
}

/*
 * By calling this method, you can update design status on server
 */
-(void)changeDesignStatus:(NSString*) designId
                   status:(DesignStatus) status
          completionBlock:(HSCompletionBlock)completion
                    queue:(dispatch_queue_t)queue
{
    if ([ConfigManager isAnyNetworkAvailable:YES] == NO) {
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:@"" withErrorCode:HSERR_LOCAL_ERROR_NO_NETWORK] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
        
        return ;
    }
    
    [[DesignRO new] designChangeStatus:designId newStatus:status completionBlock:^(id serverResponse) {
        
        DesignDuplicateResponse * response=(DesignDuplicateResponse*)serverResponse;
        
        if (response && response.errorCode == SERVER_RESPOND_NO_ERROR) {
            
            MyDesignDO * d = [self findDesignByID:designId];
            d.publishStatus = status;
            
            if(completion) completion(serverResponse,nil);
        }else{
            if(completion){
                completion(nil,response.hsLocalErrorGuid);
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMyDesignDOStatusChanged object:nil userInfo:@{kNotificationKeyItemId: designId}];
        
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion){
            completion(nil,errguid);
        }
        
    } queue:queue];
}

/*
 * By calling this method, you can update design meta data on local MyDesignDO obj
 */
-(void)updateDesignMetadataLocally:(NSString*)roomType
                   withDescription:(NSString*)desc
                     publishStatus:(DesignStatus)pstatus
                          withJson:(NSString*)json
                          andTitle:(NSString*)title
                       andFinalUrl:(NSString*)urlFinal
                        andBackUrl:(NSString*)urlBack
                        andInitUrl:(NSString*)urlInitial
                        andMaskUrl:(NSString*)urlMask
                         forDesign:(NSString*)designId{
    
    MyDesignDO * design = [sharedInstance findDesignByID:designId];
    
    if (design) {
        design.roomType = [NSNumber numberWithInt:[roomType intValue]];
        design._description = desc;
        design.publishStatus = pstatus;
        design.title = title;
        
        design.originalImageURL = urlInitial;
        design.editedImageURL = urlFinal;
        design.maskImageURL = urlMask;
        design.backgroundImageURL = urlBack;
        
        if ( [json parseJsonStringIntoMutableDictionary]!=nil) {
            design.content = json;
        }
    }
}

/*
 * By calling this method, you can retrive a specific MyDesignDO obj by design id
 */
-(MyDesignDO*)findDesignByID:(NSString*)designID{
    
    for (int i = 0; i < [self.designsArray count];i++) {
        if ([[[self.designsArray objectAtIndex:i] _id] isEqualToString:designID]) {
            return [self.designsArray objectAtIndex:i];
        }
    }
    
    return nil;
}

/*
 * By calling this method, you can update design meta data on server
 */
-(void)changeDesignMetadata:(NSString*) designId :(NSString*) title :(NSString*) description
            completionBlock:(HSCompletionBlock)completion
                      queue:(dispatch_queue_t)queue;
{
    if ([ConfigManager isAnyNetworkAvailable:YES] == NO) {
        
        NSString * erMessage = @"";
        NSString * errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_NO_NETWORK] withPrevGuid:nil];
        
        if(completion){
            completion(nil,errguid);
        }
        
        return ;
    }
    
    [[DesignRO new] designChangeMetadata:designId newTitle:title newDescription:description completionBlock:^(id serverResponse) {
        
        DesignDuplicateResponse * response=(DesignDuplicateResponse*)serverResponse;
        
        if (response && response.errorCode == SERVER_RESPOND_NO_ERROR) {
            
            MyDesignDO * d=[self findDesignByID:designId];
            if (d!=nil) {
                d._description=description;
                d.title=title;
            }
            if(completion){
                completion(serverResponse,nil);
            }
        }else{
            if(completion){
                completion(nil,response.hsLocalErrorGuid);
            }
        }
    } failureBlock:^(NSError *error) {
        
    } queue:queue];
}

/*
 * By calling this method, you can duplicate design on sever
 */
-(void)duplicateDesign:(NSString*)_id
       completionBlock:(HSCompletionBlock)completion
                 queue:(dispatch_queue_t)queue{
    
    if ([ConfigManager isAnyNetworkAvailable:YES] == NO) {
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:@"" withErrorCode:HSERR_LOCAL_ERROR_NO_NETWORK] withPrevGuid:nil];
        
        if(completion){
            completion(nil, errguid);
        }
        
        return ;
    }
    
    [[DesignRO new] designDuplicate:_id completionBlock:^(id serverResponse) {
        
        DesignDuplicateResponse * response = (DesignDuplicateResponse*)serverResponse;
        
        if (response && response.errorCode == SERVER_RESPOND_NO_ERROR) {
            
            MyDesignDO * myDesignDO = [self findDesignByID:_id];
            if (myDesignDO) {
                MyDesignDO * dup = [myDesignDO duplicate];
                dup._id = response.designIDnew;
                [self.designsArray insertObject:dup atIndex:0];
            }
            
            if(completion){
                completion(serverResponse,nil);
            }
        }else{
            if(completion){
                completion(nil,response.hsLocalErrorGuid);
            }
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion){
            completion(nil,errguid);
        }
        
    } queue:queue];
}

/*
 * By calling this method, you can generate final array containing all design (MyDesignDO) objects that came from server, autoasaved design (appear only once in the array) and
 * the offline designs
 * params:
 * designs: array of MyDesignDO you get from server
 */
-(void)fillWithDesigns:(NSMutableArray*)designs{
    
    [self.designsArray removeAllObjects];
    [self.designsArray addObjectsFromArray:[designs copy]];
    [self.designsArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO], nil]];
    
    //update each design who came from server with his status
    for (MyDesignDO * myDesign in self.designsArray) {
        myDesign.eSaveDesignStatus = SAVED_DESIGN_STATUS_SAVED;
    }
    
    if (self.workingDesign)
    {
        //add auto save to the array
        [self.workingDesign loadDataIntoUIImagesForAutosaves];
        
        MyDesignDO * convertedAutoSave = [self generateDesignDOFromSavedDesign:self.workingDesign];
        
        if (convertedAutoSave)
        {
            convertedAutoSave.eSaveDesignStatus = SAVED_DESIGN_STATUS_AUTOSAVE;
            [self.designsArray insertObject:convertedAutoSave atIndex:0];
        }
    }
    
    if (self.designsMapIdsArray) {
        for (NSDictionary * dict in self.designsMapIdsArray) {
            if ([[dict objectForKey:@"type"] isEqualToString:OFFLINE_DESIGN]) {
                NSString * designUniqueId = [dict objectForKey:@"unique-id"];
                
                SavedDesign * savedDesign = [self loadDesignFromDiskForId:designUniqueId];
                
                if (savedDesign) {
                    [savedDesign loadDataIntoUIImagesForAutosaves];
                    MyDesignDO * convertedAutoSave = [self generateDesignDOFromSavedDesign:savedDesign];
                    convertedAutoSave.eSaveDesignStatus = SAVED_DESIGN_STATUS_WAITING_FOR_SYNC;
                    [self.designsArray insertObject:convertedAutoSave atIndex:0];
                }else{
                    if ([ConfigManager isDesginManagerLogActive]) {
                        HSMDebugLog(@"================================================================================================");
                        HSMDebugLog(@"FAILED TO ADD WAITTING DESIGN TO MY DESIGN TAB");
                        HSMDebugLog(@"================================================================================================");
                    }
                }
            }
        }
    }
}

-(void)startSync{
    if ([[ReachabilityManager sharedInstance] isConnentionAvailable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendSavedDesignOnSilentMode];
        });
    }else{
        // no network so sync is not working
        self.isSyncWorking = NO;
    }
}

#pragma mark - Notifiaction
-(void)networkStatusChanged{
    [self startSync];
}

-(void)userStatusChanged{
    [self startSync];
}

#pragma mark - Debug
-(void)deleteMapFile{
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:MAP_FILE];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([ConfigManager isDesginManagerLogActive]) {
        if ([fileManager removeItemAtPath:filePath error:NULL]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"SUCCSESS TO REMOVE MAP FILE");
            HSMDebugLog(@"================================================================================================");
        }
    }
    
    [self.designsMapIdsArray removeAllObjects];
}

-(void)deleteAllFiles{
    
    NSString * folderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/DesignsFolder/"];
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        
        if ([ConfigManager isDesginManagerLogActive]) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"SUCCSESS TO REMOVE FILE %@", file);
                HSMDebugLog(@"================================================================================================");
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
    }
    
    [self.designsMapIdsArray removeAllObjects];
}

-(void)printMapFile
{
    if ([ConfigManager isDesginManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"\nDESIGN PRINT MAP \n%@", self.designsMapIdsArray);
        HSMDebugLog(@"================================================================================================");
    }
}

-(void)getMetadataForDesignModels{
    
    if (!self.productInfoArray) {
        self.productInfoArray = [NSMutableArray array];
    }else{
        [self.productInfoArray removeAllObjects];
    }
    
    for (Entity *entity in self.workingDesign.models)
    {
        HSCompletionBlock postActionBlock = ^(id response, NSError *error)
        {
            ProductInfoDO *productInfoDO = (ProductInfoDO*)response;
            
            if (error || !response || !productInfoDO){
                NSLog(@"error retriving product info");
            }else{
                [self.productInfoArray addObject:productInfoDO];
                
                if ([self.productInfoArray count] == [self.workingDesign.models count]) {
                    NSLog(@"getMetadataForDesignModels - completed");
                }
            }
            
        }; // end of block
        
        [[ModelsHandler sharedInstance] getProductInfoForEntity:entity
                                                completionBlock:postActionBlock
                                                          queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
    }
    
}

- (void)getDesignLikes:(NSString*)assetId
                offset:(NSInteger)offset
        withCompletion:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue {
    if ([NSString isNullOrEmpty:assetId])
        return;

    [[DesignRO new] getAssetLikes:assetId
                         withType:e3DItem
                           offset:offset
                  completionBlock:completion
                     failureBlock:failure
                            queue:queue];
}

- (BOOL)likeDesign:(DesignBaseClass*)item :(BOOL)bIsLiked :(UIViewController*)senderView :(BOOL)usePushDelegate withCompletionBlock:(ROCompletionBlock)completion
{
    if (bIsLiked)
    {
#ifdef USE_FLURRY
        if (ANALYTICS_ENABLED)
        {
//            [HSFlurry logEvent: FLURRY_DESIGN_LIKE_CLICK];
        }
#endif
    }

    BOOL bRetVal = [[UserManager sharedInstance] isLoggedIn];

    if (!bRetVal)
        return NO;

    if (!tempLikeDict)
    {
        tempLikeDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }

    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:item._id];

    [[DesignRO new] designLike:item._id isLiked:bIsLiked completionBlock:^(id serverResponse) {

        BaseResponse * response=(BaseResponse*)serverResponse;

        if (response && response.errorCode==-1)
        {
            if (likeDO)
            {
                [likeDO updateUserLikeStatus:bIsLiked];
            }

            if ([item isArticle])
            {
                if (bIsLiked)
                {
                    //add to local articles
                    GalleryItemDO * gido = (GalleryItemDO *)item;
                    [[[AppCore sharedInstance] getHomeManager]addLikedArticle:gido];
                }
                else
                {
                    //remove from local articles
                    [[[AppCore sharedInstance] getHomeManager]removeLikedArticle:item._id];
                }
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAssetLikeStatusChanged object:nil userInfo:@{ kNotificationKeyItemId:item._id, @"isLiked":@(bIsLiked) }];

            if (bIsLiked) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate updateReviewEvent];
                });
            }
        }

        if (bIsLiked && [[HCFacebookManager sharedInstance]isFacebookSessionOpen] && FACEBOOK_LIKE_ENABLED && item._id)
        {
            [[HCFacebookManager sharedInstance] facebookLikeDesign:item._id  andType:[NSString stringWithFormat:@"%d",item.type] withCompletionBlock:^(id serverResponse, id error)
             {
             } queue:self.designManagerQueue];
        }


        if (completion)
        {
            completion(serverResponse);
        }

        tempLikeDict = nil;

    } failureBlock:^(NSError *error)
     {
         tempLikeDict = nil;
     } queue:self.designManagerQueue];

    return YES;
}

- (void) loginRequestEndedwithState:(BOOL) state
{ //TODO: Refactor Like for

    if (state==NO) {
        tempLikeDict=nil;
    }

    if (tempLikeDict)
    {

        DesignBaseClass * item=  [tempLikeDict objectForKey:@"item"];
        BOOL bIsLiked= [[tempLikeDict objectForKey:@"liked"] boolValue];
        if(state == YES)
        {
            NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
            LikeDesignDO*  likeDO = [likeDict  objectForKey:item._id];
            [[DesignRO new] designLike:item._id isLiked:bIsLiked completionBlock:^(id serverResponse) {

                if ([[HCFacebookManager sharedInstance]isFacebookSessionOpen] && FACEBOOK_LIKE_ENABLED && item._id) {

                    [[HCFacebookManager sharedInstance] facebookLikeDesign:item._id andType:[NSString stringWithFormat:@"%d",item.type] withCompletionBlock:^(id serverResponse, id error) {

                    } queue:self.designManagerQueue];
                }

                BaseResponse * response=(BaseResponse*)serverResponse;

                if (response && response.errorCode==-1) {

                    if(likeDO)[likeDO updateUserLikeStatus:bIsLiked];

                    if ([item isArticle]) {
                        if (bIsLiked) {
                            //add to local articles
                            GalleryItemDO * gido = (GalleryItemDO*)item;
                            [[[AppCore sharedInstance] getHomeManager]addLikedArticle:gido];
                        }else{
                            //remove from local articles
                            [[[AppCore sharedInstance] getHomeManager]removeLikedArticle:item._id];
                        }
                    }
                }

                tempLikeDict = nil;
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:@"likePressedLoginResponse" object:nil userInfo:@{ @"isSuccess" : [NSNumber numberWithBool:state], @"item": item}]];

            } failureBlock:^(NSError *error) {
                tempLikeDict = nil;
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:@"likePressedLoginResponse" object:nil userInfo:@{ @"isSuccess" : [NSNumber numberWithBool:state], @"item": item}]];

            } queue:self.designManagerQueue];
        }
    }
    HSMDebugLog(@"UIGalleryMAnager loginRequestEndedwithState");
}

@end

//
//  GalleryStreamManager.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import "GalleryStreamManager.h"
#import "GalleryItemDO.h"
#import "GalleryLayoutDO.h"
#import "GalleryServerUtils.h"
#import "GalleryFilterDO.h"
#import "NotificationAdditions.h"
#import "GalleryStreamBaseController.h"
#import "GalleryHomeViewController.h"
#import "DesignRO.h"
#import "GStreamRO.h"
#import "GetLayoutsDO.h"
#import "ControllersFactory.h"
#import "GetRoomTypesRO.h"
#import "RoomTypeDO.h"
#import "ProgressPopupViewController.h"

@interface GalleryStreamManager (){
    
    GalleryFilterDO* activeGalleryFilterDO;
    NSDate * _lastRefreshDate;
}

-(int)getLayoutFlowIndexForLayout:(int)layoutid;
-(GalleryLayoutDO*)getTemplateLayoutForID:(int)layid;

@property (nonatomic, strong) NSMutableDictionary * lookupTableDesigns;
@property (nonatomic, strong) NSDate *lastRefreshDate;
@property (nonatomic, strong) GalleryStreamBaseController *galleryStreamViewController;
@end

@implementation GalleryStreamManager

static GalleryStreamManager *sharedInstance = nil;

+ (GalleryStreamManager *)sharedInstance {

    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[GalleryStreamManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.templateLayouts = [NSMutableArray array];
        self.lookupTableDesigns = [NSMutableDictionary dictionaryWithCapacity:0];
        self.customItems = [NSMutableArray arrayWithCapacity:0];
        self.likeDesignDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        self._numOfDesiredItems = (int)[[ConfigManager sharedInstance] numberOfDesignPerGalleryPage];
        self._pageIndexDesiredItems = 0;
        self.noMoreDataCanReturn = NO;
        self.bRequestRefreshSent = NO;
        self.bIsLayoutRequestSent = NO;
        self.bIsLayoutRequestLoaded = NO;
        self.lastRefreshDate = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshData)
                                                     name:@"refreshDataStream" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearStreams)
                                                     name:@"invalidateAllContent" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshTimerEvent:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        NSTimeInterval refreshRate = [GalleryStreamManager getRefreshRateInSeconds];
        
        if(refreshRate > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self._refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshRate target:self
                                                                              selector:@selector(refreshTimerEvent:) userInfo:nil repeats:YES];
            });
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    return self;
}

-(void)logout
{
    [self clearPreviousUserLikesData];
    self.loadedUserLikes=NO;
    [self.customItems removeAllObjects];
}

-(void)refreshData
{
    if ([self.templateLayouts count]==0) {
        [self loadStreamLayoutsWithCompletionBlock:^(id serverResponse, id error) {
            
        } queue:dispatch_get_main_queue()];
    } else {
        [self refreshStreams];
        [self refreshBanner];
    }
}

-(BOOL)canLoadMoreDesignItems{
    GalleryFilterDO * gf= activeGalleryFilterDO;
    return  gf.canLoadMore == YES;
}


-(GalleryLayoutDO*)findFittingLayout:(int)itemsCount{
    
    for(int i=0;i<[self.templateLayouts count];i++)
    {
        GalleryLayoutDO * layout=[self.templateLayouts objectAtIndex:i];
        if ([[layout  rects] count]<=itemsCount) {
            return  layout;
        }
        
    }
    return  nil;
}

- (GalleryLayoutDO*)getTemplateLayoutForEmptyRoomsScreen {
    
    NSMutableDictionary *dict = (NSMutableDictionary*) @{@"data": @"{\"h\":33,\"rects\":{\"rect\":[{\"x\":0,\"y\":0,\"w\":33,\"h\":100,\"id\":1,\"l\":0,\"t\":0},{\"x\":33,\"y\":0,\"w\":34,\"h\":100,\"id\":2,\"l\":1,\"t\":0},{\"x\":67,\"y\":0,\"w\":33,\"h\":100,\"id\":3,\"l\":2,\"t\":0}]}}", @"id" : @1};
    return [[GalleryLayoutDO alloc]initWithDictionary:dict];
}

-(GalleryLayoutDO*)getTemplateLayoutForID:(int)layid{
    
    for (int i=0; i<[self.templateLayouts count]; i++) {
        
        GalleryLayoutDO * gal=[self.templateLayouts objectAtIndex:i];
        if ([gal _id]==layid) {
            return [self.templateLayouts objectAtIndex:i];
        }
    }
    return nil;
}

-(int)getLayoutFlowIndexForLayout:(int)layoutid{
    
    for (int i=0; i<[self.layoutsFlow count]; i++) {
        if ([[self.layoutsFlow objectAtIndex:i] intValue]==layoutid ) {
            if (i+1<[self.layoutsFlow count]) {
                return i+1;
            }else
                return 0;
        }
    }
    
    return -1;
}

-(GalleryItemDO*)getGalleryItemByItemID:(NSString*)itemid{

    GalleryFilterDO * gf= activeGalleryFilterDO;
    
    
    for (int i=0; i<[gf.loadedItems count]; i++) {
        GalleryItemDO * item=[gf.loadedItems objectAtIndex:i] ;
        if ([[item _id] isEqualToString:itemid]) {
            return item;
        }
    }
    return nil;
}

-(GalleryItemDO*)getGalleryItemByItemIDInFilter:(NSString*)itemid forFilter:(GalleryFilterDO*)gf{

    for (int i=0; i<[gf.loadedItems count]; i++) {
        GalleryItemDO * item=[gf.loadedItems objectAtIndex:i] ;
        if ([[item _id] isEqualToString:itemid]) {
            return item;
        }
    }
    return nil;
}

#pragma mark - Server Utils Delegate

-(BOOL)needLayoutLoad{
    return self.templateLayouts.count==0;
}



#pragma mark - Handle custom items
-(void)addCustomItem:(GalleryItemDO*)item{
    [self.customItems addObject:item];
}

-(GalleryItemDO*)findCustomItem:(NSString*)itemid{
    
    for (int i=0; i<[self.customItems count]; i++) {
        GalleryItemDO * item=[self.customItems objectAtIndex:i] ;
        if ([[item _id] isEqualToString:itemid]) {
            return item;
        }
    }
    return nil;
}

- (void) roomTypeSelected:(NSString*) key :(NSString*) value {
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D]) {
//            [HSFlurry logEvent:EVENT_NAME_COMMUNITY withParameters:@{EVENT_ACTION_COMMUNITY_ROOM_TYPE:key}];
        } else if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms]) {
//            [HSFlurry logEvent:EVENT_NAME_EMPTY_ROOM withParameters:@{EVENT_ACTION_EMPTY_ROOM_FILTER:key}];
        }
    }
#endif
}

- (void) sortTypeSelected:(NSString*) key {
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D]) {
//            [HSFlurry logEvent:EVENT_NAME_COMMUNITY withParameters:@{EVENT_ACTION_COMMUNITY_LOAD_DESIGNSTREAM:[GalleryStreamManager eventNameFromCommunityFilterType:key]}];
        } else if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms]) {
//            [HSFlurry logEvent:EVENT_NAME_EMPTY_ROOM withParameters:@{EVENT_ACTION_EMPTY_ROOM_SORT:[GalleryStreamManager eventNameFromEmptyRoomSortType:key]}];
        }
    }
#endif
}

+ (NSString *)eventNameFromCommunityFilterType:(NSString *)key {
    if ([key isEqualToString:@"1"]) {
        return @"Feature";
    }
    if ([key isEqualToString:@"2"]) {
        return @"Follow";
    }
    if ([key isEqualToString:@"3"]) {
        return @"New";
    }

    // "1"
    return @"Feature";
}

+ (NSString *)eventNameFromEmptyRoomSortType:(NSString *)key {
    if ([key isEqualToString:@"1"]) {
        return @"Default";
    }
    if ([key isEqualToString:@"2"]) {
        return @"Popular";
    }

    // "1"
    return @"Default";
}

- (void)refreshDataStream:(NSString *)itemType
              andRoomType:(NSString *)roomType
                andSortBy:(NSString *)sortBy
                galleryVC:(GalleryStreamBaseController*)galStream
{
    NSLog(@"refreshDataStream itemType: %@ roomType: %@ sortBy: %@",itemType , roomType, sortBy);
    
    activeGalleryFilterDO = [[GalleryFilterDO alloc] init:itemType
                                              andRoomType:roomType
                                                andSortBy:sortBy];
    
    if ([activeGalleryFilterDO.loadedItems count]==0 && activeGalleryFilterDO.canLoadMore==YES) {
        //make call to server to get data
        
        if(_bIsLayoutRequestLoaded == YES)
        {
            [self loadFirstBulckOfDesignsForActiveFilter:^(id serverResponse, id error) {
                
                [galStream onGetGalleryItemsCompletionWithState:YES];
                
            } queue:dispatch_get_main_queue()];
            
        } else {
        
            [self loadStreamLayoutsWithCompletionBlock:^(id serverResponse, id error) {
                
                //now load first bulk of designs for currently created filter
                [self loadFirstBulckOfDesignsForActiveFilter:^(id serverResponse, id error) {
                    [galStream onGetGalleryItemsCompletionWithState: YES];
                    
                } queue:dispatch_get_main_queue()];
                
            } queue:dispatch_get_main_queue()];
        }
    } else {
        [galStream onGetGalleryItemsCompletionWithState:YES];
    }
}

-(void)loadFirstBulckOfDesignsForActiveFilter:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue{
    
    if (!activeGalleryFilterDO) {
        return;
    }
    
    if ([activeGalleryFilterDO.loadedItems count]==0 && activeGalleryFilterDO.canLoadMore==YES)
    {
        //in this case is the first X designs
        [self getNextBulkOfDesignsForActiveFilter:completion queue:queue];
        
    }else{
        if (completion) {
            completion(activeGalleryFilterDO,nil);
        }
    }
}

-(void) clearObservers;
{
}

-(GalleryFilterDO*) getActiveGalleryFilterDO
{
    return activeGalleryFilterDO;
}

-(UIViewController*) openDesignStreamWithType:(NSString*)itemType andRoomType:(NSString*)roomType andSortBy:(NSString*)sortBy
{
    if (![ConfigManager isAnyNetworkAvailableOrOffline]) {
        [ConfigManager showMessageIfDisconnected];
        return nil;
    }
    
    self.galleryStreamViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryStreamTableView"
                                                                                                               inStoryboard:kGalleryStoryboard];
    
    [self refreshDataStream:itemType andRoomType:roomType andSortBy:sortBy galleryVC:self.galleryStreamViewController ];
    
    if ([itemType isEqualToString:DesignStreamTypeEmptyRooms]) {
        self.galleryStreamViewController.isStreamOfEmptyRooms=YES;
    }else{
        self.galleryStreamViewController.isStreamOfEmptyRooms=NO;
    }
    
    [self.galleryStreamViewController resetFiltersAndSortButtons];
    return self.galleryStreamViewController;
}

#pragma mark-
#pragma mark- Like handling
-(NSArray*)getUserLikesDesigns{
    
    NSMutableArray * arr=[NSMutableArray arrayWithCapacity:0];
    
    NSMutableDictionary*  likeDict = self.likeDesignDictionary ;
    
    for (NSString * key in [likeDict allKeys]) {
        if ([[likeDict objectForKey:key] isUserLiked]) {
            [arr addObject:[likeDict objectForKey:key]];
        }
    }
    
    return arr;
}

-(void)addOrUpdateLikeData:(LikeDesignDO*)templike{
    
    NSMutableDictionary*  likeDict = self.likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:templike.designid];
    if(likeDO)
    {
        if(likeDO.localModified == NO)
        {
            likeDO.likesCount = templike.likesCount;
        }
    }
    else {
        [likeDict setObject: templike forKey:templike.designid];
    }
}

-(BOOL)needLikesRefresh{
    return self.loadedUserLikes==NO;
}

-(void)clearPreviousUserLikesData
{
    NSMutableDictionary*  likeDict = self.likeDesignDictionary ;
    for (id key in likeDict) {
        
        LikeDesignDO* likeDO =  [likeDict objectForKey:key];
        if(likeDO)
        {
            likeDO.isUserLiked = NO;
            likeDO.localModified = NO;
        }
    }
}

-(void)handleUserLikesData:(NSArray*)likeinfo{
    
    NSMutableDictionary*  likeDict = self.likeDesignDictionary ;
    
    self.loadedUserLikes=YES;
    
    for (int i=0; i<[likeinfo count]; i++) {
        DesignBaseClass * design=[likeinfo objectAtIndex:i];
        
        NSString * designid=design._id;
        NSNumber * likecount=design.tempLikeCount;
        LikeDesignDO * likeDO=[[LikeDesignDO alloc] init:designid andCount:likecount];
        if(likeDO.designid)
        {
            [[[AppCore sharedInstance] getGalleryManager]addOrUpdateLikeData:likeDO];
            
            likeDO=[likeDict objectForKey:designid];
            likeDO.localModified=YES;
            likeDO.isUserLiked = YES;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^
       {
            [self.galleryStreamViewController refreshCollection];
       });
}

#pragma mark - New implementation 1.1.2

-(void)loadStreamLayoutsWithCompletionBlock:(HSCompletionBlock)completion
                                      queue:(dispatch_queue_t)queue{
    if(_bIsLayoutRequestLoaded)
    {
        if (completion) {
            completion(nil,nil);
        }
        
    }else{
        _bIsLayoutRequestSent = YES;
        
        [[GStreamRO new] getGalleryLayoutsWithCompletionBlock:^(id serverResponse) {
            
            GetLayoutsDO * layouts = (GetLayoutsDO*)serverResponse;
            
            if (layouts.errorCode == -1) {
                self.layoutsFlow = [layouts.flows mutableCopy];
                self.templateLayouts = [[layouts layouts] mutableCopy];
                
                _bIsLayoutRequestLoaded = YES;
                
                _bIsLayoutRequestSent = NO;
                
                if(completion)
                    completion(serverResponse,nil);
                
            }else{
                if(completion)
                    completion(nil,layouts.hsLocalErrorGuid);
            }

        } failureBlock:^(NSError *error) {
            NSString * erMessage=[error localizedDescription];
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            
            if(completion) completion(nil,errguid);
        } queue:queue];
    }
}


-(void)getDesignStreamItemsWithFilter:(GalleryFilterDO*)filter
                              andPage:(int)page
                  withCompletionBlock:(HSCompletionBlock)completion
                                queue:(dispatch_queue_t)queue
{
    int numOfDesiredItems = (int)[[ConfigManager sharedInstance] numberOfDesignPerGalleryPage];
    //get the design stream and add to current filter
    [[GStreamRO new] getGalleryItemsForFilter:filter withPageNumber:page withItemsCountLimit:numOfDesiredItems WithCompletionBlock:^(id serverResponse) {
        
        _bRequestRefreshSent = NO;
        
        GalleryFilterDO * response=(GalleryFilterDO*)serverResponse;
        if (response.errorCode==-1) {
            if (response.extraData)
            {
                activeGalleryFilterDO.extraData = response.extraData;
            }
            if ([response.loadedItems  count]>0) {
                //add new design items
                [filter.loadedItems addObjectsFromArray:[response.loadedItems copy]];
                
                //devide items into filter layouts
                [self devideNewItemsIntoLayouts:[response.loadedItems mutableCopy] forFilter:filter];
                
                if([response.loadedItems count] >= numOfDesiredItems){
                    filter.canLoadMore = YES;
                }else{
                    filter.canLoadMore = NO;
                }
                filter.currentPageIndex++;
            }else{
                filter.canLoadMore = NO;
            }
            
            if (completion) {
                completion(response,nil);
            }
        }else{
            if (completion) {
                completion(nil,response.hsLocalErrorGuid);
            }
        }
    } failureBlock:^(NSError *error) {
        
        
    } queue:dispatch_get_main_queue()];
    
    
    
}

-(void)getNextBulkOfDesignsForActiveFilter:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue{
    
    if (!activeGalleryFilterDO) {
        return;
    }
    
    if ( _bRequestRefreshSent){
        completion(nil,nil);
        return;
    }else{
        _bRequestRefreshSent = YES;
    }
    
    [self getDesignStreamItemsWithFilter:activeGalleryFilterDO
                                 andPage:activeGalleryFilterDO.currentPageIndex
                     withCompletionBlock:completion
                                   queue:queue];
    
}

-(void)devideNewItemsIntoLayouts:(NSMutableArray*)items forFilter:(GalleryFilterDO*)gf{
    
    //Check if the stream is empty rooms
    BOOL isStreamOfEmptyRooms = [[UIManager sharedInstance] isDisplayingStreamOfEmptyRooms];
    
    while ([items count]>0) {
        
        //check last layout item
        
        GalleryLayoutDO * lastLayout = [gf.loadedLayouts lastObject];
        
        GalleryLayoutDO * template;
        
        if (isStreamOfEmptyRooms) {
            
            template = [self getTemplateLayoutForEmptyRoomsScreen];
        }
        else {
            
            int layoutFlowIndex=0;
            
            if (lastLayout!=nil) {
                layoutFlowIndex=[self getLayoutFlowIndexForLayout:[lastLayout _id]];
                // HSMDebugLog(@"Last layout id: %d, layout index %d",[lastLayout _id],layoutFlowIndex);
            }else
                layoutFlowIndex=0;
            
            if (layoutFlowIndex==-1) {
                HSMDebugLog(@"FAILED TO PARSE GALLERY ITEMS INTO LAYOUTS");
                return;
            }
            
            //get layout for flowindex
            
            NSNumber * lflowIndex=[self.layoutsFlow objectAtIndex:layoutFlowIndex];
            
            template = [self getTemplateLayoutForID:[lflowIndex intValue]];
        }
        
        GalleryLayoutDO *nwLayout = [template copy];
        
        if (nwLayout==nil) {
            return;
        }
        
        
        NSInteger itemsNeededForFlow = [[nwLayout rects]count];
        
        NSArray * subsetArray=nil;
        if (itemsNeededForFlow<[items count]) {
            //we have all items needed
            subsetArray=  [items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, itemsNeededForFlow)]];
            
        }else
        {
            //we need to find the fitting layout because we have less items then current layout
            nwLayout=[[self findFittingLayout:(int)[items count]] copy];
            itemsNeededForFlow=[[nwLayout rects]count];
            subsetArray=  [items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, itemsNeededForFlow)]];
        }
        
        if (nwLayout) {
            //add gallery items into layout
            [nwLayout initItemsForLayout:subsetArray];
            
            [gf.loadedLayouts addObject:nwLayout];
        }
        
        lastLayout=nwLayout;
        //remove added items
        [items removeObjectsInArray:subsetArray];
    }
    
}

#pragma mark - Room Types

- (NSArray *)defaultRoomTypes
{
    NSMutableArray *arrDefault = [NSMutableArray array];
    NSArray * types=[NSArray arrayWithObjects:@"Bathroom",@"Bedroom",@"Dining Room",@"Kids Room",@"Kitchen",
                                                @"Living Room",@"Office",@"Other Room",@"Outdoors",@"Commercial/Public Exterior",
                                                @"Commercial/Public Interior",@"Residential Exterior",@"Entrance & Hallway",
                                                @"Product Showcase",@"Floor-Plan",@"Studio",@"Basement",
                                                @"Home Cinema",@"Library",@"Den",@"Sketch",@"Porch & Balcony", nil];
    NSArray * typeids=[NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",
                                                @"16",@"17",@"18",@"19",@"20",@"21",@"22", nil];
    
    for (int i=0; i<[types count]; i++)
    {
        RoomTypeDO *room = [[RoomTypeDO alloc] init];
        room.myId = [typeids objectAtIndex:i];
        room.desc = [types objectAtIndex:i];
        [arrDefault addObject:room];
    }
    
    return arrDefault;
}


- (void)getRoomTypesWithCompletionBlock:(void (^)(NSArray *arrRoomTypes))success failureBlock:(void (^)(NSError *error))failure
{
    [[GetRoomTypesRO new] getRoomTypesWithcompletionBlock:^ (id serverResponse)
     {
         if (success)
         {
             if (serverResponse != nil)
             {
                 NSArray *arr = (NSArray *) serverResponse;
                 
                 if (([arr respondsToSelector:@selector(count)]) && (arr.count == 0))
                 {
                     arr = [self defaultRoomTypes];
                 }
                 
                 success(arr);
             }
             else
             {
                 success([self defaultRoomTypes]);
             }
         }
     } failureBlock:^ (NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     } queue:(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0))];
}

#pragma mark - Refresh Timer

+ (NSTimeInterval)getRefreshRateInSeconds
{
    NSNumber* refreshRate =  [[ConfigManager sharedInstance] refreshRateGalleryStream];
    NSTimeInterval timeInterRefreshRate = [refreshRate intValue]*60;
    
    return timeInterRefreshRate;
}

- (void) refreshTimerEvent:(NSTimer *)timer{
    
    BOOL isRefresh = [self shouldExecuteRefreshTimerEvent];
    
    if (isRefresh)
    {
        [self refreshStreams];
        [self refreshBanner];
        [self reportRefreshTimerEventExecuted];
    }
}

- (BOOL)shouldExecuteRefreshTimerEvent
{
    if (_lastRefreshDate == nil)
    {
        _lastRefreshDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshTimerEvent_lastRefresh"];
        return YES;
    }
    
    NSDate *nowDate = [NSDate date];
    
    NSTimeInterval timeDiff = [nowDate timeIntervalSinceDate:_lastRefreshDate];
    NSTimeInterval threshold = [GalleryStreamManager getRefreshRateInSeconds];
    
    return (timeDiff + 10 > threshold);
}

- (void)reportRefreshTimerEventExecuted
{
    _lastRefreshDate = [NSDate date];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_lastRefreshDate forKey:@"refreshTimerEvent_lastRefresh"];
    [defaults synchronize];
}

- (void)refreshStreams
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        
        GalleryFilterDO * gf = self.getActiveGalleryFilterDO;
        
        __block int index = 0;
        //refresh data for all pages
        for (int i=0; i<gf.currentPageIndex; i++) {
            
            HSMDebugLog(@"REFRESH DATA LOOP INDEX %d",i);
            
            //create temp filter to get specific 300 items and not adding to already existing
            GalleryFilterDO * tempFilter=[[GalleryFilterDO alloc] init];
            tempFilter.roomTypeFilter=gf.roomTypeFilter;
            tempFilter.sortType=gf.sortType;
            tempFilter.filterType=gf.filterType;
            
            [self getDesignStreamItemsWithFilter:tempFilter andPage:i withCompletionBlock:^(id serverResponse, id error) {
                
                if (error==nil) {
                    GalleryFilterDO *response=(GalleryFilterDO*)serverResponse;
                    
                    NSMutableArray * tempNewItems=[[response loadedItems] mutableCopy];
                    
                    [gf updateLoadedItem:tempNewItems atIndex:index];
                    index+= [tempNewItems count];
                }
                
            } queue:dispatch_get_main_queue()];
        }
    });
}

- (void)refreshBanner {
    
    if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"] ||
        ![[ConfigManager sharedInstance] isConfigLoaded]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        
        [[GStreamRO new] getBanneritemsCompletionBlock:^(id serverResponse) {
            self.bannerArray = serverResponse;
            
        } failureBlock:^(NSError *error) {
            
        } queue:dispatch_get_main_queue()];
        
    });
}

-(void)clearStreams{
    [self refreshStreams];
    [self refreshBanner];
}

-(GalleryBanneItem*)getBannerArray
{
    if (self.bannerArray.image_link.count && ![[ConfigManager getTenantIdName] isEqualToString:@"ezhome"] ) {
        
        return self.bannerArray.image_link[0];
        
    }else{
        return nil;
    }
}

@end










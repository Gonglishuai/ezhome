//
//  GalleryStreamManager.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//

#import <Foundation/Foundation.h>
#import "GalleryItemDO.h"
#import "BaseManager.h"
#import "GalleryFilterDO.h"
#import "GalleryBanner.h"

@class GalleryStreamBaseController;

typedef enum DesignsFilterTypes
{
    eFilter3dItem =  1,
    eFilter2dItem =  2,
    eFilterArticle = 3,
    eFilterNone = 4 
} DesignFilterType;

typedef void(^getItemsCompletionBlock)(BOOL state, BOOL needRefresh);

@interface GalleryStreamManager : BaseManager <NSCoding>
{
    
}

@property(nonatomic) NSMutableArray * customItems;
@property(nonatomic) NSMutableArray * layoutsFlow;
@property(nonatomic) NSMutableArray * templateLayouts;
@property(nonatomic) GalleryBanner * bannerArray;
@property(nonatomic) BOOL loadedUserLikes;
@property(nonatomic) BOOL noMoreDataCanReturn;
@property(nonatomic) BOOL bRequestRefreshSent;
@property(nonatomic) int _numOfDesiredItems;
@property(nonatomic) int _pageIndexDesiredItems;
@property(nonatomic) NSTimer* _refreshTimer;
@property(nonatomic) BOOL bIsLayoutRequestSent;
@property(nonatomic) BOOL bIsLayoutRequestLoaded;
@property(nonatomic)NSMutableDictionary * likeDesignDictionary;

+ (GalleryStreamManager*)sharedInstance;
-(void)logout;
-(BOOL)canLoadMoreDesignItems;
-(void)clearPreviousUserLikesData;
-(BOOL)needLikesRefresh;
-(GalleryFilterDO*) getActiveGalleryFilterDO;
-(UIViewController*) openDesignStreamWithType:(NSString*) itemType andRoomType:(NSString*) roomType andSortBy:(NSString*) sortBy;
-(GalleryItemDO*)getGalleryItemByItemID:(NSString*)itemid;
-(GalleryItemDO*)getGalleryItemByItemIDInFilter:(NSString*)itemid forFilter:(GalleryFilterDO*)gf;
-(void)addOrUpdateLikeData:(LikeDesignDO*)templike;
-(void)getRoomTypesWithCompletionBlock:(void (^)(NSArray *arrRoomTypes))success failureBlock:(void (^)(NSError *error))failure;
-(void)handleUserLikesData:(NSArray*)likeinfo;
-(void)addCustomItem:(GalleryItemDO*)item;
-(GalleryItemDO*)findCustomItem:(NSString*)itemid;
-(void)loadFirstBulckOfDesignsForActiveFilter:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue;
-(void)refreshDataStream:(NSString *)itemType andRoomType:(NSString *)roomType andSortBy:(NSString *)sortBy galleryVC:(GalleryStreamBaseController *)galStream;
-(void)roomTypeSelected:(NSString*) key :(NSString*) value;
-(void)sortTypeSelected:(NSString*) key;
-(void) refreshTimerEvent:(NSTimer *)timer;
-(void)loadStreamLayoutsWithCompletionBlock:(HSCompletionBlock)completion
                                      queue:(dispatch_queue_t)queue;
-(void)getNextBulkOfDesignsForActiveFilter:(HSCompletionBlock)completion
                                      queue:(dispatch_queue_t)queue;
-(NSArray*)getUserLikesDesigns;
- (NSArray *)defaultRoomTypes;
-(GalleryBanneItem*)getBannerArray;
-(void)refreshBanner;
@end

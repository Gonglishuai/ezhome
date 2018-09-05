//
//  GalleryFilterDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/4/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseResponse.h"
#import "RestkitObjectProtocol.h"
#import "GalleryFilterExtraDO.h"

@interface GalleryFilterDO : BaseResponse <RestkitObjectProtocol>

-(id)init:(NSString*) itemType andRoomType:(NSString*) roomType andSortBy:(NSString*) sortBy;


@property(nonatomic) NSMutableArray * loadedItems;
@property(nonatomic) NSMutableArray * loadedLayouts;
@property(nonatomic) GalleryFilterExtraDO *extraData;
@property(nonatomic) BOOL canLoadMore;
@property(nonatomic) int currentPageIndex;
@property ( nonatomic)  NSString*  filterType;
@property ( nonatomic)  NSString*  roomTypeFilter;
@property ( nonatomic)  NSString*  sortType;
-(NSString*) generateCurrentFilterKey;
-(NSString*) sortTypeToString;
-(BOOL) updateLoadedItem :(NSMutableArray* )items atIndex:(int)index;

@end


//
//  GalleryFilterDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/4/13.
//
//

#import "GalleryFilterDO.h"

@implementation GalleryFilterDO

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                 toKeyPath:@"loadedItems"
                                               withMapping:[GalleryItemDO jsonMapping]]];
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"free"
                                                 toKeyPath:@"extraData"
                                               withMapping:[GalleryFilterExtraDO jsonMapping]]];
    return entityMapping;
}

-(void)applyPostServerActions
{
    self.loadedLayouts = [NSMutableArray array];
    
    if (self.loadedItems) {
        for (int i=0;i<[self.loadedItems count]; i++) {
            if ([[self.loadedItems objectAtIndex:i] respondsToSelector:@selector(applyPostServerActions)]) {
                [[self.loadedItems objectAtIndex:i] applyPostServerActions];
            }
        }
    }
    NSLog(@"");
}

-(id)init:(NSString*) itemType andRoomType:(NSString*) roomType andSortBy:(NSString*) sortBy
{
    self = [self init];
    if (self) {
        _filterType = itemType;
        _roomTypeFilter = roomType;
        _sortType = sortBy;
        self.loadedItems = [NSMutableArray array];
        self.loadedLayouts = [NSMutableArray array];
        self.extraData = [[GalleryFilterExtraDO alloc] init];
    }
    return self;
}

-(id)init{
    self = [super init];
    
    if (self) {
        self.loadedItems = [NSMutableArray array];
        self.loadedLayouts = [NSMutableArray array];
        self.canLoadMore = YES;
        self.currentPageIndex = 0;
    }
    return self;
}

-(NSString*)generateCurrentFilterKey{
    
    NSString * key=@"";
    
    if ([_filterType length]>0) {
        key=[NSString stringWithFormat:@"ft:%@",_filterType];
        
    }
 
    if ([_roomTypeFilter length]>0 ) {
        if ([key length]>0)
            key=[NSString stringWithFormat:@"%@_rtf:%@",key,_roomTypeFilter];
        else
            key=[NSString stringWithFormat:@"rtf:%@",_roomTypeFilter];
    }
    
    if ([_sortType length]>0 ) {
        if ([key length]>0)
            key=[NSString stringWithFormat:@"%@_srt:%@",key,_sortType];
        else
            key=[NSString stringWithFormat:@"srt:%@",_sortType];
    }
    
    NSLog(@"KEY: %@", key);
    
    return key;
}

- (NSString*) sortTypeToString{
   
    NSString* retVal = @"featured";
    if([_sortType isEqualToString:@"1"] )
    {
        if ([_filterType isEqualToString:DesignStreamTypeEmptyRooms])
        {
            retVal = @"d";
        }
    }
    else if([_sortType isEqualToString:@"2"])
    {
        if ([_filterType isEqualToString:DesignStreamTypeEmptyRooms])
        {
            retVal = @"pop";
        }
        else
        {
            retVal = @"following";
        }
    }
    else if([_sortType isEqualToString:@"3"])
    {
        retVal = @"new";
    }
    return retVal;
}

-(BOOL) updateLoadedItem :(NSMutableArray* )items atIndex:(int)index
{
    BOOL bRetVal = YES;
    for (int i=0; i<[items count]; i++)
    {
        if ( index + i > [self.loadedItems count]  )
        {
            bRetVal = NO;
            break;
        }
        self.loadedItems[index+i] = items[i];
    }
    return bRetVal;
    
}

- (void)dealloc
{
    NSLog(@"dealloc - GalleryFilterDO");
}
@end

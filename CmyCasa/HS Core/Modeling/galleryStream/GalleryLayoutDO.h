//
//  GalleryLayoutDO.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@interface GalleryLayoutDO : NSObject <NSCoding,RestkitObjectProtocol>


@property(nonatomic,readonly)int  _id;
@property(nonatomic,strong)NSString * rectsDictString;
@property(nonatomic,readonly)NSMutableArray * rects;

@property(nonatomic,readonly)int height;

@property(nonatomic,readonly)NSMutableArray * layoutsFlow;
@property(nonatomic,readonly)NSMutableArray * itemsInLayoutArray;

-(id)initWithDictionary:(NSMutableDictionary*)dict;
-(void)initItemsForLayout:(NSArray*)items;

@end

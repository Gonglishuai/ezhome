//
//  GalleryLayoutDO.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import "GalleryLayoutDO.h"
#import "LayoutRectDO.h"
#import "GalleryItemDO.h"
#import "GalleryStreamManager.h"


@interface GalleryLayoutDO ()

@property(nonatomic)int  _id;
@property(nonatomic)NSMutableArray * rects;
@property(nonatomic)int height;

@property(nonatomic)NSMutableArray * layoutsFlow;
@property(nonatomic)NSMutableArray * itemsInLayoutArray;

@end

@implementation GalleryLayoutDO


+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"_id",
     @"data" :@"rectsDictString"
     }];
    
  
    
    
    return entityMapping;
}
-(void)applyPostServerActions
{
     
    //now parse the data string into dictionanry
    if (self.rectsDictString) {
        
 
    NSMutableDictionary * md= [self.rectsDictString parseJsonStringIntoMutableDictionary];
    
    
    self.height=[[md  objectForKey:@"h"] intValue];
    
    self.itemsInLayoutArray=[NSMutableArray arrayWithCapacity:0];
    self.rects=[NSMutableArray arrayWithCapacity:0];
    
    //initialize rects
    NSArray * rcts=[[md objectForKey:@"rects"] objectForKey:@"rect"];
    
    for(NSMutableDictionary * d in rcts)
    {
        LayoutRectDO * lrect=[[LayoutRectDO alloc] initWithDictionary:d];
        [self.rects addObject:lrect];
    }
   }
}

-(id)initWithDictionary:(NSMutableDictionary*)dict{
    
    self=[super init];
    
    
    
    
    self._id=[[dict objectForKey:@"id"] intValue];
    
    
    NSString * jsonStr=[dict objectForKey:@"data"];
    
    NSMutableDictionary * md= [jsonStr parseJsonStringIntoMutableDictionary];
    
    
    self.height=[[md  objectForKey:@"h"] intValue];
    
    self.itemsInLayoutArray=[NSMutableArray arrayWithCapacity:0];
    self.rects=[NSMutableArray arrayWithCapacity:0];
    
    //initialize rects
    NSArray * rcts=[[md objectForKey:@"rects"] objectForKey:@"rect"];
    
    for(NSMutableDictionary * d in rcts)
    {
        LayoutRectDO * lrect=[[LayoutRectDO alloc] initWithDictionary:d];
        [self.rects addObject:lrect];
    }
    
    
    
    return  self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}
-(id)copyWithZone:(NSZone *)zone {
    GalleryLayoutDO* newItem = [GalleryLayoutDO new];
   
    newItem.itemsInLayoutArray=[NSMutableArray arrayWithCapacity:0];//self.itemsInLayoutArray;
    newItem.rects=self.rects;
    newItem._id=self._id;
    newItem.height=self.height;
    newItem.layoutsFlow=self.layoutsFlow;
    
    
    /*[newItem setName:[self name]];
    [newItem setPrice:[self price]];
    [newItem setPictureFile:[self pictureFile]];*/
    
    return newItem;
}

-(void)initItemsForLayout:(NSArray*)items{
    
    self.itemsInLayoutArray=[NSMutableArray arrayWithArray:items];
   
}

@end

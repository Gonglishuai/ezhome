//
//  LayoutRectDO.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/12/13.
//
//

#import "LayoutRectDO.h"
@interface LayoutRectDO ()

@property(nonatomic)int x;
@property(nonatomic)int y;
@property(nonatomic)int w;
@property(nonatomic)int h;
@property(nonatomic)int left;
@property(nonatomic)int top;
@property(nonatomic)int _id;


@end
@implementation LayoutRectDO

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"x" : @"x",
     @"y" : @"y",
     @"w" : @"w",
     @"h" : @"h",
     @"l" : @"left",
     @"t" : @"top",
     @"id" : @"_id"
     }];
    
    return entityMapping;
}
-(void)applyPostServerActions
{
    NSLog(@"");
    
}

-(id)initWithDictionary:(NSMutableDictionary*)dict{
    
    self=[super init];
    
    self.x=[[dict objectForKey:@"x"] intValue];
    self.y=[[dict objectForKey:@"y"] intValue];
    self.w=[[dict objectForKey:@"w"] intValue];
    self.h=[[dict objectForKey:@"h"] intValue];
    self.left=[[dict objectForKey:@"l"] intValue];
    self.top=[[dict objectForKey:@"t"] intValue];
    self._id= [[dict objectForKey:@"id"] intValue];
    
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}
@end

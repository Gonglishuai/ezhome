//
// Created by Berenson Sergei on 3/31/14.
//


#import "CommandItem.h"


@implementation CommandItem

-(void)dealloc
{
    HSMDebugLog(@"dealloc - CommandItem");
}

- (instancetype)initWithPosition:(GLKVector3)position rotation:(GLKVector3)rotation andScale:(GLKVector3)scale forItemID:(NSString *)itemID
{
    self = [super init];


    self.position = position;
    self.rotation = rotation;
    self.scale = scale;
    self.itemID = itemID;
    //NSLog(@"UNDO ROTATION: %f,%f,%f",rotation.x,rotation.y,rotation.z);
    return self;
}

-(NSString*)printVector3:(GLKVector3)vec
{
    return [NSString stringWithFormat:@"{%f,%f,%f}",vec.x,vec.y,vec.z];
}

- (NSString*)description

{
    return  [NSString stringWithFormat:@"id:%@ , pos:%@, rot: %@ ,scale:%@",self._id,[self printVector3:self.position],
             [self printVector3:self.rotation],
             [self printVector3:self.scale]];
}

-(NSString*)itemID
{
    return _itemID;
}
@end
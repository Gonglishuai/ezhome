//
//  CommandConcealItem.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/13/14.
//
//

#import "CommandConcealItem.h"

@implementation CommandConcealItem



- (instancetype)initWithStepData:(NSData*)data  andItemID:(NSString*)itemid
{
    self = [super init];
    
    self.data = data;
    self.itemID = itemid;
    
    
    return self;
}

-(NSString*)itemID
{
    return _itemID;
}
@end

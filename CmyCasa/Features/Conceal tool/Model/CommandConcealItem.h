//
//  CommandConcealItem.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/13/14.
//
//

#import <Foundation/Foundation.h>
#import "CommandItem.h"

@interface CommandConcealItem : NSObject  <CommandItemDelegate>


- (instancetype)initWithStepData:(NSData*)data andItemID:(NSString*)itemid;
@property(nonatomic,strong ) NSString * itemID;
@property(nonatomic,strong ) NSData * data;

@end

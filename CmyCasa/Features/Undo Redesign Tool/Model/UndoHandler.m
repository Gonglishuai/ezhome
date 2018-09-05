//
// Created by Berenson Sergei on 3/31/14.
//


#import "UndoHandler.h"
#import "CommandItem.h"

@implementation UndoHandler


-(void)dealloc
{
    HSMDebugLog(@"dealloc - UndoHandler");
}

- (id)initWithStepsLimit:(NSInteger)limit 
{
   self = [super init];
    
    self.undoCommandsList = [NSMutableArray new];
    self.redoCommandsList = [NSMutableArray new];
    self.stepsLimit = limit;
    return self;
}

- (BOOL)canPerformCommand:(CommandType)commandType
{
    switch (commandType) {
        case kCommandRedo:
            return [self.redoCommandsList count]!=0;
        case kCommandUndo:
            return [self.undoCommandsList count]!=0;
        default:
            break;
    }

    return NO;
}

- (NSMutableArray *)getHistoryList
{
    return self.undoCommandsList;
}

- (void)clearCommandByType:(CommandType)commandType
{
    switch (commandType) {
        case kCommandRedo:
             [self.redoCommandsList removeAllObjects];
            break;
        case kCommandUndo:
             [self.undoCommandsList removeAllObjects];
            break;
        default:
            break;
    }
}

- (void)addUndoCommand:(id<CommandItemDelegate> )item
{
    if (self.undoCommandsList.count !=0 && self.undoCommandsList.count>=self.stepsLimit)
    {
        [self.undoCommandsList removeObjectAtIndex:0];

    }
    [self.undoCommandsList addObject:item];
}

- (void)addRedoCommand:(id<CommandItemDelegate> )item
{
    if (self.redoCommandsList.count !=0 && self.redoCommandsList.count>=self.stepsLimit)
    {
        [self.redoCommandsList removeObjectAtIndex:0];
    }
    [self.redoCommandsList addObject:item];
}

- (id <CommandItemDelegate>)getUndoCommand
{
    if (!self.undoCommandsList || self.undoCommandsList.count ==0) return nil;

    id <CommandItemDelegate> item = [self.undoCommandsList lastObject];
    [self.undoCommandsList removeObject:item];
    return item;
}

- (void)clearAllCommandsWithAllTypes
{
    [self clearCommandByType:kCommandRedo];
    [self clearCommandByType:kCommandUndo];
}

- (id <CommandItemDelegate>)getRedoCommand
{

    if (!self.redoCommandsList || self.redoCommandsList.count ==0) return nil;

    id <CommandItemDelegate>  item = [self.redoCommandsList lastObject];
    [self.redoCommandsList removeObject:item];
    return item;
}

- (void)removeCommandsForCommandID:(NSString*)commandID
{
    
    for (int i = 0; i<self.undoCommandsList.count; i++) {
        id <CommandItemDelegate> it = [self.undoCommandsList objectAtIndex:i];
        if ([it.itemID isEqualToString:commandID])
        {
            [self.undoCommandsList removeObject:it];
            i--;
        }
    }
    
    for (int i = 0; i<self.redoCommandsList.count; i++) {
        id <CommandItemDelegate> it = [self.redoCommandsList objectAtIndex:i];
        if ([it.itemID isEqualToString:commandID])
        {
            [self.redoCommandsList removeObject:it];
            i--;
        }
    }

}



@end

//
// Created by Berenson Sergei on 3/31/14.
//


#import <Foundation/Foundation.h>
#import "CommandItem.h"




@protocol UndoHandlerDelegate <NSObject>

- (void)applyUndoStep;
- (void)applyRedoStep;
- (BOOL)canUndo;
- (BOOL)canRedo;

@end

typedef enum CommandTypes
{
    kCommandUndo = 6000,
    kCommandRedo = 60001
    
}CommandType;

@interface UndoHandler : NSObject
@property (nonatomic) NSInteger stepsLimit;
@property (nonatomic, strong) NSMutableArray *undoCommandsList;
@property (nonatomic, strong) NSMutableArray *redoCommandsList;

- (id)initWithStepsLimit:(NSInteger)limit;
- (NSMutableArray *)getHistoryList;
- (void)clearAllCommandsWithAllTypes;
- (void)addUndoCommand:(id<CommandItemDelegate>)item;
- (void)addRedoCommand:(id<CommandItemDelegate>)item;
- (BOOL)canPerformCommand:(CommandType)commandType;
- (void)clearCommandByType:(CommandType)commandType;
- (void)removeCommandsForCommandID:(NSString*)commandID;
- (id<CommandItemDelegate>)getUndoCommand;
- (id<CommandItemDelegate>)getRedoCommand;



@end
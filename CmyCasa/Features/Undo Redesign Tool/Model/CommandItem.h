//
// Created by Berenson Sergei on 3/31/14.
//


#import <Foundation/Foundation.h>

@protocol CommandItemDelegate <NSObject>

-(NSString*)itemID;


@end

@interface CommandItem : NSObject <CommandItemDelegate>
@property(nonatomic) GLKVector3 position;
@property(nonatomic) GLKVector3 rotation;
@property(nonatomic) GLKVector3 scale;
@property(nonatomic, copy) NSString *itemID;
@property (nonatomic,strong) NSString * _id;
- (instancetype)initWithPosition:(GLKVector3)position rotation:(GLKVector3)rotation andScale:(GLKVector3)scale forItemID:(NSString *)itemID;


@end
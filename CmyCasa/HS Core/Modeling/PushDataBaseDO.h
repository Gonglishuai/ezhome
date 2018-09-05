
//
//  PushDataBaseDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/30/13.
//
//

#import <Foundation/Foundation.h>

@interface PushDataBaseDO : NSObject



-(id)initWithData:(NSMutableArray*)data andArgs:(NSMutableArray*)args;
- (void)setupDataObject:(NSMutableArray*)data  andArgs:(NSMutableArray*)args forType:(NSString*)pushType;
@property(nonatomic)NSString * itemID;
@property(nonatomic)NSString * assetType;
@property(nonatomic)NSString * commentingID;

@property(nonatomic)NSString * pushType;
@property(nonatomic)NSArray * pushArgs;
@property(nonatomic,strong) NSString * customAlertMessage;

-(NSString*)generateUserMessage;
-(BOOL)pushValidForCommentPush;
-(BOOL)pushValidForLikeOrPublishOrPrivatePush;
@end

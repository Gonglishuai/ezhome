//
//  PushDataBaseDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/30/13.
//
//

#import "PushDataBaseDO.h"
#import "NSString+Contains.h"

@implementation PushDataBaseDO



-(id)initWithData:(NSMutableArray*)data  andArgs:(NSMutableArray*)args{
    
    self=[super init];
    
    
    [self setupDataObject:data andArgs:args forType:nil];
    return self;
}

- (void)setupDataObject:(NSMutableArray*)data  andArgs:(NSMutableArray*)args forType:(NSString*)pushType{
    if (args) {
        self.pushArgs=[args copy];
    }
    if ([data count]==1) {
        self.itemID=[data objectAtIndex:0];
    }
    if ([data count]==2) {
        self.itemID=[data objectAtIndex:0];
        self.assetType=[data objectAtIndex:1];
    }
    
    if ([data count]==3) {
        self.itemID=[data objectAtIndex:0];
        self.commentingID=[data objectAtIndex:1];
        self.assetType=[data objectAtIndex:2];
    }
    
    if (pushType) {
        self.pushType = pushType;
    }else
    {
        self.pushType = PUSH_MESSAGE_GENERAL_NOTIFICATION;
    }

}

-(NSString*)generateUserMessage{
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_GENERAL_UNDEFINED]) {
        return (![NSString isNullOrEmpty:self.customAlertMessage])?self.customAlertMessage:nil;
    }
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_LIKED_ASSET]) {
        return  [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_LIKED_ASSET", @""),self.pushArgs[0],self.pushArgs[1]];
    }
    
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_FOLLOW]) {
        return  [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_FOLLOW", @""),self.pushArgs[0]];
    }
    
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_FEATURED]) {
        return  [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_FEATURED", @""),self.pushArgs[0]];
    }
    
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_COMMENT]) {
        return  [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_COMMENT", @""),self.pushArgs[0],self.pushArgs[1]];
    }
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_PUBLISHED_ASSET]) {
        return  [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_PUBLISHED_ASSET", @""),self.pushArgs[0],self.pushArgs[1]];
    }
    
    if ([self.pushType isEqualToString:PUSH_MESSAGE_PRIVATE]) {
        return  [NSString stringWithFormat:@"%@ %@",self.pushArgs[0],self.pushArgs[1]];
    }
    
    if( [self.pushType isEqualToString:PUSH_MESSAGE_GENERAL_NOTIFICATION]) {
        return  [NSString stringWithFormat:@"%@",self.pushArgs[0]];
    }
    
    return nil;
    
}

-(BOOL)pushValidForCommentPush{
  
    if ([NSString isNullOrEmpty:self.itemID ]) {
        return NO;
    }
    if ([NSString isNullOrEmpty:self.commentingID ]) {
        return NO;
    }
    if ([NSString isNullOrEmpty:self.assetType ]) {
        return NO;
    }
    
    return YES;
}
-(BOOL)pushValidForLikeOrPublishOrPrivatePush{
    
    if ([NSString isNullOrEmpty:self.itemID ]) {
        return NO;
    }
    if ([NSString isNullOrEmpty:self.assetType ]) {
        return NO;
    }
    
    return YES;
}
@end











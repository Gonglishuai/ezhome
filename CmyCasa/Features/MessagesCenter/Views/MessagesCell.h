//
//  MessagesCell.h
//  Homestyler
//
//  Created by liuyufei on 4/27/18.
//

#import <UIKit/UIKit.h>

#import "ProfileProtocols.h"

@class NotificationDetailDO;

@interface MessagesCell : UITableViewCell

@property (nonatomic, strong) NotificationDetailDO *detail;

@property (nonatomic, weak) id<FollowUserItemDelegate> followUserDelegate;

@property (nonatomic, weak) id<DesignItemDelegate> designItemDelegate;

@end

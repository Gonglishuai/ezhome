//
//  DesignItemView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePageBaseViewController.h"

#define DESIGN_ITEM_CELL_HEIGHT 300
#define DESIGN_ITEM_CELL_IDENTIFIER @"DesignItemCell"

@interface DesignItemView : UITableViewCell<ProfileCellUnifiedInitProtocol>
- (IBAction)editPressed;

@property (weak, nonatomic) IBOutlet UIImageView *autosaveLayer;
@property (nonatomic, strong) MyDesignDO* design;
@property (nonatomic) BOOL isCurrentUserDesign;
@property (nonatomic, weak) id<DesignItemDelegate, LikeDesignDelegate, CommentDesignDelegate> delegate;

@end

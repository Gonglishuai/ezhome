//
//  ProfileCollectionViewCell_DesignItem.h
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import <UIKit/UIKit.h>
#import "ProfileProtocols.h"

@interface ProfileCollectionViewCell_DesignItem : UICollectionViewCell

@property (nonatomic, strong) MyDesignDO *designModel;
@property (nonatomic) BOOL isOwnerProfile;

@property (nonatomic, weak) id<DesignItemDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *designImageView;
@property (weak, nonatomic) IBOutlet UIImageView *designTag;

- (void)resetUI;
- (void)refreshUI;

@end

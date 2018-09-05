//
//  ProfileCollectionViewCell_DesignBig.h
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import <UIKit/UIKit.h>
#import "ProfileCollectionViewCell_DesignItem.h"

@interface ProfileCollectionViewCell_DesignBig : ProfileCollectionViewCell_DesignItem

+ (CGFloat)calcDesignDescrtiptionTextHeightForDesign:(MyDesignDO *)design cellWidth:(CGFloat)width;

- (void)updateLikeStatus;
- (void)updateCommentsCount;

@end

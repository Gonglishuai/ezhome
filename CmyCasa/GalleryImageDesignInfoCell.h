//
//  GalleryImageDesignInfoCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/7/13.
//
//

#import "GalleryImageItemInfoCell.h"

@interface GalleryImageDesignInfoCell : GalleryImageItemInfoCell

-(void)loadUserProfileImage;

- (void)toggleLikeState;
- (void)restoreLikeState;

- (void)refreshCommentsCount;

@end

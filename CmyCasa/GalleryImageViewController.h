//
//  iphoneGalleryImageViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "GalleryItemBaseViewController.h"

@interface GalleryImageViewController : GalleryItemBaseViewController

@property (nonatomic) BOOL isTableMoved;
@property (nonatomic) BOOL isImageRequested;

-(void)createNewCommentPendingToLoadComments;
-(void)createNewComment;
-(void)moveTableViewToIndexPath:(DesignDiscussionDO*)comment;

-(void)resetImageLoading;

@end

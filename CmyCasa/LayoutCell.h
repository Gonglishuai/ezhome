//
//  LayoutCell.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GalleryStreamViewController.h"
#import "GalleryLayoutDO.h"
#import "StreamTemplateView.h"

@interface LayoutCell : UITableViewCell <GalleryStreamViewControllerDelegate,GalleryImagesDelegate>

@property (nonatomic) StreamTemplateView *streamTemplate;
@property (nonatomic) NSMutableArray * layoutItemsImages;
@property (nonatomic) GalleryLayoutDO* galleryLayout;
@property (nonatomic, weak) id<GalleryStreamViewControllerDelegate,GalleryImagesDelegate> galleryDelegate;

-(void)initCellWithLayout:(GalleryLayoutDO *)layout withDelegate:(id)delegate withTemplate:(StreamTemplateView *)newtemplate needImageLoad:(BOOL)shouldStartLoading;
-(void)cellImageUpade:(int)index withImage:(UIImage*)img;
-(BOOL)needImageUpdate:(int)index;
-(NSMutableArray*)getImagesForCell:(GalleryLayoutDO*)layout;
-(void)reloadImageContent:(BOOL)shouldReload;
@end

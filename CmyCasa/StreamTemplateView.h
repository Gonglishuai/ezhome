//
//  StreamTemplateView.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import <UIKit/UIKit.h>
#import "GalleryStreamBaseController.h"
#import "GalleryLayoutDO.h"

@interface StreamTemplateView : UIView

@property (nonatomic, strong) NSMutableArray * layoutItemsArray;
@property (nonatomic, strong) GalleryLayoutDO* galleryLayout;

-(void)initializeWithTemplate:(GalleryLayoutDO*)layout;
-(void)refreshWithDelegate:(id<GalleryStreamViewControllerDelegate,GalleryImagesDelegate>)newdeleg andLayout:(GalleryLayoutDO*)layout;
-(void)clearImages;
-(void)clearObservers;
-(void)addObservers;
-(BOOL)likesPressedWithResponseOK:(NSString*)designID;
-(BOOL)isFitForLayout:(GalleryLayoutDO*)layout;
-(void)releaseReference;


@end

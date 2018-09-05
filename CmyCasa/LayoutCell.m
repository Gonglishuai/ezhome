//
//  LayoutCell.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import "LayoutCell.h"
#import "GalleryLayerItemViewController.h"
#import "GalleryStreamViewController.h"
#import "GalleryItemDO.h"
#import "LayoutRectDO.h"
#import "NSString+CommentsAndLikesNum.h"

@implementation LayoutCell

-(int)getLayoutItemsCount{
    return (int)[self.galleryLayout.itemsInLayoutArray count];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (self.streamTemplate) {
        [self.streamTemplate releaseReference];
        [self.streamTemplate clearObservers];
        [self.streamTemplate removeFromSuperview];
    }
    
    if (!self.layoutItemsImages) {
        self.layoutItemsImages=[NSMutableArray arrayWithCapacity:0];
    }else
        [self.layoutItemsImages removeAllObjects];
}

-(void)clearImages{
    [self.streamTemplate clearImages];
}

-(void)dealloc{
    
    NSLog(@"dealloc - LayoutCell");
    
    self.galleryLayout = nil;
    self.galleryDelegate = nil;
    
    [self.layoutItemsImages removeAllObjects];
    self.layoutItemsImages = nil;
    
    if (self.streamTemplate) {
        [self.streamTemplate releaseReference];
    }
}

-(NSMutableArray*)getImagesForCell:(GalleryLayoutDO*)layout {
   
    NSMutableArray * _layoutItemsImgs=[NSMutableArray arrayWithCapacity:0];
    int localItems = (int)[[layout itemsInLayoutArray]count];
    
    for (int i=0;i<localItems;i++){

        GalleryItemDO * item=[[layout itemsInLayoutArray] objectAtIndex:i];
        LayoutRectDO * rect=[[layout rects] objectAtIndex:i];
        
        
        int width = self.frame.size.width;
        int height = self.frame.size.height;
        
        
        CGRect frame_rect = CGRectMake(width*rect.x/100+10,
                                       height*rect.y/100+10,
                                       width*rect.w/100-20,
                                       height*rect.h/100-11);
        
        //to make same width size between itemDetails
        if( frame_rect.origin.x>100)
        {
            frame_rect.origin.x-=8;
            frame_rect.size.width+=9;
        }
        
        if([item._id length]>0)
        {
            NSString* strID_Thumb = [NSString stringWithFormat:@"%@_thumb", item._id];
            NSString* imagePath = [[ConfigManager sharedInstance] getStreamFilePath:strID_Thumb];
            imagePath=[imagePath generateImagePathForWidth:frame_rect.size.width andHight:frame_rect.size.height];
            NSMutableDictionary * dt=[NSMutableDictionary dictionaryWithCapacity:0];
            NSString * img=[NSString stringWithFormat:@"%@", item.url];
            img= [img generateImageURLforWidth:frame_rect.size.width andHight:frame_rect.size.height];
            //path, image,layout,image_index
            [dt setObject:imagePath forKey:@"path"];
            [dt setObject:img forKey:@"image"];
            [dt setObject:[NSString stringWithFormat:@"%d",layout._id] forKey:@"layout"];
            [dt setObject:[NSNumber numberWithInt:i] forKey:@"image_index"];
            [_layoutItemsImgs addObject:dt];
        }
    }
    return _layoutItemsImgs;
}

- (void)initCellWithLayout:(GalleryLayoutDO *)layout withDelegate:(id)delegate withTemplate:(StreamTemplateView *)newtemplate needImageLoad:(BOOL)shouldStartLoading
{
    self.streamTemplate = newtemplate;
    
    [self addSubview:self.streamTemplate];
        
    [self.streamTemplate refreshWithDelegate:self andLayout:layout];
    
    self.galleryLayout = layout;
    self.galleryDelegate = delegate;

    int localItems = [self getLayoutItemsCount];
    
    for (int i=0;i<localItems;i++){
        
        GalleryItemDO * item = [self.galleryLayout.itemsInLayoutArray objectAtIndex:i];
    
        GalleryLayerItemViewController * itemViewController = [self.streamTemplate.layoutItemsArray objectAtIndex:i];
        
        if([item._id length] > 0)
        {
            itemViewController.indexInGalleryLayout = i;
            [itemViewController updateLikedState];
            itemViewController.comments_lbl.text = [NSString numberHandle:[item.commentsCount intValue]];
            itemViewController.title_lbl.text = item.title;
            
            if([item isArticle])
            {
                itemViewController.articleTitle.text= [item.title uppercaseString];
                
                itemViewController.articleDescription.text= item._description;
                itemViewController.title_lbl.text=@"";
            }else{
                itemViewController.articleTitle.text=@"";
                
                  itemViewController.articleDescription.text=@"";
            }
        }
    }
    
    //refresh image loading
    [self reloadImageContent:shouldStartLoading];
}

-(BOOL)needImageUpdate:(int)index{
    if (index<[self.streamTemplate.layoutItemsArray count]) {
        GalleryLayerItemViewController * it=[self.streamTemplate.layoutItemsArray objectAtIndex:index];
        
        return it.galleryImage.image==nil;
    
    }
    return NO;
}

-(void)cellImageUpade:(int)index withImage:(UIImage*)img{
 
    if (index<[self.streamTemplate.layoutItemsArray count]) {
        GalleryLayerItemViewController * it=[self.streamTemplate.layoutItemsArray objectAtIndex:index];
        
       [it setImage:img];
    }
}

-(void)itemThumnailPressed:(id)sender {
   int lastitem = (int)((UIButton*)sender).tag;

    [self fullScreenGalleryViewClickedForItemNumber:lastitem];
}

- (void)fullScreenGalleryViewClickedForItemNumber:(NSInteger)itemNumber
{
    GalleryItemDO * item = [[self.galleryLayout itemsInLayoutArray]objectAtIndex:itemNumber];
    
#ifdef USE_FLURRY
    
    if(ANALYTICS_ENABLED){
        NSArray * objs=[NSArray arrayWithObjects:item._id,[NSNumber numberWithInt:item.type],nil];
        NSArray * keys=[NSArray arrayWithObjects:@"designid",@"design_type", nil];
        
//        [HSFlurry logEvent:FLURRY_DESIGN_STREAM_ITEM_VIEW withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
    
#endif
    
    [self.galleryDelegate createFullScreenGalleryView:item._id  withOpenComment:NO];
}

- (UIViewController *)superViewController
{
    if ((self.galleryDelegate != nil) && ([self.galleryDelegate isKindOfClass:[UIViewController class]]))
    {
        UIViewController *vc = (UIViewController *) self.galleryDelegate;
        return vc;
    }
    
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark -
- (void) commentsPressed:(int)itemPos{
    if (self.galleryDelegate) {
    }
}

-(NSString*) getItemID:(int)itemPos{
    
    if (itemPos<[self.galleryLayout.itemsInLayoutArray count]) {
        GalleryItemDO* item=[self.galleryLayout.itemsInLayoutArray objectAtIndex:itemPos];
        return [item _id];
    }
    
   return @"";
}

-(int) getGalleryItemLikesCount:(int)itemPos{
    
    if (itemPos<[self.galleryLayout.itemsInLayoutArray count]) {
        GalleryItemDO* item=[self.galleryLayout.itemsInLayoutArray objectAtIndex:itemPos];
        return [item getLikesCountForDesign];
        
    }
    
    return 0;
}

#pragma mark - GalleryImagesDelegate
- (void)createFullScreenGalleryView: (NSString*)itemID  withOpenComment:(BOOL)commOpen{
    if (self.galleryDelegate) {
        [self.galleryDelegate createFullScreenGalleryView:itemID  withOpenComment:commOpen];
    }
}

- (void)createLayerViewController{
    if (self.galleryDelegate) {
        [self.galleryDelegate createLayerViewController];
    }
}

-(BOOL) isEmptyRoomsGalleryMode{
    return [self.galleryDelegate  isEmptyRoomsGalleryMode];
}

#pragma mark - GalleryStreamViewControllerDelegate

- (void)shareButtonPressedForDesign:(GalleryItemDO*)item withDesignImage:(UIImage *)designImage {
    if (self.galleryDelegate && [self.galleryDelegate respondsToSelector:@selector(shareButtonPressedForDesign:withDesignImage:)]) {
        [self.galleryDelegate shareButtonPressedForDesign:item withDesignImage:designImage];
    }
}

- (void)imageUploadStarted
{
    [self.galleryDelegate imageUploadStarted];
}

- (void)imageUploadFinished
{
    [self.galleryDelegate imageUploadFinished];
}

- (void)reloadImageContent:(BOOL)shouldReload {

    int localItems = [self getLayoutItemsCount];

    for (int i=0;i<localItems;i++){

        GalleryItemDO * item = [self.galleryLayout.itemsInLayoutArray objectAtIndex:i];

        GalleryLayerItemViewController*  itemViewController = [self.streamTemplate.layoutItemsArray objectAtIndex:i];

        if([item._id length]>0)
        {
             [itemViewController setItemWithLoadRequest:item shouldLoad:YES];

            //Set the title frame according to the new origin set in setItemWithLoadRequest
            itemViewController.title_lbl.frame = CGRectMake(itemViewController.title_lbl.frame.origin.x,
                                                            itemViewController.title_lbl.frame.origin.y,
                                                            itemViewController.bottom_bar_btnsView.frame.origin.x - itemViewController.title_lbl.frame.origin.x,
                                                            itemViewController.title_lbl.frame.size.height);
        }
    }
}

@end

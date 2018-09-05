//
//  StreamTemplateView.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import "StreamTemplateView.h"
#import "GalleryLayerItemViewController.h"
#import "LayoutRectDO.h"
#import "ControllersFactory.h"

@interface StreamTemplateView ()


@end

@implementation StreamTemplateView

-(void)dealloc{
    [self.layoutItemsArray removeAllObjects];
    self.layoutItemsArray = nil;
    self.galleryLayout = nil;
    
    NSLog(@"dealloc - StreamTemplateView");
}

-(void)initializeWithTemplate:(GalleryLayoutDO*)layout{
    
    float viewHeight = 0;
    
    self.galleryLayout = layout;
    
    if (!self.layoutItemsArray) {
        self.layoutItemsArray = [NSMutableArray array];
    }
    
    int localItems = (int)[self.galleryLayout.rects count];
    
    for (int i=0; i<localItems; i++) {
        
        GalleryLayerItemViewController*    itemViewController  =
        (GalleryLayerItemViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryLayerItemViewID" inStoryboard:kGalleryStoryboard];
        
        [self.layoutItemsArray addObject: itemViewController];
        
        LayoutRectDO * rect=[[self.galleryLayout rects] objectAtIndex:i];
        
        CGFloat persent=layout.height/100.0f;

//        int width = self.frame.size.width;
//        int height =(int)(self.bounds.size.width*persent);
        int width = 1024;
        int height =(int)(width*persent);
        
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
        
        itemViewController.view.frame = frame_rect;
        [itemViewController adjustSize];
        
        viewHeight += frame_rect.size.height;
        [self addSubview:itemViewController.view];
    }
    
    self.frame = CGRectMake(0, 0, 1024, viewHeight);
}

-(void)refreshWithDelegate:(id<GalleryStreamViewControllerDelegate,GalleryImagesDelegate>)newdeleg andLayout:(GalleryLayoutDO*)layout{
    
    [self clearImages];
    
    int localItems = (int)[self.layoutItemsArray count];
    
    for (int i=0; i<localItems; i++) {
        GalleryLayerItemViewController * itemViewController = [self.layoutItemsArray objectAtIndex:i];
        itemViewController.itemNumber = i;
        itemViewController.galleryLayerDelegate = newdeleg;
    }
}

-(void)clearImages{
    
    for (int i=0; i<[self.layoutItemsArray count]; i++) {
        GalleryLayerItemViewController*    itemViewController  = [self.layoutItemsArray objectAtIndex:i];
        
        [itemViewController clearImage];
    }
}

-(void)clearObservers
{
    for (int i=0; i<[self.layoutItemsArray count]; i++) {
        GalleryLayerItemViewController*    itemViewController  = [self.layoutItemsArray objectAtIndex:i];
        
        [itemViewController clearObservers];
    }
}

-(void)addObservers
{
    for (int i=0; i<[self.layoutItemsArray count]; i++) {
        GalleryLayerItemViewController*    itemViewController  = [self.layoutItemsArray objectAtIndex:i];
        
        [itemViewController addObservers];
    }
}

-(BOOL)isFitForLayout:(GalleryLayoutDO*)layout{
    
    if ([layout.rects count]==[self.galleryLayout.rects count]) {
        return YES;
    }
    return NO;
}

-(void)releaseReference
{    
    for (int i=0; i < [self.layoutItemsArray count]; i++) {
        GalleryLayerItemViewController * itemViewController = [self.layoutItemsArray objectAtIndex:i];
        itemViewController.galleryLayerDelegate = nil;
        [itemViewController clearObservers];
    }
}

-(BOOL)likesPressedWithResponseOK:(NSString*)designID
{
    BOOL bRetVal = NO;
    for (int i=0; i<[self.layoutItemsArray count]; i++) {
        GalleryLayerItemViewController*    itemViewController  = [self.layoutItemsArray objectAtIndex:i];
        
        bRetVal = [itemViewController likesPressedWithResponseOK:designID];
        if(bRetVal)
        {
            break;
        }
    }
    return bRetVal;
}
@end

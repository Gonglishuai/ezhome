//
//  EmptyRoomPopoverViewController.h
//  Homestyler
//
//  Created by xiefei on 14/5/18.
//

#import <UIKit/UIKit.h>
#import "GalleryItemBaseViewController.h"

@protocol EmptyRoomPopoverDelegate <NSObject>
-(void)startRedesignImages:(UIImage *)original background:(UIImage *)background mask:(UIImage *)mask needMask:(BOOL)needMask;
@end

@interface EmptyRoomPopoverViewController : GalleryItemBaseViewController
@property (nonatomic, weak) id<EmptyRoomPopoverDelegate> delegate;
@end

//
//  RetakePhotoBaseViewController.h
//  Homestyler
//
//  Created by Maayan Zalevas on 8/21/14.
//
//

#import <UIKit/UIKit.h>

@protocol RetakePhotoProtocol <NSObject>

- (void)retakePhotoRetakeRequested;
- (void)retakePhotoApproved;

@end

@interface RetakePhotoBaseViewController : UIViewController

@property (nonatomic, weak) id <RetakePhotoProtocol> delegate;
@property (nonatomic ,strong) UIImage * image;
@property BOOL allowZooming;


@end

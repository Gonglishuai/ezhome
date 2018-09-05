//
//  ImageOptionsViewController.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    IMAGE_OPTION_NONE = 0,
    IMAGE_OPTION_CONCEAL,
    IMAGE_OPTION_BRIGHTNESS
} ImageOptions;

///////////////////////////////////////////////////////
//                  PROTOCOL                         //
///////////////////////////////////////////////////////
/** Define the protocol for returning the user's choice to **/
/** the caller                                             **/
@protocol ImageOptionsDelegate <NSObject>
@required
- (void)chooseImageOption:(ImageOptions)imageOptionPicked;
@end


///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////
@interface ImageOptionsViewController : UIViewController

///////////////////// Properties //////////////////////
@property (strong, nonatomic) id delegate;

///////////////////// Outlets /////////////////////////
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *wallsButton;
@property (weak, nonatomic) IBOutlet UIButton *floorButton;
@property (strong, nonatomic) IBOutlet UIView *styleRoomView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

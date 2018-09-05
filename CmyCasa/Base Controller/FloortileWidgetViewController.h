//
//  FloortileWidgetViewController.h
//  Homestyler
//
//  Created by Avihay Assouline on 1/15/14.
//
//

#import <UIKit/UIKit.h>


///////////////////////////////////////////////////////
//                  DEFINES                          //
///////////////////////////////////////////////////////
#define SLIDER_ANGLE_START_DEGREE   (0.0f)
#define SLIDER_ANGLE_MAX_DEGREE     (30.0f)
#define SLIDER_ANGLE_MIN_DEGREE     (-30.0f)

#define SLIDER_WIDTH_START_VAL      (0.0f)
#define SLIDER_WIDTH_MAX_VAL        (30.0f)
#define SLIDER_WIDTH_MIN_VAL        (-30.0f)

#define SLIDER_HEIGHT_START_VAL      (0.0f)
#define SLIDER_HEIGHT_MAX_VAL        (30.0f)
#define SLIDER_HEIGHT_MIN_VAL        (-30.0f)

///////////////////////////////////////////////////////
//                  PROTOCOL                         //
///////////////////////////////////////////////////////
@protocol FloortileWidgetDelegate
-(void)floortileAngleChanged:(float)angle;
-(void)floortileWidthChanged:(float)angle;
-(void)floortileDepthChanged:(float)angle;
-(void)closeFloortileWidgetDialog;
@end


///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////
@interface FloortileWidgetViewController : UIViewController

@property id <FloortileWidgetDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UISlider *sliderAngle;
@property (weak, nonatomic) IBOutlet UISlider *sliderDepth;
@property (weak, nonatomic) IBOutlet UISlider *sliderWidth;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

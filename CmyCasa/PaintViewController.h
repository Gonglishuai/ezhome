//
//  PaintViewController.h
//  CmyCasa
//
//  Created by Or Sharir on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import "PaintBaseViewController.h"

@class HSNUIIconLabelButton;


@interface PaintViewController : PaintBaseViewController
@property (weak, nonatomic) IBOutlet UIButton *painFillButton;
@property (weak, nonatomic) IBOutlet UIButton *paintCurveButton;
@property (weak, nonatomic) IBOutlet UIButton *paintLineButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *paintActionPaintButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *paintActionRemoveButton;

- (IBAction)togglePaintDrawAction:(id)sender;
- (IBAction)togglePaintAction:(id)sender;
- (void) startedStrokeOnCanvasView:(RMCanvasView *)canvasView;
@end


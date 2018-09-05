//
//  UIPaintView.h
//  Homestyler
//
//  Created by Or Sharir on 7/9/13.
//
//

#import <UIKit/UIKit.h>
#import "UIPaintStep.h"
@protocol UIPaintViewDelegate;

typedef enum UIPaintViewMode {
    kUIPaintViewModeNone = 0,
    kUIPaintViewModeScribble = 1,
    kUIPaintViewModeLine = 2,
} UIPaintViewMode;


@interface UIPaintView : UIView
@property (weak, nonatomic) id<UIPaintViewDelegate> delegate;
@property (assign, nonatomic) CGFloat brushSize;
@property (strong, nonatomic) UIColor* brushColor;
@property (assign, nonatomic) UIPaintViewMode paintViewMode;
@property (strong, nonatomic) CAShapeLayer* drawLayer;
@property (strong, nonatomic) CALayer* displayLayer;
@property (strong, nonatomic) UIBezierPath* currentPath;
@property (strong, nonatomic) UIPanGestureRecognizer* recognizer;
@property CGContextRef currentDrawing;

- (void)clearPaint;
@end

@protocol UIPaintViewDelegate <NSObject>
- (void)painted:(UIPaintStep*)step endOfStroke:(BOOL)endOfStroke;
- (void) startedStrokeOnCanvasView:(UIPaintView *)canvasView;
- (void)tapped:(UIPaintView *)canvasView;
@end

//
//  UIPaintView.m
//  Homestyler
//
//  Created by Or Sharir on 7/9/13.
//
//

#import "UIPaintView.h"
#import <QuartzCore/QuartzCore.h>
#define kInpaintingBrushSize (50.0)

@interface UIPaintViewLayer : NSObject {
    __weak UIPaintView* _view;
}

-(instancetype)initWithPaintView:(UIPaintView*)view;
@end

@interface UIPaintView ()
@property (strong, nonatomic) UIPaintViewLayer* paintViewLayer;
@end

@implementation UIPaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentPath = [[UIBezierPath alloc] init];
        self.currentPath.lineCapStyle = kCGLineCapRound;
        self.currentPath.lineJoinStyle = kCGLineJoinRound;
        self.currentPath.miterLimit = 10;
       
        self.displayLayer = [[CALayer alloc] init];
        self.displayLayer.frame = self.bounds;
        
        self.paintViewLayer = [[UIPaintViewLayer alloc] initWithPaintView:self];
        self.displayLayer.delegate = self.paintViewLayer;
        [self.layer addSublayer:self.displayLayer];

        
        self.drawLayer = [CAShapeLayer layer];
        self.drawLayer.frame = self.bounds;
        self.drawLayer.fillColor = [[UIColor clearColor] CGColor];
        self.drawLayer.lineCap = kCALineCapRound;
        self.drawLayer.lineJoin = kCALineJoinRound;
        
        self.brushColor = [UIColor blackColor];
        self.brushSize = kInpaintingBrushSize;

        UIGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
    [self.displayLayer removeFromSuperlayer];
    self.displayLayer.delegate = nil;
    self.displayLayer = nil;
    self.drawLayer.path = nil;
    self.drawLayer = nil;
    self.currentPath = nil;
    if (self.currentDrawing)
    {
        CGContextRelease(self.currentDrawing);
        self.currentDrawing = NULL;
    }
}

CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     (int)kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease( colorSpace );
    return context;
}

- (void)setPaintViewMode:(UIPaintViewMode)paintViewMode {
    if (self.recognizer) [self removeGestureRecognizer:self.recognizer];
    switch (paintViewMode) {
        case kUIPaintViewModeScribble:
            self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scribbleRecognizer:)];
            self.recognizer.minimumNumberOfTouches = 1;
            self.recognizer.maximumNumberOfTouches = 1;
            break;
        case kUIPaintViewModeLine:
            self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(lineRecognizer:)];
            self.recognizer.minimumNumberOfTouches = 1;
            self.recognizer.maximumNumberOfTouches = 2;
            break;
        case kUIPaintViewModeNone:
        default:
            self.recognizer = nil;
            break;
    }
    if (self.recognizer) [self addGestureRecognizer:self.recognizer];
    _paintViewMode = paintViewMode;
}

- (void)setBrushColor:(UIColor *)brushColor {
    self.drawLayer.strokeColor = [brushColor CGColor];
    _brushColor = brushColor;
}

- (void)setBrushSize:(CGFloat)brushSize {
    self.drawLayer.lineWidth = brushSize;
    self.currentPath.lineWidth = brushSize;
    _brushSize = brushSize;
}

static int blocker = 0;

- (void)scribbleRecognizer:(UIPanGestureRecognizer*)recognizer {
    
    static CGPoint previousLocation;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"recognizer %ld",(long)recognizer.state);
        blocker = 1;
        //set starting point to current location also update previousLocation to starting point
        [self.currentPath moveToPoint:[recognizer locationInView:self]];
        previousLocation = [recognizer locationInView:self];
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged){
        NSLog(@"recognizer %ld",(long)recognizer.state);
        blocker = 2;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"recognizer %ld",(long)recognizer.state);
        if (blocker == 1) {
            [self.currentPath removeAllPoints];
            self.drawLayer.path = [self.currentPath CGPath];
            [self.displayLayer setNeedsDisplay];
            NSLog(@"recognizer error kill me :)");
            return;
        }
    }
        
    //get current location
    CGPoint p2 = [recognizer locationInView:self];
    CGPoint p1 = previousLocation;
    
    //add the new point to the path
    [self.currentPath addLineToPoint:p2];
    
    //update previousLocation
    previousLocation = [recognizer locationInView:self];
    
    //upate shape layer with the hole path
    self.drawLayer.path = [self.currentPath CGPath];
    
    // tell the screen to refresh it self
    [self.displayLayer setNeedsDisplay];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.currentPath removeAllPoints];
        self.drawLayer.path = [self.currentPath CGPath];
        [self.displayLayer setNeedsDisplay];
    }

    [self.delegate painted:[[UIPaintStep alloc] initWithColor:self.brushColor brushSize:self.brushSize start:p1 end:p2]
               endOfStroke:recognizer.state == UIGestureRecognizerStateEnded];
}

- (void)lineRecognizer:(UIPanGestureRecognizer*)recognizer {
    static CGPoint startPoint;
    static CGPoint endPoint;
    
    [self.currentPath removeAllPoints];
    CGPoint p1 = startPoint;
    CGPoint p2 = endPoint;
    CGRect r = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), MAX(p1.x, p2.x), MAX(p1.y, p2.y));
    [self.displayLayer setNeedsDisplayInRect:CGRectInset(r, -r.size.width, -r.size.height)];
    
    if (recognizer.numberOfTouches == 2) {
        startPoint = [recognizer locationOfTouch:0 inView:self];
        endPoint = [recognizer locationOfTouch:1 inView:self];
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate startedStrokeOnCanvasView:self];
        if (recognizer.numberOfTouches != 2) {
            startPoint = [recognizer locationInView:self];
            endPoint = startPoint;
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

    } else {
        if (recognizer.numberOfTouches != 2) {
            CGPoint temp = [recognizer locationInView:self];
            if (CGPointDistance(temp, startPoint) > CGPointDistance(temp, endPoint)) {
                endPoint = temp;
            } else {
                startPoint = temp;
            }
        }
    }
    
    [self.currentPath moveToPoint:startPoint];
    [self.currentPath addLineToPoint:endPoint];
    self.drawLayer.path = [self.currentPath CGPath];
    p1 = startPoint;
    p2 = endPoint;
    r = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), MAX(p1.x, p2.x), MAX(p1.y, p2.y));
    [self.displayLayer setNeedsDisplayInRect:CGRectInset(r, -r.size.width, -r.size.height)];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGContextSetBlendMode(self.currentDrawing, kCGBlendModeCopy);
        [self.drawLayer renderInContext:self.currentDrawing];
        [self.currentPath removeAllPoints];
        self.drawLayer.path = [self.currentPath CGPath];
        [self.displayLayer setNeedsDisplay];
        
        [self.delegate painted:[[UIPaintStep alloc] initWithColor:self.brushColor brushSize:self.brushSize start:startPoint end:endPoint] endOfStroke:YES];
        startPoint = CGPointZero;
        endPoint = CGPointZero;
    }
}

- (void)handleTap {
    // toggle display of bottom bar
    [self.delegate tapped:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.drawLayer.frame = [UIScreen currentScreenBoundsDependOnOrientation];
    self.displayLayer.frame = self.bounds;
    
    if (self.currentDrawing)
    {
        CGContextRelease(self.currentDrawing);
        self.currentDrawing = NULL;
    }
    
    self.currentDrawing = MyCreateBitmapContext(self.bounds.size.width, self.bounds.size.height);
}

- (void)clearPaint
{
    CGContextClearRect(self.currentDrawing, self.bounds);
    [self.displayLayer setNeedsDisplay];
}
@end

@implementation UIPaintViewLayer
-(instancetype)initWithPaintView:(UIPaintView*)view {
    if (self = [super init]) {
        _view = view;
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGImageRef temp = CGBitmapContextCreateImage(_view.currentDrawing);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextDrawImage(ctx, layer.bounds, temp);
    CGImageRelease(temp);
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    [_view.drawLayer renderInContext:ctx];
}
@end

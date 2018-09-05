//
//  RetakePhotoBaseViewController.m
//  Homestyler
//
//  Created by Maayan Zalevas on 8/21/14.
//
//

#import "RetakePhotoBaseViewController.h"
#import "UIImage+OpenCVWrapper.h"
#import "ESOrientationManager.h"

@interface RetakePhotoBaseViewController () <UIGestureRecognizerDelegate>
{
    CGRect rectOriginalImageViewFrame;
    
    CGFloat currentZoom;
    CGFloat minZoom;
    CGFloat maxZoom;
    
    CGFloat currentYValue;

    CGFloat minYValue;
    CGFloat maxYValue;
}

@property (nonatomic, weak) IBOutlet UIImageView *ivImage;

- (IBAction)buttonPressedRetake:(id)sender;
- (IBAction)buttonPressedNext:(id)sender;

@end

@implementation RetakePhotoBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ivImage.image = self.image;
    
    if (self.allowZooming)
    {
        [self setZoomGestureRecognizersAndVariables];
    }
    
    if (IS_IPHONE) {
        //开启横屏
        [ESOrientationManager setAllowRotation:YES];
    }
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    if (IS_IPHONE) {
//        //关闭横屏
//        [ESOrientationManager setAllowRotation:NO];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Public

- (void)setWithImage:(UIImage *)image
{
    self.image = image;
}

#pragma mark - Actions

- (IBAction)buttonPressedRetake:(id)sender
{
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(retakePhotoRetakeRequested)]))
    {
        [self.delegate retakePhotoRetakeRequested];
    }
}

- (IBAction)buttonPressedNext:(id)sender
{
    [self cropImageAccordingToZoom];

    if (self.delegate && ([self.delegate respondsToSelector:@selector(retakePhotoApproved)]))
    {
        [self.delegate retakePhotoApproved];
    }
}

#pragma mark - Image Cropping

- (void)cropImageAccordingToZoom
{
    SavedDesign *design = [[DesignsManager sharedInstance] workingDesign];
    UIImage *img = design.originalImage;
    if (img != nil)
    {
        //the percent (0-1) of the image that is not visible from top to start, and from end to bottom. There are only Y values since the full width of the image will always be visible.
        CGFloat percentStartCropY = (fabsf((float)self.ivImage.frame.origin.y) / self.ivImage.frame.size.height);
        CGFloat percentEndCropY = ((self.ivImage.frame.size.height - fabsf((float)self.ivImage.frame.origin.y) - self.view.frame.size.width) / self.ivImage.frame.size.height);
        
        //the rect that we should crop out of the original image. the scale is real image scale in pixels, meaning that if we should crop the whole image then the copRect variable will be exactly (0, 0, image.size.width, image.size.height).
        CGRect cropRect = CGRectMake(0,
                                     img.size.height * percentStartCropY,
                                     img.size.width,
                                     img.size.height - img.size.height * (percentStartCropY + percentEndCropY));
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
        
        UIImage *imgPortrait = [UIImage imageWithCGImage:imageRef
                                                   scale:img.scale
                                             orientation:img.imageOrientation];
        
        UIImage *imgLandscape = [imgPortrait transformPortraitToLandscape:[UIColor blackColor]
                                                             withMaxWidth:1024];
        
        design.image = imgLandscape;
        
        CGImageRelease(imageRef);
    }
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Gesture Recognizers

- (void)setZoomGestureRecognizersAndVariables
{
    CGFloat fImageScreenFactor = self.view.frame.size.width/self.image.size.height;
    CGFloat xVal = (self.view.frame.size.height - self.image.size.width*fImageScreenFactor)/2;
    CGFloat yVal = 0;
    CGFloat wVal = self.image.size.width*fImageScreenFactor;
    CGFloat hVal = self.image.size.height*fImageScreenFactor;
    
    self.ivImage.frame = CGRectMake(xVal, yVal, wVal, hVal);
    rectOriginalImageViewFrame = self.ivImage.frame;
    
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoomView:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    currentZoom = 1.0;
    minZoom = 1.0;
    maxZoom = self.view.frame.size.height / self.ivImage.frame.size.width;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (IS_IPAD)
                       {
                           [self scaleAndCenterImageViewFirstTimeIpad];
                       }
                       else
                       {
                           [self scaleAndCenterImageView];
                       }
                   });
    
    currentYValue = 0;
    minYValue = self.view.frame.size.width - self.ivImage.frame.size.height;
    maxYValue = 0;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panZoomView:)];
    pan.delegate = self;
    pan.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];
}

- (void)scaleAndCenterImageView
{
    CGFloat wVal = rectOriginalImageViewFrame.size.width * currentZoom;
    CGFloat hVal = rectOriginalImageViewFrame.size.height * currentZoom;
    CGFloat xVal = (self.view.frame.size.height - wVal) / 2;
    CGFloat yVal = self.ivImage.center.y;
    
    self.ivImage.frame = CGRectMake(xVal, self.ivImage.frame.origin.y, wVal, hVal);
    self.ivImage.center = CGPointMake(xVal, yVal);
    
    //normalize the y value to stay in the frame
    minYValue = self.view.frame.size.width - hVal;
    
    CGFloat nowYVal = self.ivImage.frame.origin.y;
    
    if (nowYVal > 0)
    {
        nowYVal = 0;
    }
    else if (nowYVal < minYValue)
    {
        nowYVal = minYValue;
    }
    
    self.ivImage.frame = CGRectMake(xVal, nowYVal, self.ivImage.frame.size.width, self.ivImage.frame.size.height);

    currentYValue = self.ivImage.frame.origin.y;
}

- (void)scaleAndCenterImageViewFirstTimeIpad
{
    CGFloat wVal = rectOriginalImageViewFrame.size.width * currentZoom;
    CGFloat hVal = rectOriginalImageViewFrame.size.height * currentZoom;
    CGFloat xVal = (self.view.frame.size.width - wVal) / 2;
    CGFloat yVal = (self.view.frame.size.height - hVal) / 2;
    
    self.ivImage.frame = CGRectMake(xVal, yVal, wVal, hVal);
}

- (void)pinchZoomView:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateFailed)
    {
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        recognizer.scale = currentZoom;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (recognizer.scale < minZoom)
        {
            recognizer.scale = minZoom;
        }
        else if (recognizer.scale > maxZoom)
        {
            recognizer.scale = maxZoom;
        }
        
        currentZoom = recognizer.scale;
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self scaleAndCenterImageView];
                       });
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
    }
    if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
    }
}

- (void)panZoomView:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateFailed)
    {
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    CGFloat tempVal = currentYValue + translatedPoint.y;
    if (tempVal < minYValue)
    {
        tempVal = minYValue;
    }
    else if (tempVal > maxYValue)
    {
        tempVal = maxYValue;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           self.ivImage.frame = CGRectMake(self.ivImage.frame.origin.x, tempVal, self.ivImage.frame.size.width, self.ivImage.frame.size.height);
                       });
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        currentYValue = tempVal;
    }
    if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
    }
}


@end

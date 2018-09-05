//
//  PaintSession.m
//  Homestyler
//
//  Created by Itamar Berger on 9/12/13.
//
//

#import "UIPaintSession.h"
#import "effects_composer.h"
#include "paint_session.h"
#include "ios_opencv_conversions.h"

PaintSession paintSession;
Scribble currScribble;


@interface UIPaintSession ()
{
    float scale;
    float offsetX;
    float offsetY;
    bool hasPredefinedMask;
}
@end


@implementation UIPaintSession

-(id)initWithImage:(UIImage*)image withScreenSize:(CGSize) size
{
    if (!image)
        return nil;
    
    if (self = [super init])
    {
        cv::Mat imageMat;
        ::UIImageToMat(image, imageMat, true, 3);
        
        bool status = paintSession.init(imageMat);
        if (!status) {
            NSLog(@"failed to init paint Session");
            self = nil;
            return self;
        }
        
        paintSession.setImageForAutoFill(imageMat);
        self.isPositive = YES;
        hasPredefinedMask = NO;
        [self updateScribbleTransformationForScreenSize:size withImageSize:image.size];

        return self;
    }
    
    return nil;
}

- (void)addPredefineMask:(UIImage*)mask
{
    cv::Mat masksMat;
    ::UIImageToMat(mask, masksMat, true, 3);
    
    paintSession.loadPredefinedMasks(masksMat);
    hasPredefinedMask = YES;
}

-(void)setColor:(UIColor *)color {
    if (color == _color) return;
    _color = color;
    if (color) {
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        int r = floor(red * 255);
        int g = floor(green * 255);
        int b = floor(blue * 255);
        if(paintSession.isReady())
            paintSession.updatePaintColor(cv::Scalar(r,g,b));
    }
}


-(void)setTexture:(UIImage *)texture
{
    if (texture == _texture)
        return;
    
    _texture = texture;
    
    if (texture)
    {
        cv::Mat wallPaperMat;
        ::UIImageToMat(texture, wallPaperMat, true);

        bool success =false;
        if(paintSession.isReady())
            success= paintSession.updateWallpaper(wallPaperMat);
        
        if (!success)
            HSMDebugLog(@"problems updating paint wallpaper");
    }
}

-(void)addScribble:(UIScribble*)scribble {
    currScribble.clear();
    
    for (ScribbleLinePart* step in scribble.line) {
        currScribble.push_back(cv::Point(scale * step.start.x  + offsetX,
                                         scale * step.start.y  + offsetY));
        currScribble.push_back(cv::Point(scale * step.end.x    + offsetX,
                                         scale * step.end.y    + offsetY));
    }
    
    ScribbleType type = self.isPositive ? POSITIVE : NEGATIVE;
    
    if ([scribble useSimple]) {
         if (paintSession.isReady())
         {
             paintSession.addManualScribble(currScribble, type, scribble.lineWidth);
         }
    } else{
        
        if (hasPredefinedMask)
        {
             if (paintSession.isReady()) {
                 paintSession.addPredefinedMaskScribble(currScribble, type);
             }
        }
        else
        {
            // increasing the line width above 5 for autofill will produce a very slow repsonse in the old api
            int lineWidth = 3;
            if (paintSession.isReady()) {
               paintSession.addAutoFillScribble(currScribble, type, lineWidth); 
            }
            
        }
    }
}

-(UIImage*)result
{
    if(!paintSession.isReady())
        return nil;
    
    cv::Mat paintedMat = paintSession.getPaintedImage();
    return MatToUIImage(paintedMat);
}

-(void) updateScribbleTransformationForScreenSize:(CGSize)screenSize withImageSize:(CGSize)imageSize
{   
    scale = 1;
    offsetX = 0;
    offsetY = 0;

    float screenSizeRatio = screenSize.width / screenSize.height;
    float imageSizeRatio = imageSize.width / imageSize.height;
    
    if (imageSizeRatio > screenSizeRatio) {
        scale = imageSize.height / screenSize.height;
        offsetX = (imageSize.width - screenSize.width * scale) / 2.0f;
    } else {
        scale = imageSize.width / screenSize.width;
        offsetY = (imageSize.height - screenSize.height * scale) / 2.0f;
    }
}

- (BOOL) gotAnythingToUndo {
     if(paintSession.isReady())
    return paintSession.gotAnythingToUndo();
    
    return NO;
}
- (BOOL) gotAnythingToRedo {
     if(paintSession.isReady())
         return paintSession.gotAnythingToRedo();
    
    
    return NO;
}

- (void) undo {
     if(paintSession.isReady())
         paintSession.undo();
}

- (void) redo {
     if(paintSession.isReady())
         paintSession.redo();
}

- (void) reset {
     if(paintSession.isReady())
         paintSession.reset();
}

- (void)setBrightness:(NSUInteger)brightness
{
    if (paintSession.isReady())
        paintSession.setBrightness((int)brightness);
}

- (void)setOpacity:(CGFloat)opacity
{
    if (paintSession.isReady())
        paintSession.setOpacity(opacity);
}

- (void)enableAmbientOcclusion:(float)maxDarkenColor kSize:(float)kSize sigma:(float)sigma
{
    if (paintSession.isReady())
        paintSession.enableAmbientOcclusion(maxDarkenColor, kSize, sigma);
}
- (void)disableAmbientOcclusion
{
    if (paintSession.isReady())
        paintSession.disableAmbientOcclusion();
}

+ (UIImage*)gammaCorrectImage:(UIImage*)image withGamma:(float)gamma
{
    if (!image)
        return nil;
    
    cv::Mat imageMat, result;
    ::UIImageToMat(image, imageMat, true, 3);
    EffectsComposer::gammaCorrection(imageMat, result, gamma);
    UIImage *myImg = ::MatToUIImage(result);
    
    return myImg;
}

@end

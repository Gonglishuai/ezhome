//
// Created by Berenson Sergei on 3/2/14.
// Copyright (c) 2014 SB Tech. All rights reserved.
//


#import "ConcealSessionWrapper.h"
#import "ios_opencv_conversions.h"

@interface ConcealSessionWrapper ()
{
    ConcealSession concealerSession;
    cv::Mat srcImg;
}

@property (nonatomic, strong)  UIImage * workingImage;
@property (nonatomic)  size_t patchSide;// = 70

@end

@implementation ConcealSessionWrapper

- (instancetype)initWithInitialImage:(UIImage *)image patchSideSize:(size_t)patchSize json3dCube:(NSData *)jsonStr {

    self = [super init];
    BOOL status = [self setupConcealWrapper:image patchSize:patchSize jsonStr:jsonStr];
  
    return (status)? self:nil;

}

- (BOOL)setupConcealWrapper:(UIImage *)image patchSize:(size_t)patchSize jsonStr:(NSData *)jsonStr
{
    self.workingImage = image;
    self.patchSide = patchSize;
    
    UIImageToMat(self.workingImage, srcImg,false);
    cvtColor(srcImg, srcImg,CV_RGBA2RGB);

    // Try to initialize the conceal session with an image. Failure can occur do to bad memory allocation
    BOOL status = concealerSession.init(srcImg, self.patchSide);
    if (!status)
        return NO;
    
    // Setup 3D mode if JSON string exists
    self.mode3dEnabled = NO;
    if (jsonStr)
    {
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonStr options:NSJSONReadingMutableContainers error:nil];
      self.mode3dEnabled = [self initWith3dJson:dict];
    }

    // Setup conceal parameters. If it fails then we continue (no stopping on these failures)
    concealerSession.setPatchTransferMode(MIXTURE_MODE);
    concealerSession.setPatchShape(SQUARE_PATCH);
    concealerSession.setPatchMode(PATCH_2D);
    //concealerSession.setSelectPatchProximityDistance(50.0);
    return  status;
}

-(BOOL)initWith3dJson:(NSDictionary *)pt
{
    float verticalFoVDeg =[[pt objectForKey:@"Vertical-FOV"] floatValue];

    cv::Matx33f R(3,3,CV_32FC1);
    int elem = 0;
    NSArray * pos = pt[@"Rotation-Matrix"];
    for (NSNumber * num in pos)
    {
        R.val[elem++] = [num floatValue];
    }
    
    std::vector<cv::Point3f> backwall3D(4);

    backwall3D[TOP_LEFT]     = cv::Point3f([[[pt objectForKey:@"Back-Wall-3D-Top-Left"] objectForKey:@"x"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Top-Left"] objectForKey:@"y"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Top-Left"] objectForKey:@"z"] floatValue]);
    backwall3D[TOP_RIGHT]    = cv::Point3f([[[pt objectForKey:@"Back-Wall-3D-Top-Right"] objectForKey:@"x"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Top-Right"] objectForKey:@"y"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Top-Right"] objectForKey:@"z"] floatValue]
                                          );
    backwall3D[BOTTOM_RIGHT] = cv::Point3f([[[pt objectForKey:@"Back-Wall-3D-Bot-Right"] objectForKey:@"x"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Bot-Right"] objectForKey:@"y"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Bot-Right"] objectForKey:@"z"] floatValue]
                                           );
    backwall3D[BOTTOM_LEFT]  = cv::Point3f([[[pt objectForKey:@"Back-Wall-3D-Bot-Left"] objectForKey:@"x"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Bot-Left"] objectForKey:@"y"] floatValue],
                                           [[[pt objectForKey:@"Back-Wall-3D-Bot-Left"] objectForKey:@"z"] floatValue]
                                           );

    return   concealerSession.init3D(R, verticalFoVDeg, backwall3D);
}

- (void)startConcealWork {

}

- (void)stopConcealWork {

}

- (size_t)getPatchSideSize {
   
    return self.patchSide;
}

- (void)setPatchSizeSize:(size_t)patchSize
{
    self.patchSide = patchSize;
    concealerSession.setPatchSideSize(self.patchSide);
}

- (BOOL)moveSelectedPatchTo:(CGPoint)patchTouch
{
    cv::Point pt(patchTouch.x,patchTouch.y);

   return  concealerSession.moveSelectedPatchTo(pt);
}

- (void)selectPatch:(CGPoint)touchPatch
{
    cv::Point pt(touchPatch.x,touchPatch.y);
    concealerSession.selectPatch(pt);
}

- (WhichPatch)getCurrentPatch{
    return concealerSession.getSelectedPatch();

}

- (void)draw
{
}

- (UIImage *)redraw
{
    cv::Mat  img = srcImg.clone();
    concealerSession.conceal(srcImg, img);
    return MatToUIImage(img);
}

- (void)updateSourceImageForConcealer:(UIImage*)image
{
    self.workingImage = image;
    UIImageToMat(self.workingImage, srcImg,false);
    cvtColor(srcImg, srcImg,CV_RGBA2RGB);
    concealerSession.updateSrcImg(srcImg);
}

- (UIImage *)applyChangeToSrcImage {
    cv::Mat  img = srcImg.clone();

    concealerSession.conceal(srcImg, img);
    concealerSession.updateSrcImg(img);
    srcImg = img;
    return MatToUIImage(img);

}

- (UIImage*)getSourceImage
{
    cv::Mat  img = srcImg.clone();
    return MatToUIImage(img);

}

- (CGPoint)getCenterOfPatchType:(WhichPatch)patchType {

    cv::Point2f p =  concealerSession.getPatchCenterPoint(patchType);

    return CGPointMake(p.x,p.y);
}

- (PatchTransferMode)getCurrentPatchTransferMode {

    return concealerSession.getPatchTransferMode();

}

- (PatchMode)getCurrentPatchMode {

    return concealerSession.getPatchMode();

}

- (PatchShape)getCurrentPatchShape{

    return concealerSession.getPatchShape();

}

- (Boolean)setPatchMode :(PatchMode)mode{

   return  concealerSession.setPatchMode(mode);

}

- (void)setPatchTransferMode:(PatchTransferMode)newmode {

   concealerSession.setPatchTransferMode(newmode);

}

- (void)setPatchShape:(PatchShape)newmode {

   concealerSession.setPatchShape(newmode);

}

- (void)setSelectPatchProximityDistance:(float)patchProximityDistance
{
    concealerSession.setSelectPatchProximityDistance(patchProximityDistance);
}



- (NSArray*)getPatchCorners:(WhichPatch)patchOption withShrinkSize:(int)size
{
   if (NO_PATCH == patchOption)
      return @[];

    Quad2f quad = concealerSession.getPatchCorners(patchOption);
    
    if (size!=0) {
        concealerSession.getShrunkenPatchCorners(patchOption,size,quad);
    }
    
    return [NSArray arrayWithObjects:
            [NSValue valueWithCGPoint:CGPointMake(quad[0].x, quad[0].y)],
            [NSValue valueWithCGPoint:CGPointMake(quad[1].x, quad[1].y)],
            [NSValue valueWithCGPoint:CGPointMake(quad[2].x, quad[2].y)],
            [NSValue valueWithCGPoint:CGPointMake(quad[3].x, quad[3].y)],
            nil];
}

- (void)selectSpecificPatch:(WhichPatch)patch {

    concealerSession.selectPatch(patch);
}

#pragma  mark -
- (void)nudgeWithPoint:(CGPoint)point
{

    cv::Point pt(point.x,point.y);
    concealerSession.nudgeSelectedPatch(pt);

}
@end





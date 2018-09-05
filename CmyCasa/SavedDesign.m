
//
//  SavedDesign.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "SavedDesign.h"
#import "CubeViewController.h"
#import "UIImage+EXIF.h"
#import "NSArray+Vertex.h"
#import "SaveDesignResponse.h"
#import "ImageFetcher.h"
#import "ImageBackgroundEffectsViewController.h"

#define arrayFloat(object, index) [(NSNumber*)[object objectAtIndex:index] floatValue]
#define dictFloat(object, key) [(NSNumber*)[object objectForKey:key] floatValue]
#define BIASED_SIGN(x) (x >= 0 ? 1 : -1)
#define SIGN(x) (x == 0 ? 0 : (x > 0 ? 1 : -1))

NSString* const SavedDesignKeyCameraAlignEnableKey = @"camera_rotation_aligned";
NSString* const SavedDesignKeyServerKey = @"sid";
NSString* const SavedDesignKeyUniqueID = @"localUniqueID";
NSString* const SavedDesignKeySceneName = @"sceneName";
NSString* const SavedDesignKeyVersion = @"version";
NSString* const SavedDesignKeyGlobalScale = @"globalScale";
NSString* const SavedDesignKeyHorizonalFOV = @"cameraXFOV";
NSString* const SavedDesignKeyVerticalFOV= @"cameraYFOV";
NSString* const SavedDesignKeyScreenSize = @"imageSize";
NSString* const SavedDesignKeyScreenSizeWidth = @"Width";
NSString* const SavedDesignKeyScreenSizeHeight = @"Height";
NSString* const SavedDesignKeyMatrix = @"matrix";
NSString* const SavedDesignKeyModels = @"models";
NSString* const SavedDesignKeyTimestamp = @"timeStamp";
NSString* const SavedDesignKeyOrientation = @"orientation";
NSString* const SavedDesingKeyCubeVerts = @"cube";
NSString* const SavedDesingKeyParent = @"o";
NSString* const SavedDesingKeyScaleLock = @"scaleLock";
NSString* const SavedDesingKeyBGBrightness = @"bgBrightness";

@interface SavedDesign ()
@property (nonatomic, readwrite) SavedDesignStatus status;
@property (nonatomic) BOOL supportConcealAPI;
@end

@implementation SavedDesign

@synthesize originalImage;
@synthesize maskImage;
@synthesize parentID;
@synthesize CubeVerts;
@synthesize GyroData;
@synthesize UniqueID;
@synthesize GlobalScale;
@synthesize designID;
@synthesize designDescription;
@synthesize designRoomType;

+(SavedDesign*) initWithImage:(UIImage*)image
                imageMetadata:(NSDictionary*)metadata
               devicePosition:(SavedGyroData*)devicePosition
          originalOrientation:(UIImageOrientation)o
{
    SavedDesign* ret = [[SavedDesign alloc] init];
    if (ret)
    {
        ret.saveReminder=[[SaveReminderItem alloc] init];
        ret.dirty = YES;
        ret.image = image;
        ret.originalImage = image;
        ret.isScaleLockFoundInData=YES;
        ret.isScalingLocked=YES;
        
        // Initialize Camera
        ret.camera = [[SimpleCamera alloc] init];
        [ret.camera setupWithRotationMatrixAndGravity:devicePosition.gyroRotationMatrix gravity:devicePosition.gravity];
        ret.GyroData = devicePosition;
        
        ret.GlobalScale = 1; // Default is 1 unit = 1 meter
        ret.Orientation = o;
        ret.UniqueID = [[ServerUtils sharedInstance] generateGuid];
        ret.FocalLengthIn35mmFilm = [UIImage focalLengthIn35mmFilmFromMetadata:metadata];
        ret.date = [NSDate date];
        UIImage* t = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:ret.Orientation];
        ret.originalImageSize = t.size;
        ret.bgBrightness = IMAGE_BACKGROUND_DEFAULT_VALUE;
        ret.status = SAVED_DESIGN_STATUS_NEW;
    }
    return ret;
}


-(NSArray*)CubeVerts {
    return CubeVerts;
}

-(void)setCubeVerts:(NSArray *)newCubeVerts {
    CubeVerts = newCubeVerts;
    [self fixCube];
}

-(GLKVector3)getVectorForVertex:(NSUInteger)index {
	return GLKVector3Make([(NSNumber*)[CubeVerts objectAtIndex:index*COORDS + X] floatValue], [(NSNumber*)[CubeVerts objectAtIndex:index*COORDS + Y] floatValue], [(NSNumber*)[CubeVerts objectAtIndex:index*COORDS + Z] floatValue]);
}

-(void)fixCube {
	if (CubeVerts == nil || CubeVerts.count != 24)
        return;
    
	GLKVector3 ftl = [self getVectorForVertex:4];
	GLKVector3 ftr = [self getVectorForVertex:5];
	GLKVector3 fbr = [self getVectorForVertex:6];
	GLKVector3 fbl = [self getVectorForVertex:7];
    
    //  enforce that the cube is parralel to (0,0,1) (1,0,0) (0,1,0) plane
	ftr.y = ftl.y;
	fbr.y = fbl.y;
	ftl.x = fbl.x;
	ftl.z = fbl.z;
	ftr.x = fbr.x;
	ftr.z = fbr.z;
    
	GLKVector3 n = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(fbr, fbl), GLKVector3Subtract(ftl, fbl)));
    float maxDepth = MAX(fabs(fbl.z), fabs(fbr.z));
    n = GLKVector3MultiplyScalar(n, MAX(maxDepth, CUBE_DEPTH));
	GLKVector3 ntl = GLKVector3Add(ftl, n);
	GLKVector3 ntr = GLKVector3Add(ftr, n);
	GLKVector3 nbl = GLKVector3Add(fbl, n);
	GLKVector3 nbr = GLKVector3Add(fbr, n);
	
	CubeVerts = @[@(ntl.x), @(ntl.y), @(ntl.z),
	@(ntr.x), @(ntr.y), @(ntr.z),
	@(nbr.x), @(nbr.y), @(nbr.z),
	@(nbl.x), @(nbl.y), @(nbl.z),
	@(ftl.x), @(ftl.y), @(ftl.z),
	@(ftr.x), @(ftr.y), @(ftr.z),
	@(fbr.x), @(fbr.y), @(fbr.z),
	@(fbl.x), @(fbl.y), @(fbl.z)];
}

- (void)generateUniqueuId {
   self.UniqueID = [[ServerUtils sharedInstance] generateGuid];
}

- (NSComparisonResult)compare:(SavedDesign *)otherObject {
    return [self.name compare:otherObject.name];
}

// Initialization of a saved design following 3D analysis operation
+(SavedDesign*) initWithParams:(UIImage*)image
              ImageOrientation:(UIImageOrientation)orientation
                          JSON:(NSDictionary*)jsonData
{
    SavedDesign* ret = [[SavedDesign alloc] init];
    ret.camera = [[SimpleCamera alloc] init];
    if (ret == nil) return nil;
    
    //new version starting from 1.9.0 supports aligned rotation camera matrix and allows concealAPI
    ret.supportConcealAPI = YES;
    ret.saveReminder = [[SaveReminderItem alloc] init];
    ret.dirty = YES;
    ret.isScalingLocked=YES;
    ret.isScaleLockFoundInData=YES;
    ret.image = image;
    ret.originalImage = image;
    ret.Orientation = orientation;
    ret.GlobalScale = 1; // Default is 1 unit = 1 meter
    ret.bgBrightness = IMAGE_BACKGROUND_DEFAULT_VALUE;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationUp:
            ret.camera.fovVertical = [[jsonData objectForKey:@"Vertical-FOV"] floatValue];
            break;
        case UIImageOrientationRight:
        case UIImageOrientationLeft:
            ret.camera.fovVertical = [[jsonData objectForKey:@"Horizontal-FOV"] floatValue];
        default:
            break;
    }
    
    NSArray* rotArr = [jsonData objectForKey:@"Rotation-Matrix"];
    GLKMatrix3 mat = GLKMatrix3Make(arrayFloat(rotArr,0), arrayFloat(rotArr,1), arrayFloat(rotArr,2),
                                    arrayFloat(rotArr,3), arrayFloat(rotArr,4), arrayFloat(rotArr,5),
                                    arrayFloat(rotArr,6), arrayFloat(rotArr,7), arrayFloat(rotArr,8));
    
    ret.GyroData = [[SavedGyroData alloc] initWithRotationMatrix:mat withModMatrix:GLKMatrix4MakeRotation(M_PI_2, 0, 0, 1)];
    [ret.camera setupWithRotationMatrixAndGravity:ret.GyroData.gyroRotationMatrix gravity:ret.GyroData.gravity];
    
    GLKMatrix3 fixRotation = [ret.camera headingMatrix];
    
    NSDictionary* topLeft = [jsonData objectForKey:@"Back-Wall-3D-Top-Left"];
    NSDictionary* topRight = [jsonData objectForKey:@"Back-Wall-3D-Top-Right"];
    NSDictionary* bottomLeft = [jsonData objectForKey:@"Back-Wall-3D-Bot-Left"];
    NSDictionary* bottomRight = [jsonData objectForKey:@"Back-Wall-3D-Bot-Right"];
    
    GLKMatrix3 flipX = GLKMatrix3Make(-1, 0, 0,
                                      0, 1, 0,
                                      0, 0, 1);
    
    GLKMatrix3 fixScale = GLKMatrix3MakeScale(CAMERA_DEFAULT_HEIGHT, CAMERA_DEFAULT_HEIGHT, CAMERA_DEFAULT_HEIGHT);
    GLKMatrix3 fix = GLKMatrix3Multiply(fixScale, GLKMatrix3Multiply(fixRotation, flipX));
    
    // Read and apply fixes to Cube
    GLKVector3 tl = GLKVector3Make(dictFloat(topLeft, @"x"), dictFloat(topLeft, @"y")+1, dictFloat(topLeft, @"z"));
    GLKVector3 tr = GLKVector3Make(dictFloat(topRight, @"x"), dictFloat(topRight, @"y")+1, dictFloat(topRight, @"z"));
    GLKVector3 bl = GLKVector3Make(dictFloat(bottomLeft, @"x"), dictFloat(bottomLeft, @"y")+1, dictFloat(bottomLeft, @"z"));
    GLKVector3 br = GLKVector3Make(dictFloat(bottomRight, @"x"), dictFloat(bottomRight, @"y")+1, dictFloat(bottomRight, @"z"));
    
    tl = GLKMatrix3MultiplyVector3(fix, tl);
    tr = GLKMatrix3MultiplyVector3(fix, tr);
    bl = GLKMatrix3MultiplyVector3(fix, bl);
    br = GLKMatrix3MultiplyVector3(fix, br);
    
    float maxDepth = MAX(abs((int)bl.z), abs((int)br.z));
    GLKVector3 back = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(tr, br), GLKVector3Subtract(bl, br)));
    back = GLKVector3MultiplyScalar(back, MAX(maxDepth, CUBE_DEPTH));
    GLKVector3 ntl = GLKVector3Add(tl, back);
    GLKVector3 ntr = GLKVector3Add(tr, back);
    GLKVector3 nbl = GLKVector3Add(bl, back);
    GLKVector3 nbr = GLKVector3Add(br, back);
    NSArray* cubeVerts = @[ @(ntl.x), @(ntl.y), @(ntl.z),
                            @(ntr.x), @(ntr.y), @(ntr.z),
                            @(nbr.x), @(nbr.y), @(nbr.z),
                            @(nbl.x), @(nbl.y), @(nbl.z),
                            @(tl.x),  @(tl.y),  @(tl.z),
                            @(tr.x),  @(tr.y),  @(tr.z),
                            @(br.x),  @(br.y),  @(br.z),
                            @(bl.x),  @(bl.y),  @(bl.z)];
    
    ret.CubeVerts = cubeVerts;
    
    ret.UniqueID = [[ServerUtils sharedInstance] generateGuid];
    ret.date = [NSDate date];
    UIImage* t = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:orientation];
    ret.originalImageSize = t.size;
    
    return ret;
}

+(SavedDesign*)designWithJSONDictionary:(NSDictionary*)jsonData
{
    HSMDebugLog(@"j:%@", jsonData);
    SavedDesign* ret = [[SavedDesign alloc] init];
    
    if (ret)
    {
        ret.camera = [[SimpleCamera alloc] init];
        if (jsonData[SavedDesingKeyScaleLock]) {
            ret.isScalingLocked=[jsonData[SavedDesingKeyScaleLock] boolValue];
            ret.isScaleLockFoundInData=YES;
        }else{
            ret.isScaleLockFoundInData=NO;
            ret.isScalingLocked=NO;
        }
        
        ret.supportConcealAPI = (jsonData[SavedDesignKeyCameraAlignEnableKey]) ? [jsonData[SavedDesignKeyCameraAlignEnableKey] boolValue]: NO;
        ret.saveReminder = [[SaveReminderItem alloc] init];
        ret.FormatVersion = [NSString stringWithFormat:@"%@", jsonData[SavedDesignKeyVersion]];
        ret.ServerKey = jsonData[SavedDesignKeyServerKey];
        ret.UniqueID = jsonData[SavedDesignKeyUniqueID];
        if (ret.UniqueID == nil) {
            if (ret.ServerKey != nil) {
                ret.UniqueID = [NSString stringWithFormat:@"%@", ret.ServerKey];
            } else {
                ret.UniqueID = [[ServerUtils sharedInstance] generateGuid];
            }
        }
        ret.name = jsonData[SavedDesignKeySceneName];
        ret.parentID = jsonData[SavedDesingKeyParent];
        ret.GlobalScale = [jsonData[SavedDesignKeyGlobalScale] floatValue];
       
        if (ret.GlobalScale <= 0)
            ret.GlobalScale = 1;
        
        ret.camera.fovVertical = [jsonData[SavedDesignKeyVerticalFOV] floatValue];
        
        if (ret.camera.fovVertical <= 0)
        {
            ret.camera.fovVertical = CAMERA_DEFAULT_VFOV;
        }

        if (jsonData[SavedDesignKeyOrientation] == nil) {
            ret.Orientation = 2;//UIImageOrientationLeft;
        } else {
            ret.Orientation = [jsonData[SavedDesignKeyOrientation] integerValue];
        }
        
        NSArray* matrixArr = jsonData[SavedDesignKeyMatrix];
        float matrix[16];
        for (int i = 0; i < 16; i++) {
            matrix[i] = [[matrixArr objectAtIndex:i] floatValue];
        }
        
        ret.GyroData = [[SavedGyroData alloc] initWithCameraMatrix:GLKMatrix3Make(matrix[0], matrix[1], matrix[2],
                                                                                  matrix[4], matrix[5], matrix[6],
                                                                                  matrix[8], matrix[9], matrix[10])];
        
        
        [ret.camera setupWithRotationMatrixAndGravity:ret.GyroData.gyroRotationMatrix gravity:ret.GyroData.gravity];
        
        
        ret.Orientation = [ret.GyroData imageOrientation];
        
        NSArray* verts = jsonData[SavedDesingKeyCubeVerts];
        if (verts != nil) {
            GLKVector3 upperLeft, upperRight, lowerRight, lowerLeft;
            upperLeft = GLKVector3Make([verts[0][@"x"] floatValue], [verts[0][@"y"] floatValue], [verts[0][@"z"] floatValue]);
            upperRight = GLKVector3Make([verts[1][@"x"] floatValue], [verts[1][@"y"] floatValue], [verts[1][@"z"] floatValue]);
            lowerRight = GLKVector3Make([verts[2][@"x"] floatValue], [verts[2][@"y"] floatValue], [verts[2][@"z"] floatValue]);
            lowerLeft = GLKVector3Make([verts[3][@"x"] floatValue], [verts[3][@"y"] floatValue], [verts[3][@"z"] floatValue]);
            
            GLKVector3 back = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(lowerLeft, upperLeft), GLKVector3Subtract(upperRight, upperLeft)));
            float maxDepth = MAX(fabs(lowerRight.z), fabs(lowerLeft.z));
            back = GLKVector3MultiplyScalar(back, MAX(maxDepth, CUBE_DEPTH));
            GLKVector3 backUpperLeft, backUpperRight, backLowerRight, backLowerLeft;
            backUpperLeft = GLKVector3Add(upperLeft, back);
            backUpperRight = GLKVector3Add(upperRight, back);
            backLowerRight = GLKVector3Add(lowerRight, back);
            backLowerLeft = GLKVector3Add(lowerLeft, back);
            
            NSArray* tempCube = @[@(backUpperLeft.x), @(backUpperLeft.y), @(backUpperLeft.z),
                              @(backUpperRight.x), @(backUpperRight.y), @(backUpperRight.z),
                              @(backLowerRight.x), @(backLowerRight.y), @(backLowerRight.z),
                              @(backLowerLeft.x), @(backLowerLeft.y), @(backLowerLeft.z),
                              @(upperLeft.x), @(upperLeft.y), @(upperLeft.z),
                              @(upperRight.x), @(upperRight.y), @(upperRight.z),
                              @(lowerRight.x), @(lowerRight.y), @(lowerRight.z),
                              @(lowerLeft.x), @(lowerLeft.y), @(lowerLeft.z),
            ];
            ret.CubeVerts = [tempCube copy];
        }
        NSArray* jsonModels = jsonData[SavedDesignKeyModels];
        NSMutableArray* models = [[NSMutableArray alloc] initWithCapacity:jsonModels.count];
        for (NSDictionary* jsonEntity in jsonModels) {
            [models addObject:[Entity entityWithJsonDictionary:jsonEntity]];
        }
        
        ret.models = [NSMutableArray arrayWithArray:models];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm"];
        ret.date = [dateFormatter dateFromString:jsonData[SavedDesignKeyTimestamp]];
        ret.originalImageSize = CGSizeMake([jsonData[SavedDesignKeyScreenSize][SavedDesignKeyScreenSizeWidth] floatValue], [jsonData[SavedDesignKeyScreenSize][SavedDesignKeyScreenSizeHeight] floatValue]);
        if (ret.originalImageSize.height > ret.originalImageSize.width) {
            ret.originalImageSize = CGSizeMake(ret.originalImageSize.height, ret.originalImageSize.width);
        }
        
        // Retrieve the background brightness level if it exist. Otherwise, put the default value
        ret.bgBrightness = IMAGE_BACKGROUND_DEFAULT_VALUE;
        if (jsonData[SavedDesingKeyBGBrightness]) {
            ret.bgBrightness = [jsonData[SavedDesingKeyBGBrightness] floatValue];
        }

    }
    return ret;
}

- (GLKMatrix3)convertRotationMatrixTo3DAnalysisFormat:(GLKMatrix3)rotMatrix withModMatrix:(GLKMatrix4)modMatrix
{
    GLKMatrix3 flipX = GLKMatrix3Make(-1, 0, 0,
                                      0, 1, 0,
                                      0, 0, 1);
    
    GLKMatrix4 invModMatrix = GLKMatrix4MakeRotation(-M_PI_2, 0, 0, 1);
    
    GLKMatrix3 newRotMatrix = GLKMatrix3Multiply(flipX, rotMatrix);
    newRotMatrix = GLKMatrix3Multiply(newRotMatrix, GLKMatrix4GetMatrix3(invModMatrix));
    newRotMatrix = GLKMatrix3Multiply(newRotMatrix, flipX);
    
    // Conceal API is currently supporting the new version of the 3D Analysis JSON format.
    // therefore we invert the first and last row of the matrix until the new API will be deployed
    return GLKMatrix3Make(-newRotMatrix.m00, -newRotMatrix.m01, -newRotMatrix.m02,
                          newRotMatrix.m10, newRotMatrix.m11, newRotMatrix.m12,
                          -newRotMatrix.m20, -newRotMatrix.m21, -newRotMatrix.m22);
    
}

- (GLKVector3)convertVectorTo3DAnalysisFormat:(GLKVector3)v
{
    GLKMatrix3 flipX = GLKMatrix3Make(-1, 0, 0,
                                      0, 1, 0,
                                      0, 0, 1);
    
    GLKMatrix3 invFixRotation = GLKMatrix3Transpose([self.camera headingMatrix]);
    GLKMatrix3 invFixScale = GLKMatrix3MakeScale(1/CAMERA_DEFAULT_HEIGHT, 1/CAMERA_DEFAULT_HEIGHT, 1/CAMERA_DEFAULT_HEIGHT);
    GLKMatrix3 invfix = GLKMatrix3Multiply(flipX, GLKMatrix3Multiply(invFixRotation, invFixScale));
    
    GLKVector3 new_v = GLKMatrix3MultiplyVector3(invfix, v);
    return GLKVector3Make(new_v.x, new_v.y - 1, new_v.z);
}

- (NSDictionary*)jsonData
{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    @try
    {
   
    if (self.UniqueID == nil)
    {
        self.UniqueID = [[ServerUtils sharedInstance] generateGuid];
    }
        
    data[SavedDesignKeyCameraAlignEnableKey] = [NSNumber numberWithBool:self.supportConcealAPI];
        
    data[SavedDesignKeyUniqueID] = self.UniqueID;
    
    data[SavedDesingKeyScaleLock]=[NSNumber numberWithBool:self.isScalingLocked];
    if (self.ServerKey != nil) data[SavedDesignKeyServerKey] = self.ServerKey;
        data[SavedDesignKeySceneName] = (self.name) ? self.name : @"";
    if(self.parentID && ![self.parentID isEqualToString:self.designID] )
    {
        data[SavedDesingKeyParent] = self.parentID;
    }
    if (self.FormatVersion) {
        data[SavedDesignKeyVersion] = self.FormatVersion;
    } else {
        data[SavedDesignKeyVersion] = DESIGN_VERSION;
    }
        
    data[SavedDesignKeyGlobalScale] = @(self.GlobalScale);
    data[SavedDesingKeyBGBrightness] = @(self.bgBrightness);
    data[SavedDesignKeyVerticalFOV] = @(self.camera.fovVertical);
    data[SavedDesignKeyHorizonalFOV] = @([self.camera horizonalFOV:(self.originalImageSize.width / self.originalImageSize.height)]);
    data[SavedDesignKeyOrientation] = @(self.Orientation);
    data[SavedDesignKeyScreenSize] = @{SavedDesignKeyScreenSizeWidth : @(self.originalImageSize.width), SavedDesignKeyScreenSizeHeight: @(self.originalImageSize.height)};
    if (self.camera != nil)
    {
        GLKMatrix3 matrix = GLKMatrix3Transpose([self.camera rotationMatrix]);
        
        data[SavedDesignKeyMatrix] = @[@(matrix.m00), @(matrix.m01), @(matrix.m02), @0,
        @(matrix.m10), @(matrix.m11), @(matrix.m12), @0,
        @(matrix.m20), @(matrix.m21), @(matrix.m22), @0,
        @0, @0, @0, @1];
    }
    else
    {
        HSMDebugLog(@"WTF?");
    }
    data[SavedDesignKeyModels] = [[NSMutableArray alloc] initWithCapacity:self.models.count];
    for (Entity* entity in self.models) {
        [data[SavedDesignKeyModels]   addObject:[entity jsonData]];
    }


    if (self.date == nil) self.date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm"];
    data[SavedDesignKeyTimestamp] = [dateFormatter stringFromDate:self.date];
    
    if (self.CubeVerts)
    {
        NSDictionary* upperLeft, *upperRight, *lowerLeft, *lowerRight;
        upperLeft = [self.CubeVerts getDictionaryForVertex:4];
        upperRight = [self.CubeVerts getDictionaryForVertex:5];
        lowerRight = [self.CubeVerts getDictionaryForVertex:6];
        lowerLeft = [self.CubeVerts getDictionaryForVertex:7];
        data[SavedDesingKeyCubeVerts] = @[upperLeft, upperRight, lowerRight, lowerLeft];
    }
    
    }
    @catch (NSException *exception)
    {
        HSMDebugLog(@"SaveDesign Exception: %@", exception);
        data = nil;
        
    }

    return data;
}

- (void)updateCachedImage:(SaveDesignResponse *)saveUrls
{
    ImageFetcher * fetcher=[ImageFetcher sharedInstance];
    NSValue *valSize;
    if(IS_IPAD)
        valSize = [NSValue valueWithCGSize:CGSizeMake(1024, 768)];
    else
        valSize = [NSValue valueWithCGSize:CGSizeMake(1024, 768)];

    //Background image without furniture
    NSDictionary *background=@{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL : (saveUrls.urlBack) ? saveUrls.urlBack:@"",
                               IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                               IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM};
    
    NSData *backData = UIImagePNGRepresentation(self.image);
    [fetcher storeImage:self.image withData:backData andUrlInfo:background];

    
    //Original image without any changes
    NSDictionary *original=@{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL : (saveUrls.urlInitial) ? saveUrls.urlInitial:@"",
                             IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                             IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM};

    NSData *originalData = UIImagePNGRepresentation(self.originalImage);
    [fetcher storeImage:self.originalImage withData:originalData andUrlInfo:original];


    //Final Image after redesigning + coloring + forniture.
    NSDictionary *final = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL : (saveUrls.urlFinal) ? saveUrls.urlFinal:@"",
                            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM};

    NSData *finalData = UIImagePNGRepresentation(self.ImageWithFurnitures);
    [fetcher storeImage:self.ImageWithFurnitures withData:finalData andUrlInfo:final];


    if(self.maskImage && saveUrls.urlMask)
    {
        //Masking  image if exists
        NSDictionary * mask=@{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL : (saveUrls.urlMask) ? saveUrls.urlMask:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM};

        NSData * maskData = UIImagePNGRepresentation(self.maskImage);
        [fetcher storeImage:self.maskImage withData:maskData andUrlInfo:mask];
    }
}

+(SavedDesign*) designWithJSONString:(NSString*)jsonString {
    
    NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    return [SavedDesign designWithJSONDictionary:jsonData];
}

-(NSString*)jsonString
{
    NSString* retVal = @"";
    if([self jsonData] ){
        NSData * data = [NSJSONSerialization dataWithJSONObject:[self jsonData] options:0 error:NULL];
        
        if (data) {
         retVal =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
    }
    return retVal;
}

- (float)oldFOVForScreenSize:(CGSize)screenSize {
    float newFov;
    // The case where when the height of the image fits the screen, and the original width overflow the screen edges    
    
    if (screenSize.width/screenSize.height <= self.originalImageSize.width / self.originalImageSize.height) {
        newFov =  GLKMathRadiansToDegrees(2*atanf(((screenSize.width / screenSize.height)/(self.originalImageSize.width / self.originalImageSize.height))*tanf(GLKMathDegreesToRadians(self.camera.fovVertical / 2))));
    } else { // The opposite case where the width is the same as the screen and the height overflow the screen edges
        newFov = GLKMathRadiansToDegrees(2*atanf(((screenSize.height / screenSize.width)/(self.originalImageSize.height / self.originalImageSize.width))*tanf(GLKMathDegreesToRadians(self.camera.fovVertical / 2))));  
    }
    return newFov;
}

-(float)fovForScreenSize:(CGSize)screenSize {
    //CGSize temp = screenSize;
    //screenSize = CGSizeMake(temp.height, temp.width);
    float newFov;
    // The case where when the height of the image fits the screen, and the original width overflow the screen edges
    
    if (screenSize.width / screenSize.height < 1) {
        float tmp = screenSize.width;
        screenSize.width = screenSize.height;
        screenSize.height = tmp;
    }
    
    if (screenSize.width/screenSize.height <= self.originalImageSize.width / self.originalImageSize.height) {
        newFov = self.camera.fovVertical;
    } else {
        newFov = GLKMathRadiansToDegrees(2*atanf(((screenSize.height / screenSize.width)/(self.originalImageSize.height / self.originalImageSize.width))*tanf(GLKMathDegreesToRadians(self.camera.fovVertical / 2))));
    }
    
//    NSString * version=[NSString stringWithFormat:@"%@",(self.FormatVersion!=nil)?self.FormatVersion:DESIGN_VERSION];
//    
//    if (screenSize.width/screenSize.height <= self.originalImageSize.width / self.originalImageSize.height) {
//        if ([version compare:@"1.1" options:NSCaseInsensitiveSearch] != NSOrderedDescending) {
//            if (4.0/3.0 <= self.originalImageSize.width / self.originalImageSize.height) {
//                newFov = GLKMathRadiansToDegrees(2*atanf(((4.0/3.0)/(self.originalImageSize.width / self.originalImageSize.height))*tanf(GLKMathDegreesToRadians(self.camera.fovVertical / 2))));
//            } else {
//                newFov = self.camera.fovVertical;
//            }
//        } else {
//            newFov = self.camera.fovVertical;
//        }
//    } else { // The opposite case where the width is the same as the screen and the height overflow the screen edges
//        if ([version compare:@"1.1" options:NSCaseInsensitiveSearch] != NSOrderedDescending) {
//            if (4.0/3.0 <= self.originalImageSize.width / self.originalImageSize.height) {
//                newFov = GLKMathRadiansToDegrees(2*atanf(((4.0/3.0)/(self.originalImageSize.width / self.originalImageSize.height))*tanf(GLKMathDegreesToRadians(self.camera.fovVertical / 2))));
//            } else {
//                newFov = self.camera.fovVertical;
//            }
////            newFov = GLKMathRadiansToDegrees(2*atanf(((screenSize.height / screenSize.width)/(self.originalImageSize.height / self.originalImageSize.width))*tanf(GLKMathDegreesToRadians(newFov / 2)))); 
//        } else {
//            newFov = GLKMathRadiansToDegrees(2*atanf(((screenSize.height / screenSize.width)/(self.originalImageSize.height / self.originalImageSize.width))*tanf(GLKMathDegreesToRadians(self.camera.fovVertical / 2))));
//        }
//    }
    return newFov;
}

-(void)setMaskImage:(UIImage *)mskImage{
    maskImage=mskImage;
}

-(UIImage*)maskImage{
    return maskImage;
}

-(void)setParentID:(NSString *)arentID{
    //NSLog(@"SAVED DESIGN PARENT ID :%@",arentID);
    parentID = arentID;
}

-(BOOL)isEntityScaled:(Entity*)entity{
    
   if( fabs((1/self.GlobalScale)-entity.scale.x)<0.0001)
       return NO;
    
    return YES;
}

-(BOOL)isAnyEntityWasScalled{  
    for (int i=0; i<[self.models count]; i++) {
        Entity * ent=[self.models objectAtIndex:i];
        if ([self isEntityScaled:ent]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)changeScaleLock:(BOOL)lock{
    self.isScalingLocked=lock;
}

-(void)updateLockingStateAccordingToDesignType:(int)sourceType{
    
    //set locking state
    if ([self isScaleLockFoundInData]==NO) {
        
        switch (sourceType) {
            case eFScreenUserDesigns:
            {
                BOOL isScaled = [self isAnyEntityWasScalled];
                [self changeScaleLock:!isScaled];
            }
                break;
            case eFScreenEmptyRooms:
                [self changeScaleLock:YES];
                break;
                
            case eFScreenGalleryStream:
            {
                BOOL isScaled = [self isAnyEntityWasScalled];
                [self changeScaleLock:!isScaled];
            }
                
                break;
            default:
                [self changeScaleLock:YES];
                break;
        }
    }
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToDesign:other];
}

- (BOOL)isEqualToDesign:(SavedDesign *)design {
    if (self == design)
        return YES;
    if (design == nil)
        return NO;
    if (self.saveReminder != design.saveReminder && ![self.saveReminder isEqual:design.saveReminder])
        return NO;
    if (self.ImageWithFurnitures != design.ImageWithFurnitures && ![self.ImageWithFurnitures isEqual:design.ImageWithFurnitures])
        return NO;
    if (self.FormatVersion != design.FormatVersion && ![self.FormatVersion isEqualToString:design.FormatVersion])
        return NO;
    if (self.Orientation != design.Orientation)
        return NO;
    if (self.ServerKey != design.ServerKey && ![self.ServerKey isEqualToNumber:design.ServerKey])
        return NO;
    if (self.date != design.date && ![self.date isEqualToDate:design.date])
        return NO;
    if (self.FocalLengthIn35mmFilm != design.FocalLengthIn35mmFilm && ![self.FocalLengthIn35mmFilm isEqualToNumber:design.FocalLengthIn35mmFilm])
        return NO;
    if (self.dirty != design.dirty)
        return NO;
    if (self.mustSaveAsNewDesign != design.mustSaveAsNewDesign)
        return NO;
    if (self.originalImageSize.width != design.originalImageSize.width)
        return NO;
    if (self.originalImageSize.height != design.originalImageSize.height)
        return NO;
    if (self.isScaleLockFoundInData != design.isScaleLockFoundInData)
        return NO;
    if (self.isScalingLocked != design.isScalingLocked)
        return NO;
    if (self.image != design.image && ![self.image isEqual:design.image])
        return NO;
    if (self.originalImage != design.originalImage && ![self.originalImage isEqual:design.originalImage])
        return NO;
    if (self.maskImage != design.maskImage && ![self.maskImage isEqual:design.maskImage])
        return NO;
    if (self.name != design.name && ![self.name isEqualToString:design.name])
        return NO;
    if (self.parentID != design.parentID && ![self.parentID isEqualToString:design.parentID])
        return NO;
    if (self.CubeVerts != design.CubeVerts && ![self.CubeVerts isEqualToArray:design.CubeVerts])
        return NO;
    if (self.GyroData != design.GyroData && ![self.GyroData isEqual:design.GyroData])
        return NO;
    if (self.UniqueID != design.UniqueID && ![self.UniqueID isEqualToString:design.UniqueID])
        return NO;
    if (self.GlobalScale != design.GlobalScale)
        return NO;
    if (![self.camera isEqual:design.camera])
        return NO;
    if (self.designID != design.designID && ![self.designID isEqualToString:design.designID])
        return NO;
    if (self.designDescription != design.designDescription && ![self.designDescription isEqualToString:design.designDescription])
        return NO;
    if (self.designRoomType != design.designRoomType && ![self.designRoomType isEqualToString:design.designRoomType])
        return NO;
    if (self.publicDesignID != design.publicDesignID && ![self.publicDesignID isEqualToString:design.publicDesignID])
        return NO;
    if (self.autoSaveUniqueID != design.autoSaveUniqueID && ![self.autoSaveUniqueID isEqualToString:design.autoSaveUniqueID])
        return NO;


    return YES;
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.saveReminder = [coder decodeObjectForKey:@"self.saveReminder"];
        self.FormatVersion = [coder decodeObjectForKey:@"self.FormatVersion"];
        self.Orientation = (UIImageOrientation) [coder decodeIntForKey:@"self.Orientation"];
        self.ServerKey = [coder decodeObjectForKey:@"self.ServerKey"];
        self.date = [coder decodeObjectForKey:@"self.date"];
        self.FocalLengthIn35mmFilm = [coder decodeObjectForKey:@"self.FocalLengthIn35mmFilm"];
        self.dirty = [coder decodeBoolForKey:@"self.dirty"];
        self.mustSaveAsNewDesign = [coder decodeBoolForKey:@"self.mustSaveAsNewDesign"];
        self.originalImageSize = [coder decodeCGSizeForKey:@"self.originalImageSize"];
        self.isScaleLockFoundInData = [coder decodeBoolForKey:@"self.isScaleLockFoundInData"];
        self.isScalingLocked = [coder decodeBoolForKey:@"self.isScalingLocked"];
        self.status = [coder decodeIntForKey:@"self.status"];
        self.name = [coder decodeObjectForKey:@"self.name"];
        self.parentID = [coder decodeObjectForKey:@"self.parentID"];
        self.CubeVerts = [coder decodeObjectForKey:@"self.CubeVerts"];
        self.GyroData = [coder decodeObjectForKey:@"self.GyroData"];
        self.UniqueID = [coder decodeObjectForKey:@"self.UniqueID"];
        self.models = [coder decodeObjectForKey:@"self.models"];
        self.GlobalScale = [coder decodeFloatForKey:@"self.GlobalScale"];
        self.camera = [coder decodeObjectForKey:@"self.camera"];
        self.designID = [coder decodeObjectForKey:@"self.designID"];
        self.designDescription = [coder decodeObjectForKey:@"self.designDescription"];
        self.designRoomType = [coder decodeObjectForKey:@"self.designRoomType"];
        self.publicDesignID = [coder decodeObjectForKey:@"self.publicDesignID"];
        self.autoSaveUniqueID = [coder decodeObjectForKey:@"self.autoSaveUniqueID"];
        self.autosaveDate = [coder decodeObjectForKey:@"self.autosaveDate"];
        self.previewImageData = [coder decodeObjectForKey:@"self.ImageWithFurnituresData"];
        self.ImageData = [coder decodeObjectForKey:@"self.ImageData"];
        self.originalImageData =  [coder decodeObjectForKey:@"self.originalImageData"];
        self.maskImageData = [coder decodeObjectForKey:@"self.maskImageData"];
        self.supportConcealAPI = [coder decodeBoolForKey:@"self.supportConcealAPI"];
        self.bgBrightness = [coder decodeFloatForKey:@"self.bgBrightness"];
        self.isPublic = [coder decodeBoolForKey:@"self.isPublic"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.saveReminder forKey:@"self.saveReminder"];
   
    [coder encodeObject:self.FormatVersion forKey:@"self.FormatVersion"];
    [coder encodeInt:self.Orientation forKey:@"self.Orientation"];
    [coder encodeObject:self.ServerKey forKey:@"self.ServerKey"];
    [coder encodeObject:self.date forKey:@"self.date"];
    [coder encodeObject:self.FocalLengthIn35mmFilm forKey:@"self.FocalLengthIn35mmFilm"];
    [coder encodeBool:self.dirty forKey:@"self.dirty"];
    [coder encodeBool:self.mustSaveAsNewDesign forKey:@"self.mustSaveAsNewDesign"];
    [coder encodeCGSize:self.originalImageSize forKey:@"self.originalImageSize"];
    [coder encodeBool:self.isScaleLockFoundInData forKey:@"self.isScaleLockFoundInData"];
    [coder encodeBool:self.isScalingLocked forKey:@"self.isScalingLocked"];
    [coder encodeInt:self.status forKey:@"self.status"];
    [coder encodeObject:self.name forKey:@"self.name"];
    [coder encodeObject:self.parentID forKey:@"self.parentID"];
    [coder encodeObject:[self.CubeVerts copy] forKey:@"self.CubeVerts"];
    [coder encodeObject:self.GyroData forKey:@"self.GyroData"];
    [coder encodeObject:self.UniqueID forKey:@"self.UniqueID"];
    [coder encodeObject:[self.models copy] forKey:@"self.models"];
    [coder encodeFloat:self.GlobalScale forKey:@"self.GlobalScale"];
    [coder encodeObject:self.camera forKey:@"self.camera"];
    [coder encodeObject:self.designID forKey:@"self.designID"];
    [coder encodeObject:self.designDescription forKey:@"self.designDescription"];
    [coder encodeObject:self.designRoomType forKey:@"self.designRoomType"];
    [coder encodeObject:self.publicDesignID forKey:@"self.publicDesignID"];
    [coder encodeObject:self.autoSaveUniqueID forKey:@"self.autoSaveUniqueID"];
    [coder encodeObject:self.autosaveDate forKey:@"self.autosaveDate"];
    [coder encodeBool:self.isPublic forKey:@"self.isPublic"];

    if(self.previewImageData && !self.ImageWithFurnitures)
        self.ImageWithFurnitures = [UIImage imageWithData:self.previewImageData];
    
    if (self.ImageData && !self.image)
        self.image = [UIImage imageWithData:self.ImageData];
    
    if (self.originalImageData && !self.originalImage)
        self.originalImage = [UIImage imageWithData:self.originalImageData];
    
    if(self.maskImageData && !self.maskImageData)
        self.maskImage = [UIImage imageWithData:self.maskImageData];
    
    [coder encodeObject:UIImagePNGRepresentation(self.ImageWithFurnitures) forKey:@"self.ImageWithFurnituresData"];
    [coder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"self.ImageData"];
    [coder encodeObject:UIImagePNGRepresentation(self.originalImage) forKey:@"self.originalImageData"];
    [coder encodeObject:UIImagePNGRepresentation(self.maskImage) forKey:@"self.maskImageData"];
    [coder encodeBool:self.supportConcealAPI forKey:@"self.supportConcealAPI"];
    [coder encodeFloat:self.bgBrightness forKey:@"self.bgBrightness"];
}

- (id)copyWithZone:(NSZone *)zone {
    SavedDesign *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.saveReminder = [self.saveReminder copy];
        copy.ImageWithFurnitures = [self.ImageWithFurnitures copy];
        copy.FormatVersion = [self.FormatVersion copy];
        copy.Orientation = self.Orientation;
        copy.ServerKey = [self.ServerKey copy];
        copy.date = [self.date copy];
        copy.FocalLengthIn35mmFilm = [self.FocalLengthIn35mmFilm copy];
        copy.dirty = self.dirty;
        copy.mustSaveAsNewDesign = self.mustSaveAsNewDesign;
        copy.originalImageSize = self.originalImageSize;
        copy.isScaleLockFoundInData = self.isScaleLockFoundInData;
        copy.isScalingLocked = self.isScalingLocked;
        copy.status = self.status;
        copy.image = [self.image copy];
        copy.originalImage = [self.originalImage copy];
        copy.maskImage = [self.maskImage copy];
        copy.name = [self.name copy];
        copy.parentID = [self.parentID copy];
        copy.CubeVerts = [self.CubeVerts copy];
        copy.GyroData = [self.GyroData copy];
        copy.UniqueID = [self.UniqueID copy];
        copy.models = [self.models copyWithZone:zone];
        copy.GlobalScale = self.GlobalScale;
        copy.camera = [self.camera copy];
        copy.designID = [self.designID copy];
        copy.designDescription = [self.designDescription copy];
        copy.designRoomType = [self.designRoomType copy];
        copy.publicDesignID = [self.publicDesignID copy];
        copy.autoSaveUniqueID = [self.autoSaveUniqueID copy];
        copy.autosaveDate = [self.autosaveDate copy];
        copy.ImageData = [self.ImageData copy];
        copy.previewImageData = [self.previewImageData copy];
        copy.maskImageData = [self.maskImageData copy];
        copy.originalImageData = [self.originalImageData copy];
        copy.supportConcealAPI = self.supportConcealAPI;
        copy.bgBrightness = self.bgBrightness;
        copy.isPublic = self.isPublic;
    }

    return copy;
}

- (void)loadPreviewImageOnlyIntoUIImage
{
    if (self.ImageData)
        self.image = [UIImage imageWithData:self.ImageData];
}

-(void)loadDataIntoUIImagesForAutosaves
{
    if(self.previewImageData)
        self.ImageWithFurnitures = [UIImage imageWithData:self.previewImageData];
    
    if (self.ImageData)
        self.image = [UIImage imageWithData:self.ImageData];
    
    if (self.originalImageData)
        self.originalImage = [UIImage imageWithData:self.originalImageData];
    if(self.maskImageData)
        self.maskImage = [UIImage imageWithData:self.maskImageData];
}

#pragma mark - Generate Json for Conceal
- (NSData*)generateConcealRepresentationJSON
{
    
    if (self.camera != nil)
    {
        //rotation matrix
        NSMutableDictionary * jsonDict = [NSMutableDictionary new];
        
        GLKMatrix3 prevMat = [self convertRotationMatrixTo3DAnalysisFormat:[self.camera rotationMatrix] withModMatrix:GLKMatrix4Identity];
    
        [jsonDict setObject:@[ [NSNumber numberWithFloat:prevMat.m[0]],
                               [NSNumber numberWithFloat:prevMat.m[1]],
                               [NSNumber numberWithFloat:prevMat.m[2]],
                               [NSNumber numberWithFloat:prevMat.m[3]],
                               [NSNumber numberWithFloat:prevMat.m[4]],
                               [NSNumber numberWithFloat:prevMat.m[5]],
                               [NSNumber numberWithFloat:prevMat.m[6]],
                               [NSNumber numberWithFloat:prevMat.m[7]],
                               [NSNumber numberWithFloat:prevMat.m[8]]
                               ] forKey:@"Rotation-Matrix"];
        
        if (self.CubeVerts)
        {
            NSDictionary* upperLeft, *upperRight, *lowerLeft, *lowerRight;
            upperLeft = [self.CubeVerts getDictionaryForVertex:4];
            upperRight = [self.CubeVerts getDictionaryForVertex:5];
            lowerRight = [self.CubeVerts getDictionaryForVertex:6];
            lowerLeft = [self.CubeVerts getDictionaryForVertex:7];
             
            GLKVector3 prevTopLeft =[self convertVectorTo3DAnalysisFormat:[self.CubeVerts getVectorForVertex:4]];
          //  NSLog(@"Back-Wall-3D-Top-Left : { x : %f, y : %f, z : %f }", prevTopLeft.x, prevTopLeft.y, prevTopLeft.z);
            
            GLKVector3 prevTopRight =[self convertVectorTo3DAnalysisFormat:[self.CubeVerts getVectorForVertex:5]];
          //  NSLog(@"Back-Wall-3D-Top-Right : { x : %f, y : %f, z : %f }", prevTopRight.x, prevTopRight.y, prevTopRight.z);
            
            GLKVector3 prevBottomRight =[self convertVectorTo3DAnalysisFormat:[self.CubeVerts getVectorForVertex:6]];
          //  NSLog(@"Back-Wall-3D-Bottom-Right : { x : %f, y : %f, z : %f }", prevBottomRight.x, prevBottomRight.y, prevBottomRight.z);
            
            GLKVector3 prevBottomLeft =[self convertVectorTo3DAnalysisFormat:[self.CubeVerts getVectorForVertex:7]];
           // NSLog(@"Back-Wall-3D-Bottom-Left : { x : %f, y : %f, z : %f }", prevBottomLeft.x, prevBottomLeft.y, prevBottomLeft.z);
            
            [jsonDict setObject:@{@"x":[NSNumber numberWithFloat:prevTopLeft.x],
                                  @"y":[NSNumber numberWithFloat:prevTopLeft.y],
                                  @"z":[NSNumber numberWithFloat:prevTopLeft.z]} forKey:@"Back-Wall-3D-Top-Left"];
            
            
            [jsonDict setObject:@{@"x":[NSNumber numberWithFloat:prevTopRight.x],
                                  @"y":[NSNumber numberWithFloat:prevTopRight.y],
                                  @"z":[NSNumber numberWithFloat:prevTopRight.z]} forKey:@"Back-Wall-3D-Top-Right"];
          
            
            [jsonDict setObject:@{@"x":[NSNumber numberWithFloat:prevBottomRight.x],
                                  @"y":[NSNumber numberWithFloat:prevBottomRight.y],
                                  @"z":[NSNumber numberWithFloat:prevBottomRight.z]} forKey:@"Back-Wall-3D-Bot-Right"];
          
            
            [jsonDict setObject:@{@"x":[NSNumber numberWithFloat:prevBottomLeft.x],
                                  @"y":[NSNumber numberWithFloat:prevBottomLeft.y],
                                  @"z":[NSNumber numberWithFloat:prevBottomLeft.z]} forKey:@"Back-Wall-3D-Bot-Left"];
          
            
            
            [jsonDict setObject:[NSNumber numberWithFloat:self.camera.fovVertical] forKey:@"Vertical-FOV"];
            
           //[jsonDict set
            NSData * data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
            
            return data;
        }
        return nil;
    }
    return nil;
}

- (BOOL)supportsFullConcealAPI
{
    return self.supportConcealAPI;
}

@end






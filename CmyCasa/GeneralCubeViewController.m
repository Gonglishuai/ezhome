//
//  CubeViewController.m
//  CmyCasa


#import "GeneralCubeViewController.h"
#import "UIImage+Scale.h"
#import "UIImage+fixOrientation.h"
#import "AppDelegate.h"
#import "MathMacros.h"

#define EPSILON (0.0001f)
#define WALL_SPEED_FACTOR (60.0f)
#define SURFACE_FACES (4)


#define WALL_NONE_MASK      (0x0)
#define WALL_FRONT_MASK     (0x1 << 0)
#define WALL_FLOOR_MASK     (0x1 << 1)
#define WALL_RIGHT_MASK     (0x1 << 2)
#define WALL_LEFT_MASK      (0x1 << 3)
#define WALL_CEILING_MASK   (0x1 << 4)
#define WALL_ALL_MASK       (WALL_FRONT_MASK | WALL_FLOOR_MASK | WALL_RIGHT_MASK | WALL_LEFT_MASK | WALL_CEILING_MASK)



static const GLubyte surfaceXY[3 * 4] = {
    4, 6, 5,
    7, 6, 4,

    0, 1, 2,
    0, 2, 3,
};

static const GLfloat surfaceTexCoordsXY[2 * 8] = {
    0, 0,
    1, 0,
    1, 1,
    0, 1,
    0, 0,
    1, 0,
    1, 1,
    0, 1,
};

static GLfloat scaledSurfaceTexCoordsXY[2 * 8] = {
    0, 0,
    1, 0,
    1, 1,
    0, 1,
    0, 0,
    1, 0,
    1, 1,
    0, 1,
};

static const GLubyte surfaceFloorIdx[3 * 2] = {
    7, 3, 2, // Triangle with base at depth (base is far)
    2, 6, 7 // Triangle with base at origin (base is near)
};

static const GLubyte surfaceCeilingIdx[3 * 2] = {
    4, 0, 1,
    1, 5, 4
};

static const GLubyte surfaceFrontIdx[3 * 2] = {
    4, 6, 5,
    7, 6, 4
};

static const GLubyte surfaceLeftIdx[3 * 4] = {
    0, 7, 4,
    0, 3, 7
};

static const GLubyte surfaceRightIdx[3 * 4] = {
    5, 6, 2,
    2, 1, 5
};


static const GLubyte surfaceXZ[3 * 4] = {    
    // Ceiling vertex indices
    4, 0, 1,
    1, 5, 4,
    
    // Floor vertex indices
    7, 3, 2, // Triangle with base at depth (base is far)
    2, 6, 7, // Triangle with base at origin (base is near)
};

static GLfloat surfaceTexCoordsXZ[2 * 8] = {
    0, 1, // 0 Ceiling
    1, 1, // 1 Ceiling
    
    0, 1, // 2 Floor
    1, 1, // 3 Floor
    
    0, 0, // 4 Ceiling
    1, 0, // 5 Ceiling
    
    0, 0, // 6 Floor
    1, 0, // 7 Floor
};

static GLfloat scaledSurfaceTexCoordsXZ[2 * 8] = {
    0, 1, // 0 Ceiling
    1, 1, // 1 Ceiling
    
    0, 1, // 2 Floor
    1, 1, // 3 Floor
    
    0, 0, // 4 Ceiling
    1, 0, // 5 Ceiling
    
    0, 0, // 6 Floor
    1, 0, // 7 Floor
};

static GLfloat cubeVertsXZ[CUBE_VERTS*COORDS];


static const GLubyte surfaceZY[3 * 4] = {
    0, 7, 4,
    0, 3, 7,
    
    5, 6, 2,
    2, 1, 5,
};

static const GLfloat surfaceTexCoordsZY[2 * 8] = {
    0, 0,
    1, 0,
    1, 1,
    0, 1,
    1, 0,
    0, 0,
    0, 1,
    1, 1,
};

static GLfloat scaledSurfaceTexCoordsZY[2 * 8] = {
    0, 0,
    1, 0,
    1, 1,
    0, 1,
    1, 0,
    0, 0,
    0, 1,
    1, 1,
};


// wireframe of the cube
static const GLubyte wireframe[] = {
	0,1,
	1,2,
	2,3,
	3,0,
	
	4,5,
	5,6,
	6,7,
	7,4,
	
	0,4,
	1,5,
	2,6,
	3,7,
};

static const GLubyte surfaceXZFloorOnly[3 * 2] = {
    // Floor vertex indices
    7, 3, 2, // Triangle with base at depth (base is far)
    2, 6, 7 // Triangle with base at origin (base is base)
};

@interface GeneralCubeViewController ()
@property WallSide currentWallside;
@property (strong, nonatomic) GLKTextureInfo* wireframeTex;
@end

@implementation GeneralCubeViewController
@synthesize wireframeHidden;

static int activeScribbleWallMasks = WALL_NONE_MASK;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    self.cubeTextureScale = 1;
    self.useMipmapping = YES;
    self.wallsTransparency = 1;
    self.currentWallside = WallNone;
    
    self.wireframeHidden = YES;
    if (self.textureImage == nil) {
        self.textureImage = [UIImage imageNamed:@"wall_grid"];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshGLView];
}

-(void)dealloc {
    NSLog(@"dealloc - GeneralCubeViewController");
    self.wireframeTex = nil;
}

-(void)refreshGLView{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[appDelegate glkView] removeFromSuperview];
    [self.view addSubview:[appDelegate glkView]];
    [appDelegate glkView].delegate = self;
    [appDelegate glkVC].delegate = self;
    [appDelegate glkView].frame = self.view.bounds;
    [appDelegate setDrawableMultisample];
    [self.view sendSubviewToBack:[appDelegate glkView]];
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    self.floorWidthDelta = 0.0;
    self.floorHeightDelta = 0.0;
    
    [self setupSceneFromCurrentDesign];
}

- (void)setWallSide:(WallSide)side;
{
    self.currentWallside = side;
}

- (void)setTextureImage:(UIImage *)textureImage
{
    if (textureImage == _textureImage)
        return;
    
    self.wireframeTex = nil;
    _textureImage = textureImage;
    
    if (_textureImage)
    {
        NSDictionary* textureOptions = @{GLKTextureLoaderGenerateMipmaps: [NSNumber numberWithBool:self.useMipmapping],
                                         GLKTextureLoaderApplyPremultiplication: @YES};
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        if (sem != NULL)
        {
            @autoreleasepool
            {
                [[appDelegate textureLoader] textureWithContentsOfData:UIImagePNGRepresentation(textureImage)
                                                               options:textureOptions
                                                                 queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                     completionHandler:^(GLKTextureInfo *textureInfo, NSError *outError)
                                                                        {
                                                                            self.wireframeTex = textureInfo;
                                                                            //NSLog(@"tex name: %d", textureInfo.name);
                                                                            dispatch_semaphore_signal(sem);
                                                                        }];
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            }
        }
    }
}

- (void)setWireframeTex:(GLKTextureInfo *)wireframeTex {
    if (_wireframeTex && (wireframeTex == nil || wireframeTex.name != _wireframeTex.name)) {
        GLuint name = _wireframeTex.name;
        glDeleteTextures(1, &name);
        _wireframeTex = nil;
    }
    _wireframeTex = wireframeTex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupSceneFromCurrentDesign {
    if (self.currentDesign == nil) {
        return;
    }
    
    self.gyroData = self.currentDesign.GyroData;
	self.camera.fovVertical = [self.currentDesign fovForScreenSize:self.view.bounds.size];
    self.worldScale = [self.currentDesign GlobalScale];
    [self reloadCube];
}

-(void)reloadCube {
    if (self.currentDesign.CubeVerts && self.currentDesign.CubeVerts.count == CUBE_VERTS * COORDS) {
		self.wireframeHidden = self.cubeWallsHidden = NO;
        self.cubeNSArray = self.currentDesign.CubeVerts;
	} else {
        self.wireframeHidden = self.cubeWallsHidden = YES;
    }
}

void rotateCoordinate(float x, float y, float *new_x, float *new_y, float angle)
{
    float temp_x = x * cos(angle) - y * sin(angle);
    float temp_y = x * sin(angle) + y * cos(angle);
    *new_x = temp_x;
    *new_y = temp_y;
}

-(void)buildSurfaceXZ
{
    memcpy (&cubeVertsXZ, &cubeVerts, sizeof(cubeVerts));
    
    GLKVector3 diag = GLKVector3Subtract([self getVectorForVertex:7], [self getVectorForVertex:2]);

    float diagSize = 1 * GLKVector3Length(diag);
    
    [self setVectorXZ:GLKVector3Make(-diagSize, cubeVertsXZ[7*3 + 1], -diagSize) forVertex:7];
    [self setVectorXZ:GLKVector3Make(diagSize, cubeVertsXZ[6*3 + 1], -diagSize) forVertex:6];
    [self setVectorXZ:GLKVector3Make(-diagSize, cubeVertsXZ[3*3 + 1], diagSize) forVertex:3];
    [self setVectorXZ:GLKVector3Make(diagSize, cubeVertsXZ[2*3 + 1], diagSize) forVertex:2];
    
    GLKVector3 rightFlank = GLKVector3Subtract([self getVectorForVertex:6], [self getVectorForVertex:2]);
    GLKVector3 leftFlank = GLKVector3Subtract([self getVectorForVertex:7], [self getVectorForVertex:3]);
    GLKVector2 v1 = GLKVector2Normalize(GLKVector2Make(rightFlank.x, rightFlank.z));
    GLKVector2 v2 = GLKVector2Normalize(GLKVector2Make(leftFlank.x, leftFlank.z));
    GLKVector2 xDirection = GLKVector2Make(1,0);
    
    float leftAngle = acos(GLKVector2DotProduct(v2, xDirection));
    float rightAngle = acosf(GLKVector2DotProduct(v1, xDirection));
    
    double initFloatingAngle = (leftAngle + rightAngle)/2;
    
    GLKVector3 deltaVector = GLKVector3Make(self.floorWidthDelta, 0, self.floorHeightDelta);
    
    [self translateVertexXZ:2 withVector:deltaVector];
    [self translateVertexXZ:6 withVector:deltaVector];
    [self translateVertexXZ:3 withVector:deltaVector];
    [self translateVertexXZ:7 withVector:deltaVector];
    
    [self rotateSurfaceXZ:-initFloatingAngle];
    [self updateSurfaceTexXZ];
}

- (void)rotateSurfaceXZ:(float)angle
{
    // TODO: Change to rotate by surface :: This is a c-style rotation. Wrap it with iOS code
    rotateCoordinate(cubeVertsXZ[7*3], cubeVertsXZ[7*3+2], &cubeVertsXZ[7*3], &cubeVertsXZ[7*3 + 2], angle);
    rotateCoordinate(cubeVertsXZ[6*3], cubeVertsXZ[6*3+2], &cubeVertsXZ[6*3], &cubeVertsXZ[6*3 + 2], angle);
    rotateCoordinate(cubeVertsXZ[3*3], cubeVertsXZ[3*3+2], &cubeVertsXZ[3*3], &cubeVertsXZ[3*3 + 2], angle);
    rotateCoordinate(cubeVertsXZ[2*3], cubeVertsXZ[2*3+2], &cubeVertsXZ[2*3], &cubeVertsXZ[2*3 + 2], angle);
}

- (void)updateSurfaceTexWithWidth:(float)w andHeight:(float)h andDepth:(float)d{
    
    // Iterate over even indices (x coordinates)
    for (int i = 0; i < 2* 8; i += 2) {
        scaledSurfaceTexCoordsXY[i] = w * SIGN(surfaceTexCoordsXY[i]); // multiply by w to correct aspect ratio of surface
        scaledSurfaceTexCoordsZY[i] = d * SIGN(surfaceTexCoordsZY[i]); // multiply by d to correct aspect ratio of surface
        scaledSurfaceTexCoordsXZ[i] = w * surfaceTexCoordsXZ[i]; // multiply by w to correct aspect ratio of surface
    }
    
    // Iterate over odd indices (y coordinates)
    for (int i = 1; i < 2* 8; i += 2) {
        scaledSurfaceTexCoordsXY[i] = h * SIGN(surfaceTexCoordsXY[i]); // multiply by w to correct aspect ratio of surface
        scaledSurfaceTexCoordsZY[i] = h * SIGN(surfaceTexCoordsZY[i]); // multiply by h to correct aspect ratio of surface
        scaledSurfaceTexCoordsXZ[i] = d * surfaceTexCoordsXZ[i]; // multiply by d to correct aspect ratio of surface
    }
}

- (void)updateSurfaceTexXZ {
    if (self.currentDesign.CubeVerts == nil || self.currentDesign.CubeVerts.count != CUBE_VERTS * COORDS) return;
    
    float width = GLKVector3Distance([self getVectorForVertexXZ:6], [self getVectorForVertexXZ:7]) * self.worldScale / self.cubeTextureScale;
    float height = GLKVector3Distance([self getVectorForVertexXZ:0], [self getVectorForVertexXZ:3]) * self.worldScale / self.cubeTextureScale;
    float depth = GLKVector3Distance([self getVectorForVertexXZ:2], [self getVectorForVertexXZ:6]) * self.worldScale / self.cubeTextureScale;
    
    [self updateSurfaceTexWithWidth:width andHeight:height andDepth:depth];
}

- (void)updateSurfaceTex {
    if (self.currentDesign.CubeVerts == nil || self.currentDesign.CubeVerts.count != CUBE_VERTS * COORDS) return;
    
    float width = GLKVector3Distance([self getVectorForVertex:6], [self getVectorForVertex:7]) * self.worldScale / self.cubeTextureScale;
    float height = GLKVector3Distance([self getVectorForVertex:0], [self getVectorForVertex:3]) * self.worldScale / self.cubeTextureScale;
    float depth = GLKVector3Distance([self getVectorForVertex:2], [self getVectorForVertex:6]) * self.worldScale / self.cubeTextureScale;
    
    [self updateSurfaceTexWithWidth:width andHeight:height andDepth:depth];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

#pragma mark GLKViewControllerDelegate
// Setup perspective, update wirefram, and set the controlls accordingly.
- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    [self glkViewLogic];
}

-(void)glkViewLogic{
    [self updateSurfaceTex];
    self.effect.transform.modelviewMatrix = [self.camera cameraMatrix];
    self.effect.light0.enabled = GL_FALSE;
    
    // Set the color of the wireframe.
    self.effect.useConstantColor = GL_FALSE;
    self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = self.wireframeTex.name;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}

#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [super glkView:view drawInRect:rect];
    
	self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(self.wallsTransparency, self.wallsTransparency, self.wallsTransparency, self.wallsTransparency);
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = self.wireframeTex.name;
    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
	[self.effect prepareToDraw];
    
    
	glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    if (self.cubeWallsHidden == NO) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glLineWidth(1.0);
        if (_currentWallside == WallNone)
        {
            glVertexAttribPointer(GLKVertexAttribPosition, COORDS, GL_FLOAT, GL_FALSE, 0, cubeVerts);
            
            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, scaledSurfaceTexCoordsXZ);
            glDrawElements(GL_TRIANGLES, COORDS * 4, GL_UNSIGNED_BYTE, surfaceXZ);

            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, scaledSurfaceTexCoordsXY);
            glDrawElements(GL_TRIANGLES, COORDS * 4, GL_UNSIGNED_BYTE, surfaceXY);
            
            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, scaledSurfaceTexCoordsZY);
            glDrawElements(GL_TRIANGLES, COORDS * 4, GL_UNSIGNED_BYTE, surfaceZY);
        }
        
        if (_currentWallside == WallFloor)
        {
            [self buildSurfaceXZ];
            [self rotateSurfaceXZ:self.floorRotatingAngle];
            
            self.effect.texture2d0.enabled = GL_FALSE;
            self.effect.useConstantColor = GL_TRUE;
            GLKVector4 oldColor = self.effect.constantColor;
            self.effect.constantColor = GLKVector4Make(0, 0, 0, 0);
            [self.effect prepareToDraw];
            
            glDepthMask(GL_FALSE);
            glEnable(GL_STENCIL_TEST);
            glStencilFunc(GL_ALWAYS, 1, ~0);
            glStencilOp(GL_KEEP, GL_REPLACE, GL_REPLACE);
            
            glVertexAttribPointer(GLKVertexAttribPosition, COORDS, GL_FLOAT, GL_FALSE, 0, cubeVerts);
            
            // For each type of wall, check if the mask is turned on or not.
            // If it is turned on, render the appropriate plane(s)
            if (activeScribbleWallMasks & WALL_CEILING_MASK)
                glDrawElements(GL_TRIANGLES, COORDS * 2, GL_UNSIGNED_BYTE, surfaceCeilingIdx);
            
            if (activeScribbleWallMasks & WALL_FLOOR_MASK)
                glDrawElements(GL_TRIANGLES, COORDS * 2, GL_UNSIGNED_BYTE, surfaceFloorIdx);
            
            if (activeScribbleWallMasks & WALL_LEFT_MASK)
                glDrawElements(GL_TRIANGLES, COORDS * 2, GL_UNSIGNED_BYTE, surfaceLeftIdx);
            
            if (activeScribbleWallMasks & WALL_RIGHT_MASK)
                glDrawElements(GL_TRIANGLES, COORDS * 2, GL_UNSIGNED_BYTE, surfaceRightIdx);
            
            if (activeScribbleWallMasks & WALL_FRONT_MASK)
                glDrawElements(GL_TRIANGLES, COORDS * 2, GL_UNSIGNED_BYTE, surfaceFrontIdx);
            
            if ( WALL_NONE_MASK == activeScribbleWallMasks)
                 glDrawElements(GL_TRIANGLES, COORDS * 2, GL_UNSIGNED_BYTE, surfaceFloorIdx);

            glEnable(GL_DEPTH_TEST);
            glDepthMask(GL_TRUE);
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
            glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
            glStencilFunc(GL_EQUAL, 1, ~0);
            glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
            
            self.effect.texture2d0.enabled = GL_TRUE;
            self.effect.constantColor = oldColor;
            [self.effect prepareToDraw];
            
            glVertexAttribPointer(GLKVertexAttribPosition, COORDS, GL_FLOAT, GL_FALSE, 0, cubeVertsXZ);
            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, scaledSurfaceTexCoordsXZ);
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, surfaceXZFloorOnly);
            
            glDisable(GL_STENCIL_TEST);
        }
    }
    
    if (self.wireframeHidden == NO) {
        self.effect.texture2d0.enabled = GL_FALSE;
        self.effect.useConstantColor = GL_TRUE;
        self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        [self.effect prepareToDraw];
        glLineWidth(5.0);
		glDrawElements(GL_LINES, 24, GL_UNSIGNED_BYTE, wireframe);
    }       
		glDisableVertexAttribArray(GLKVertexAttribPosition);
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
}

- (GLKVector3)getVectorForVertex:(int)vertex {
	if (vertex < 0 || vertex >= CUBE_VERTS) return GLKVector3Make(0, 0, 0);
	return GLKVector3Make(
						  cubeVerts[COORDS * vertex+X],
						  cubeVerts[COORDS * vertex+Y],
						  cubeVerts[COORDS * vertex+Z]);
}

- (CGPoint)getPointForVertex:(int)vertex {
	GLKVector3 p = [self projectPointForVertex:vertex];
	return CGPointMake(p.x, self.view.bounds.size.height - p.y);
}

- (CGPoint)getPointForButton:(UIButton*)button {
	return [self getPointForVertex:(int)button.tag];
}

- (void)translateVertex:(int)vertex withVector:(GLKVector3)diff {
	GLKVector3 p = [self getVectorForVertex:vertex];
	p = GLKVector3Add(p, diff);
	[self setVector:p forVertex:vertex];
}

- (void)setVector:(GLKVector3)vector forVertex:(int)vertex {
	cubeVerts[vertex * COORDS + X] = vector.x;
	cubeVerts[vertex * COORDS + Y] = vector.y;
	cubeVerts[vertex * COORDS + Z] = vector.z;
}

- (GLKVector3)projectPointForVertex:(int)vertex {
    return [self projectPointForVector:[self getVectorForVertex:vertex]];
}

- (NSArray*)cubeNSArray {
    NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity:CUBE_VERTS * COORDS];
    for (int i = 0; i < CUBE_VERTS * COORDS; i++) {
        [temp addObject:[NSNumber numberWithFloat:cubeVerts[i]]];
    }
    return [temp copy];
}

- (void)setCubeNSArray:(NSArray *)cubeNSArray {
    if (cubeNSArray && cubeNSArray.count == CUBE_VERTS * COORDS) {
        for (int i = 0; i < CUBE_VERTS * COORDS; i++) {
            cubeVerts[i] = [(NSNumber*)[self.currentDesign.CubeVerts objectAtIndex:i] floatValue];
        }
        [self updateSurfaceTex];
	}
}


/* */
- (GLKVector3)getVectorForVertexXZ:(int)vertex {
	if (vertex < 0 || vertex >= CUBE_VERTS) return GLKVector3Make(0, 0, 0);
	return GLKVector3Make(
						  cubeVertsXZ[COORDS * vertex+X],
						  cubeVertsXZ[COORDS * vertex+Y],
						  cubeVertsXZ[COORDS * vertex+Z]);
}

- (void)translateVertexXZ:(int)vertex withVector:(GLKVector3)diff {
	GLKVector3 p = [self getVectorForVertexXZ:vertex];
	p = GLKVector3Add(p, diff);
	[self setVectorXZ:p forVertex:vertex];
}
- (void)setVectorXZ:(GLKVector3)vector forVertex:(int)vertex {
	cubeVertsXZ[vertex * COORDS + X] = vector.x;
	cubeVertsXZ[vertex * COORDS + Y] = vector.y;
	cubeVertsXZ[vertex * COORDS + Z] = vector.z;
}


#pragma mark - Wall masks

+ (void)activateWall:(WallSide)wallside
{
    switch (wallside)
    {
        case WallCeilling: activeScribbleWallMasks |= WALL_CEILING_MASK;    break;
        case WallFloor: activeScribbleWallMasks    |= WALL_FLOOR_MASK;      break;
        case WallFront: activeScribbleWallMasks    |= WALL_FRONT_MASK;      break;
        case WallLeft: activeScribbleWallMasks     |= WALL_LEFT_MASK;       break;
        case WallRight: activeScribbleWallMasks    |= WALL_RIGHT_MASK;      break;
        case WallNone: activeScribbleWallMasks     |= WALL_NONE_MASK;       break;
        case WallAll: activeScribbleWallMasks      |= WALL_ALL_MASK;        break;
    }
}


+ (void)clearWallMasks
{
    activeScribbleWallMasks = WALL_NONE_MASK;
}

+ (int)getActiveWallMask
{
    return activeScribbleWallMasks;
}

+ (void)setActiveWallMask:(int)wallMask
{
    activeScribbleWallMasks = wallMask;
}



@end

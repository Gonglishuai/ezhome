//
//  GraphicObject.h
//  CmyCasa
//

#import <Foundation/Foundation.h>
#import "ModelBoundingBox.h"

#define GO_NO_SCALE (-1.0)

typedef struct SingleObject {
    char* name;
	int numVerts;
	float* verts;
	float* normals;
	float* texCoord;
} SingleObject;

@interface GraphicObject : NSObject <NSCoding, NSCopying> {
	int _numObjects;
	SingleObject* _objects;
	float _minX;
	float _minY;
	float _minZ;
	float _maxX;
	float _maxY;
	float _maxZ;
}

@property (nonatomic,strong) ModelBoundingBox *modelBoundingBox;
@property (nonatomic,strong) ModelBoundingBox *modelBoundingBoxWithShadow;

// Create a graphic object from an OBJ WaveFront file contents. objString is the contents.
- (id)initWithOBJFormat:(NSString *)objString scale:(float)scale parseTexture:(BOOL)parseTexture;
// Create a graphic object from the given vertices, normals and texture coordinates.
- (id)initWithNumOfVerts: (unsigned int)num Verts:(float*)verts Normals:(float*)normals TexCoord:(float*)texCoord;
- (void)dealloc;
// Returns the verts, normals and texture coordinates.
-(float*)vertsOfObject:(int)i;
-(float*)normalsOfObject:(int)i;
-(float*)texCoordOfObject:(int)i;
-(NSString*)nameOfObject:(int)i;
// Returns the sizes of the bounding box.
-(float)widthX;
-(float)widthY;
-(float)widthZ;
-(float)minZ;
-(float)maxZ;
-(float)minX;
-(float)maxX;
-(float)minY;
-(float)maxY;
// The number of vertices
-(int)numVertsOfObject:(int)i;
-(float) diagonalBoundingBox;

-(int)numberOfObjects;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

- (ModelBoundingBox*)getBoundingBox;

- (ModelBoundingBox*)getBoundingBoxWithShadow;

- (BOOL)hasObjectNamed:(NSString*)nameOfObject;

@end

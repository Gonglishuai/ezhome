//
//  GraphicObject.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "GraphicObject.h"
#import "AppDelegate.h"
#import "NSString+Contains.h"

#define X (0)
#define Y (1)
#define Z (2)

@interface GraphicObject(Private)
-(int)numberOfVerticesWithBBInit:(NSString*) objString;
-(int)calcSizeAndCenter:(NSString*) objString intoSize:(float*)size intoCenter:(float*)center;
-(BOOL)readFaceVert:(NSString*)vertString intoV:(float*)va intoN:(float*)na intoT:(float*)ta;
@end

// Private structure for keeping track of object's faces
@interface GraphicObjectFace : NSObject {
	int va, vb, vc, na, nb, nc, ta, tb, tc;
}

@property(atomic) int va;
@property(atomic) int vb;
@property(atomic) int vc;
@property(atomic) int na;
@property(atomic) int nb;
@property(atomic) int nc;
@property(atomic) int ta;
@property(atomic) int tb;
@property(atomic) int tc;

-(BOOL)hasNormals;
-(BOOL)hasTexture;

@end

@implementation GraphicObjectFace
@synthesize va, vb, vc, na, nb, nc, ta, tb, tc;

-(id)init {
	if (self = [super init]) {
		va = -1;
		vb = -1;
		vc = -1;
		na = -1;
		nb = -1;
		nc = -1;
		ta = -1;
		tb = -1;
		tc = -1;
	}
	return self;
}

-(BOOL)hasNormals {
	return na >= 0 && nb >= 0 && nc >= 0;
}
-(BOOL)hasTexture {
	return ta >=0 && tb >= 0 && tc >= 0;
}

@end

@implementation GraphicObject

- (id)initWithOBJFormat: (NSString*)objString scale:(float)scale parseTexture:(BOOL)parseTexture{
    
	if (self = [super init]) {
		int numVerts = [self numberOfVerticesWithBBInit:objString];
		float temp_scale = 1.0f;

		if (scale == GO_NO_SCALE) {
			scale = temp_scale;
		}
		if (numVerts == 0) return nil;

        BOOL usingNormals = NO, usingTexture = NO;
		// Accumelating x, y, z coordinates
		int v_idx = 0;
		float* xCoord = malloc(numVerts * sizeof(float));
		float* yCoord = malloc(numVerts * sizeof(float));
		float* zCoord = malloc(numVerts * sizeof(float));
		// Accumelating x,y,z normals
		int n_idx = 0;
		float* xNormal = malloc(numVerts * sizeof(float));
		float* yNormal = malloc(numVerts * sizeof(float));
		float* zNormal = malloc(numVerts * sizeof(float));
		// Accumelating x,y texture coordinates
		int t_idx = 0;
		float* xTex = malloc(numVerts * sizeof(float));
		float* yTex = malloc(numVerts * sizeof(float));
		// Number of faces:
		NSMutableArray* objectsFaces = [[NSMutableArray alloc] init];
		NSMutableArray* faces;
        NSString* objectName;
        NSMutableArray* objectNames = [NSMutableArray array];
		
		NSScanner* fileScanner = [[NSScanner alloc] initWithString:objString];
		NSString* line;
		BOOL conversionError = NO;

        while (YES == [fileScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line]) {
			BOOL succBool = YES;
			NSScanner* lineScanner = [[NSScanner alloc] initWithString:line];
			
			if (YES == [line hasPrefix:@"g "]) {
                [lineScanner scanString:@"g " intoString:NULL];

				if (faces != nil) {
                    [objectsFaces addObject:faces];
                    [objectNames addObject:objectName];
                }
                [lineScanner scanUpToCharactersFromSet:[[NSCharacterSet alloc] init] intoString:&objectName];
				faces = [[NSMutableArray alloc] init];
			}
			
			// Porcess normals
            else if (YES == [line hasPrefix:@"vn "]) {
                [lineScanner scanString:@"vn " intoString:NULL];

				usingNormals = YES;
				if (n_idx >= numVerts) {
					conversionError = YES;
					break;
				}
				succBool &= [lineScanner scanFloat:&xNormal[n_idx]];
				succBool &= [lineScanner scanFloat:&yNormal[n_idx]];
				succBool &= [lineScanner scanFloat:&zNormal[n_idx]];

				if (succBool == NO) {
					conversionError = YES;
					break;
				}

				// Normalize normal vector:
				float size = sqrtf(xNormal[n_idx] * xNormal[n_idx] + yNormal[n_idx] * yNormal[n_idx] + zNormal[n_idx] * zNormal[n_idx]);
				if (size != 0) {
					xNormal[n_idx] /= size;
					yNormal[n_idx] /= size;
					zNormal[n_idx] /= size;
				} else {
					xNormal[n_idx] = 1.0f;
					yNormal[n_idx] = 0.0f;
					zNormal[n_idx] = 0.0f;
				}

				n_idx++;
            }
			
			// Process texture coordinates
            else if (YES == [line hasPrefix:@"vt "]) {
                [lineScanner scanString:@"vt " intoString:NULL];

				usingTexture = YES && parseTexture;
				if (t_idx >= numVerts) {
					conversionError = YES;
					break;
				}
				succBool &= [lineScanner scanFloat:&xTex[t_idx]];
				succBool &= [lineScanner scanFloat:&yTex[t_idx]];
				
				if (succBool == NO) {
					conversionError = YES;
					break;
				}
				yTex[t_idx] = 1 - yTex[t_idx];
				[lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
				t_idx++;
			}

			
			// Process verteces
            else if (YES == [line hasPrefix:@"v "]) {
                [lineScanner scanString:@"v " intoString:NULL];

				if (v_idx >= numVerts) {
					conversionError = YES;
					break;
				}
				succBool &= [lineScanner scanFloat:&xCoord[v_idx]];
				succBool &= [lineScanner scanFloat:&yCoord[v_idx]];
				succBool &= [lineScanner scanFloat:&zCoord[v_idx]];
				
				if (succBool == NO) {
					conversionError = YES;
					break;
				}
				
				// Translate vertex vector according the scale and center:
				xCoord[v_idx] = (xCoord[v_idx]) * scale;
				yCoord[v_idx] = (yCoord[v_idx]) * scale;
				zCoord[v_idx] = (zCoord[v_idx]) * scale;
				
				v_idx++;
			}
			
			// Process faces
            else if (YES == [line hasPrefix:@"f "]) {
                [lineScanner scanString:@"f " intoString:NULL];

				NSString* faceString;
				[lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&faceString];
				NSArray* faceVerts = [faceString componentsSeparatedByString:@" "];
				if ([faceVerts count] < 3) {
					conversionError = YES;
					break;
				}

				GraphicObjectFace* face = [[GraphicObjectFace alloc] init];
				float tempV=-1, tempN =-1, tempT=-1;
				succBool &= [self readFaceVert:[faceVerts objectAtIndex:0] intoV:&tempV intoN:&tempN intoT:&tempT];
				face.va = tempV; face.na = tempN; face.ta = tempT;
				succBool &= [self readFaceVert:[faceVerts objectAtIndex:1] intoV:&tempV intoN:&tempN intoT:&tempT];
				face.vb = tempV; face.nb = tempN; face.tb = tempT;
				succBool &=[self readFaceVert:[faceVerts objectAtIndex:2] intoV:&tempV intoN:&tempN intoT:&tempT];
				face.vc = tempV; face.nc = tempN; face.tc = tempT;
				if (succBool && usingNormals == [face hasNormals] && usingTexture == [face hasTexture]) {
					[faces addObject:face];
				} else {
					conversionError = YES;
					break;
				}
				
				
				// rectangle...
				if ([faceVerts count] >= 4 && [[faceVerts objectAtIndex:3] length] > 0) {
					GraphicObjectFace* anotherFace = [[GraphicObjectFace alloc] init];
					anotherFace.va = face.va; anotherFace.na = face.na; anotherFace.ta = face.ta;
					anotherFace.vc = face.vc; anotherFace.nc = face.nc; anotherFace.tc = face.tc;
					succBool &= [self readFaceVert:[faceVerts objectAtIndex:3] intoV:&tempV intoN:&tempN intoT:&tempT];
					anotherFace.vb = tempV; anotherFace.nb = tempN; anotherFace.tb = tempT;
					
                    if (succBool && usingNormals == [face hasNormals] && usingTexture == [face hasTexture]) {
						[faces addObject:anotherFace];
					} else {
						conversionError = YES;
						break;
					}
				}
			}
		}

        if (faces != nil) {
            [objectNames addObject:objectName];
            [objectsFaces addObject:faces];
        }
		faces = nil;
        objectName = nil;
		
		if (conversionError == YES) {
			free(xCoord);free(yCoord);free(zCoord);
			free(xNormal);free(yNormal);free(zNormal);
			free(xTex);free(yTex);
			return nil;
		}
        
		_numObjects = (int)objectsFaces.count;

        //temp min/max values for correct bounding box
        float mnx = 0;
        float mxx = 0;
        float mny = 0;
        float mxy = 0;
        float mnz = 0;
        float mxz = 0;
        
		_objects = malloc(_numObjects * sizeof(SingleObject));
		for (int objectId = 0; objectId < objectsFaces.count; ++objectId) {
			NSArray* objectFaces = objectsFaces[objectId];
            NSString* objectName = objectNames[objectId];
            
            _objects[objectId].name = malloc((objectName.length+1) * sizeof(char));
            strcpy(_objects[objectId].name, objectName.UTF8String);
			_objects[objectId].numVerts = (int)(3 * objectFaces.count);
			_objects[objectId].verts = malloc(_objects[objectId].numVerts * 3 * sizeof(float));
			if (usingNormals) {
				_objects[objectId].normals = malloc(_objects[objectId].numVerts * 3 * sizeof(float));
			} else {
				_objects[objectId].normals = NULL;
			}
			if (usingTexture) {
				_objects[objectId].texCoord = malloc(_objects[objectId].numVerts * 2 * sizeof(float));
			}  else {
				_objects[objectId].texCoord = NULL;
			}
			int vert_idx=0, normal_idx=0, tex_idx=0;


			// Update the vertex array with the faces we've found
			for (GraphicObjectFace* face in objectFaces)
            {
				_objects[objectId].verts[vert_idx++] = xCoord[face.va];
				_objects[objectId].verts[vert_idx++] = yCoord[face.va];
				_objects[objectId].verts[vert_idx++] = zCoord[face.va];
				_objects[objectId].verts[vert_idx++] = xCoord[face.vb];
				_objects[objectId].verts[vert_idx++] = yCoord[face.vb];
				_objects[objectId].verts[vert_idx++] = zCoord[face.vb];
				_objects[objectId].verts[vert_idx++] = xCoord[face.vc];
				_objects[objectId].verts[vert_idx++] = yCoord[face.vc];
				_objects[objectId].verts[vert_idx++] = zCoord[face.vc];
				
				if (usingNormals) {
					_objects[objectId].normals[normal_idx++] = xNormal[face.na];
					_objects[objectId].normals[normal_idx++] = yNormal[face.na];
					_objects[objectId].normals[normal_idx++] = zNormal[face.na];
					_objects[objectId].normals[normal_idx++] = xNormal[face.nb];
					_objects[objectId].normals[normal_idx++] = yNormal[face.nb];
					_objects[objectId].normals[normal_idx++] = zNormal[face.nb];
					_objects[objectId].normals[normal_idx++] = xNormal[face.nc];
					_objects[objectId].normals[normal_idx++] = yNormal[face.nc];
					_objects[objectId].normals[normal_idx++] = zNormal[face.nc];
				}
				
				if (usingTexture) {
					_objects[objectId].texCoord[tex_idx++] = xTex[face.ta];
					_objects[objectId].texCoord[tex_idx++] = yTex[face.ta];
					_objects[objectId].texCoord[tex_idx++] = xTex[face.tb];
					_objects[objectId].texCoord[tex_idx++] = yTex[face.tb];
					_objects[objectId].texCoord[tex_idx++] = xTex[face.tc];
					_objects[objectId].texCoord[tex_idx++] = yTex[face.tc];
				}
			}
            
            
            // Get bounding box for non shadow object
            if (![objectName contains:@"shadow" options:NSCaseInsensitiveSearch])
            {
                for (int i=0; i < _objects[objectId].numVerts; i++) {
                    mnx = MIN(mnx, _objects[objectId].verts[3*i]);
                    mxx = MAX(mxx, _objects[objectId].verts[3*i]);
                    mny = MIN(mny, _objects[objectId].verts[3*i + 1]);
                    mxy = MAX(mxy, _objects[objectId].verts[3*i + 1]);
                    mnz = MIN(mnz, _objects[objectId].verts[3*i + 2]);
                    mxz = MAX(mxz, _objects[objectId].verts[3*i + 2]);
                }
            }
            
		}
     
        objectsFaces = nil;
        _maxX *= scale;
        _maxY *= scale;
        _maxZ *= scale;
        _minX *= scale;
        _minY *= scale;
        _minZ *= scale;
        
        // TODO (AVIHAY): Document here
        self.modelBoundingBoxWithShadow = [[ModelBoundingBox alloc] initWithMaxX:_maxX
                                                                              maxY:_maxY
                                                                              maxZ:_maxZ
                                                                              minX:_minX
                                                                              minY:_minY
                                                                              minZ:_minZ];

        self.modelBoundingBox = [[ModelBoundingBox alloc] initWithMaxX:mxx
                                                                  maxY:mxy
                                                                  maxZ:mxz
                                                                  minX:mnx
                                                                  minY:mny
                                                                  minZ:mnz];

        free(xCoord); free(yCoord); free(zCoord);
        free(xNormal); free(yNormal); free(zNormal);
        free(xTex); free(yTex);
        
        long totalSize = 0;
        for (int i = 0; i < [self numberOfObjects]; i++) {
            totalSize += sizeof(_objects[i].verts) * _objects[i].numVerts * 3;
            totalSize += sizeof(_objects[i].texCoord) * _objects[i].numVerts * 2;
            totalSize += sizeof(_objects[i].normals) * _objects[i].numVerts * 3;
            totalSize += sizeof(_objects[i]);
        }
        HSMDebugLog(@"total size: %ld", totalSize);
    }
    
    
	return self;
}

// Read a single face from file
-(BOOL)readFaceVert:(NSString*)vertString intoV:(float*)va intoN:(float*)na intoT:(float*)ta {    
    NSArray * parts=[vertString componentsSeparatedByString:@"/"];
    
    if ([parts count]==0) {
        return NO;
        
    }
    
    if ([parts count]==1) {
        if([[parts objectAtIndex:0] length]>0) *va=[[parts objectAtIndex:0] floatValue]-1;
        return YES;
    }
    if ([parts count]==2) {
        if([[parts objectAtIndex:0] length]>0) *va=[[parts objectAtIndex:0] floatValue]-1;
        if([[parts objectAtIndex:1] length]>0) *ta=[[parts objectAtIndex:1] floatValue]-1;
        
        return YES;
    }
    if ([parts count]==3) {
        if([[parts objectAtIndex:0] length]>0) *va=[[parts objectAtIndex:0] floatValue]-1;
        if([[parts objectAtIndex:1] length]>0) *ta=[[parts objectAtIndex:1] floatValue]-1;
        if([[parts objectAtIndex:2] length]>0) *na=[[parts objectAtIndex:2] floatValue]-1;
        
        return YES;
    }
    
	return NO;
}

// Finds the number of vertices of the model and calculate min/max bounding box in one pass
-(int)numberOfVerticesWithBBInit:(NSString*) objString {
    NSScanner* fileScanner = [[NSScanner alloc] initWithString:objString];
    NSString* line;
    int numVerts = 0;

    float minx = INFINITY, miny = INFINITY, minz = INFINITY;
    float maxx = -INFINITY, maxy = -INFINITY, maxz = -INFINITY;

    while (YES == [fileScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line]) {
        if (YES == [line hasPrefix:@"f "]) {
            numVerts++;
        }

        else if (YES == [line hasPrefix:@"v "]) {
            NSScanner* lineScanner = [[NSScanner alloc] initWithString:line];
            [lineScanner scanString:@"v " intoString:NULL];

            BOOL succBool = YES;
            float x, y, z;
            succBool &= [lineScanner scanFloat:&x];
            succBool &= [lineScanner scanFloat:&y];
            succBool &= [lineScanner scanFloat:&z];
            if (succBool == NO) break;

            //sumx += x; sumy += y; sumz += z;
            minx = MIN(minx, x); miny = MIN(miny, y); minz = MIN(minz, z);
            maxx = MAX(maxx, x); maxy = MAX(maxy, y); maxz = MAX(maxz, z);
        }
    }


    if (numVerts > 0) {
        _maxX = maxx;
        _maxY = maxy;
        _maxZ = maxz;
        _minX = minx;
        _minY = miny;
        _minZ = minz;
    }

    return 3 * numVerts;
}


// Manual init
- (id)initWithNumOfVerts: (unsigned int)num Verts:(float*)verts Normals:(float*)normals TexCoord:(float*)texCoord {
	if (self = [super init]) {
		_objects = malloc(sizeof(SingleObject));
		_objects->numVerts = num;
		_objects->verts = malloc(_objects->numVerts * 3 * sizeof(float));
		memcpy(_objects->verts, verts, num * 3 * sizeof(float));
		if (normals != NULL) {
			_objects->normals = malloc(_objects->numVerts * 3 * sizeof(float));
			memcpy(_objects->normals, normals, num * 3 * sizeof(float));
		} else {
			_objects->normals = NULL;
		}
		if (texCoord != NULL) {
			_objects->texCoord = malloc(_objects->numVerts * 2 * sizeof(float));
			memcpy(_objects->texCoord, texCoord, num * 2 * sizeof(float));
		} else {
			_objects->texCoord = NULL;
		}
		
		_minX = _minY = _minZ = INFINITY;
		_maxX = _maxY = _maxZ = -INFINITY;
		for (int i=0; i < _objects->numVerts; i++) {
			_minX = MIN(_minX, _objects->verts[3*i]);
			_maxX = MAX(_maxX, _objects->verts[3*i]);
			_minY = MIN(_minY, _objects->verts[3*i + 1]);
			_maxY = MAX(_maxY, _objects->verts[3*i + 1]);
			_minZ = MIN(_minZ, _objects->verts[3*i + 2]);
			_maxZ = MAX(_maxZ, _objects->verts[3*i + 2]);
		}
	}
	return self;
}

-(float*)vertsOfObject:(int)i {
	if (i < 0 || i >= _numObjects) return NULL;
	return _objects[i].verts;
}
-(float*)normalsOfObject:(int)i {
	if (i < 0 || i >= _numObjects) return NULL;
	return _objects[i].normals;
}
-(float*)texCoordOfObject:(int)i {
	if (i < 0 || i >= _numObjects) return NULL;
	return _objects[i].texCoord;
}
-(int)numVertsOfObject:(int)i {
	if (i < 0 || i >= _numObjects) return 0;
	return _objects[i].numVerts;
}
-(NSString*)nameOfObject:(int)i {
    if (i < 0 || i >= _numObjects) return nil;
    return [NSString stringWithUTF8String:_objects[i].name];
}
-(int)numberOfObjects {
	return _numObjects;
}
-(float)widthX {
	return _maxX - _minX;
}
-(float)widthY {
	return _maxY - _minY;
}
-(float)widthZ {
	return _maxZ - _minZ;
}
-(float)minZ {
    return _minZ;
}
-(float)maxZ {
    return _maxZ;
}
-(float)minX {
    return _minX;
}
-(float)maxX {
    return _maxX;
}
-(float)minY {
    return _minY;
}
-(float)maxY {
    return _maxY;
}

-(float) diagonalBoundingBox
{
    return sqrtf(([self widthX] *[self widthX]) + ([self widthY]*[self widthY]) + ([self widthZ]*[self widthZ]));
}

- (void)dealloc {
	for (int i = 0; i < _numObjects; ++i) {
        free(_objects[i].name);
		free(_objects[i].verts);
		free(_objects[i].normals);
		free(_objects[i].texCoord);
	}
	free(_objects);
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _numObjects = [coder decodeIntForKey:@"_numObjects"];
        _minX = [coder decodeFloatForKey:@"_minX"];
        _minY = [coder decodeFloatForKey:@"_minY"];
        _minZ = [coder decodeFloatForKey:@"_minZ"];
        _maxX = [coder decodeFloatForKey:@"_maxX"];
        _maxY = [coder decodeFloatForKey:@"_maxY"];
        _maxZ = [coder decodeFloatForKey:@"_maxZ"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:_numObjects forKey:@"_numObjects"];
    [coder encodeFloat:_minX forKey:@"_minX"];
    [coder encodeFloat:_minY forKey:@"_minY"];
    [coder encodeFloat:_minZ forKey:@"_minZ"];
    [coder encodeFloat:_maxX forKey:@"_maxX"];
    [coder encodeFloat:_maxY forKey:@"_maxY"];
    [coder encodeFloat:_maxZ forKey:@"_maxZ"];
}

- (id)copyWithZone:(NSZone *)zone {
    GraphicObject *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy->_numObjects = _numObjects;
        copy->_objects = _objects;
        copy->_minX = _minX;
        copy->_minY = _minY;
        copy->_minZ = _minZ;
        copy->_maxX = _maxX;
        copy->_maxY = _maxY;
        copy->_maxZ = _maxZ;
    }

    return copy;
}

- (ModelBoundingBox*)getBoundingBox
{
    return self.modelBoundingBox;
    
}

- (ModelBoundingBox*)getBoundingBoxWithShadow
{
    return self.modelBoundingBoxWithShadow;
    
}


- (BOOL)hasObjectNamed:(NSString*)nameOfObject
{
    for (int i = 0; i < self.numberOfObjects; i++) {
        if([[self nameOfObject:i] isEqual:nameOfObject]) {
            return YES;
        }
    }
    return NO;
}

@end

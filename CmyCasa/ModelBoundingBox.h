//
//  ModelBoundingBoxDimensions.h
//  Homestyler
//
//

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ModelBoundingBox : NSObject

@property (nonatomic) float width;
@property (nonatomic) float hight;
@property (nonatomic) float length;

@property (nonatomic) float minX;
@property (nonatomic) float minY;
@property (nonatomic) float minZ;
@property (nonatomic) float maxX;
@property (nonatomic) float maxY;
@property (nonatomic) float maxZ;


- (instancetype)initWithMaxX:(float)_maxX
                        maxY:(float)_maxY
                        maxZ:(float)_maxZ
                        minX:(float)_minX
                        minY:(float)_minY
                        minZ:(float)_minZ;

// Retrieves the center of the bounding box
- (GLKVector3)centerOfBox;

@end

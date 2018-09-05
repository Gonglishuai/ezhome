//
//  ModelBoundingBoxDimensions.m
//  Homestyler
//
//  Holds Bounding box of the model assuming no scaling was performed on it
//
//

#import "ModelBoundingBox.h"

///////////////////////////////////////////////////////
//               IMPLEMENTATION                      //
///////////////////////////////////////////////////////

@implementation ModelBoundingBox

- (instancetype)initWithMaxX:(float)maxX
                        maxY:(float)maxY
                        maxZ:(float)maxZ
                        minX:(float)minX
                        minY:(float)minY
                        minZ:(float)minZ
{
    self = [super init];

    self.minX = minX;
    self.minY = minY;
    self.minZ = minZ;
    self.maxX = maxX;
    self.maxY = maxY;
    self.maxZ = maxZ;
    
    self.width = (_maxX - _minX) * 100;
    self.hight = (_maxY - _minY) * 100;
    self.length =(_maxZ - _minZ) * 100;
    
    return self;
}

- (GLKVector3)centerOfBox
{
    return GLKVector3Make((self.maxX + self.minX) / 2,
                          (self.maxY + self.minY) / 2,
                          (self.maxZ + self.minZ) / 2);
}


@end

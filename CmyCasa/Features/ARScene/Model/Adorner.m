//
//  Dimesnion.m
//  ardemo
//
//  Created by lvwei on 23/10/2017.
//  Copyright © 2017 juran. All rights reserved.
//

#import "Adorner.h"

@implementation Adorner

const CGFloat TOPRADIUS = 0;
const CGFloat BOTTOMRADIUS = 2;
const CGFloat ARROWHEIGHT = 5;
const CGFloat LINERADIUS = 0.25;
const CGFloat LINELENGHT = 10;
const CGFloat MARGIN = 4;
const CGFloat TEXTDEPTH = 0.1;
const CGFloat TEXTSIZE = 4;

#pragma mark Dimension

+ (SCNNode*)buildDimensions:(SCNNode*)target min:(SCNVector3)min max:(SCNVector3)max
{
    SCNNode* dimension = [SCNNode node];
    
//    SCNVector3 min = SCNVector3Make(0, 0, 0);
//    SCNVector3 max = SCNVector3Make(0, 0, 0);
//    [target.geometry getBoundingBoxMin:&min max:&max];
    
    CGFloat width  = max.x - min.x;
    SCNNode *widthDim = [self buildDimension:width];
    widthDim.position = SCNVector3Make((max.x + min.x)/2, min.y, max.z);
    [dimension addChildNode: widthDim];
    
    CGFloat length = max.z - min.z;
    SCNNode *lengthDim = [self buildDimension:length];
    lengthDim.eulerAngles = SCNVector3Make(0, M_PI_2, 0);
    lengthDim.position = SCNVector3Make(max.x, min.y, (max.z + min.z)/2);
    [dimension addChildNode: lengthDim];
    
    CGFloat height = max.y - min.y;
    SCNNode *heightDim = [self buildDimension:height];
    heightDim.eulerAngles = SCNVector3Make(M_PI_2, 0, M_PI_2);
    heightDim.position = SCNVector3Make(max.x, (min.y + max.y) / 2, max.z);
    
    [dimension addChildNode: heightDim];
    
    return dimension;
}

+ (SCNNode*)buildLeading
{
    SCNGeometry *geoArrow = [SCNCone coneWithTopRadius:TOPRADIUS bottomRadius:BOTTOMRADIUS height:ARROWHEIGHT];
    
    SCNNode *leading = [SCNNode nodeWithGeometry:geoArrow];
    leading.rotation = SCNVector4Make(0, 0,1,-M_PI_2);
    
    SCNGeometry *geoLine = [SCNCylinder cylinderWithRadius:LINERADIUS height:LINELENGHT];
    SCNNode *line = [SCNNode nodeWithGeometry:geoLine];
    line.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    line.position = SCNVector3Make(0, ARROWHEIGHT/2, 0);
    [leading addChildNode:line];
    
    return leading;
}

+ (SCNNode*)buildTrailing
{
    SCNGeometry *geoArrow = [SCNCone coneWithTopRadius:TOPRADIUS bottomRadius:BOTTOMRADIUS height:ARROWHEIGHT];
    
    SCNNode *trailing = [SCNNode nodeWithGeometry:geoArrow];
    trailing.rotation = SCNVector4Make(0,0,1,M_PI_2);
    
    SCNGeometry *geoLine = [SCNCylinder cylinderWithRadius:LINERADIUS height:LINELENGHT];
    SCNNode *line = [SCNNode nodeWithGeometry:geoLine];
    line.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    line.position = SCNVector3Make(0, ARROWHEIGHT/2, 0);
    [trailing addChildNode:line];
    
    return trailing;
}

+ (SCNNode*)buildLine:(CGFloat)distance
{
    SCNGeometry *geoLine = [SCNCylinder cylinderWithRadius:LINERADIUS height:(distance)];
    
    SCNNode *line = [SCNNode nodeWithGeometry:geoLine];
    line.rotation = SCNVector4Make(0,0,1,M_PI_2);
    
    return line;
}

+ (SCNNode*)buildLabel:(CGFloat)distance
{
    NSString* text = [NSString stringWithFormat:@"%.2fcm", distance];
    SCNText *geoText = [SCNText textWithString:text extrusionDepth:TEXTDEPTH];
    geoText.font = [UIFont systemFontOfSize:TEXTSIZE];
    
    SCNVector3 min = SCNVector3Make(0, 0, 0);
    SCNVector3 max = SCNVector3Make(0, 0, 0);
    [geoText getBoundingBoxMin:&min max:&max];
    CGFloat width = max.x - min.x;
    
    SCNNode *label = [SCNNode nodeWithGeometry:geoText];
    label.position = SCNVector3Make(-width/2, 0, MARGIN*2);
    label.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    
    return label;
}

+ (SCNNode*)buildDimension:(CGFloat)distance
{
    SCNNode* dimension = [SCNNode node];
    
    
//    SCNNode* line = [self buildLine:(distance - ARROWHEIGHT * 2)];
//    [dimension addChildNode:line];
    
//    SCNNode* leading = [self buildLeading];
//    leading.position = SCNVector3Make((distance - ARROWHEIGHT)/2, 0, 0);
//    [dimension addChildNode:leading];
//
//    SCNNode* trailing = [self buildTrailing];
//    trailing.position = SCNVector3Make((ARROWHEIGHT - distance)/2, 0, 0);
//    [dimension addChildNode:trailing];
    
    
    SCNNode* line = [self buildLine:distance];
    [dimension addChildNode:line];
    
    SCNNode* text = [self buildLabel:distance];
    [dimension addChildNode:text];
    
    return dimension;
}

#pragma mark Basement
+ (SCNNode*)buildBasement:(SCNNode *)target min:(SCNVector3)min max:(SCNVector3)max
{
    SCNNode *basement = [SCNNode node];

//    SCNVector3 min = SCNVector3Make(0, 0, 0);
//    SCNVector3 max = SCNVector3Make(0, 0, 0);
//    [target getBoundingBoxMin:&min max:&max];
    CGFloat radius = sqrt(pow((max.x - min.x) / 2, 2) + pow((max.z - min.z) / 2 , 2));
    
    SCNGeometry *geoBase = [SCNCylinder cylinderWithRadius:radius height:0.1];
    geoBase.firstMaterial.diffuse.contents = [UIImage imageNamed:[NSString stringWithFormat:@"./art.scnassets/Materials/cycle.png"]];
//    geoBase.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
//    SCNGeometry *geoCenter = [SCNCylinder cylinderWithRadius:radius-5 height:0.2];
//    geoCenter.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.3];

    SCNNode *base = [SCNNode nodeWithGeometry:geoBase];
    base.position = SCNVector3Make((max.x + min.x) / 2, min.y + 0.1, (max.z + min.z) / 2);
    [basement addChildNode:base];
//    SCNNode *center = [SCNNode nodeWithGeometry:geoCenter];
//    center.position = SCNVector3Make(0, min.y - 0.2, 0);
//    [basement addChildNode:center];
    
    return basement;
}

+ (SCNNode*)buildMarker:(SCNNode*)target
{
    CGFloat radius = 0;
    SCNVector3 center = SCNVector3Make(0, 0, 0);
    [target getBoundingSphereCenter:&center radius:&radius];
    
    SCNText *geoText = [SCNText textWithString:@"Table" extrusionDepth:TEXTDEPTH];
    SCNGeometry *geoMarker = [SCNBox boxWithWidth:10 height:0.1 length:8 chamferRadius:0];
    geoMarker.firstMaterial.diffuse.contents = [UIImage imageNamed:[NSString stringWithFormat:@"./art.scnassets/Materials/marker.png"]];
    
    SCNNode *marker = [SCNNode nodeWithGeometry:geoMarker];
    marker.position = center;
    [target addChildNode:marker];
    
    return target;
}

+ (SCNNode*)buildBox:(SCNNode *)target
{
    SCNNode* box = [SCNNode node];
    
    SCNVector3 min = SCNVector3Make(0, 0, 0);
    SCNVector3 max = SCNVector3Make(0, 0, 0);
    [target getBoundingBoxMin:&min max:&max];
    
    CGFloat width  = max.x - min.x;
    CGFloat length = max.z - min.z;
    CGFloat height = max.y - min.y;
    
    SCNGeometry * geoBottom = [SCNPlane planeWithWidth:width height:length];
    SCNGeometry * geoTop = [SCNPlane planeWithWidth:width height:length];
    SCNGeometry * geoLeft = [SCNPlane planeWithWidth:length height:height];
    SCNGeometry * geoRight = [SCNPlane planeWithWidth:length height:height];
    SCNGeometry * geoFront = [SCNPlane planeWithWidth:width height:height];
    SCNGeometry * geoBack = [SCNPlane planeWithWidth:width height:height];
    
    geoBottom.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
    geoTop.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
    geoLeft.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
    geoRight.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
    geoFront.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
    geoBack.firstMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    SCNNode *bottom = [SCNNode nodeWithGeometry:geoBottom];
    SCNNode *top = [SCNNode nodeWithGeometry:geoTop];
    SCNNode *left = [SCNNode nodeWithGeometry:geoLeft];
    SCNNode *right = [SCNNode nodeWithGeometry:geoRight];
    SCNNode *front = [SCNNode nodeWithGeometry:geoFront];
    SCNNode *back = [SCNNode nodeWithGeometry:geoBack];
    
    bottom.position = SCNVector3Make(0, min.y, 0);
    bottom.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0);
    top.position = SCNVector3Make(0, max.y, 0);
    top.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0);
    left.position = SCNVector3Make(min.x, (min.y + max.y)/2, 0);
    left.eulerAngles = SCNVector3Make(0, -M_PI_2, 0);
    right.position = SCNVector3Make(max.x, (min.y + max.y)/2, 0);
    right.eulerAngles = SCNVector3Make(0, M_PI_2, 0);
    front.position = SCNVector3Make(0, (min.y + max.y)/2, max.z);
    back.position = SCNVector3Make(0, (min.y + max.y)/2, min.z);
    back.eulerAngles = SCNVector3Make(0, M_PI, 0);
  
    [box addChildNode:bottom];
    [box addChildNode:top];
    [box addChildNode:left];
    [box addChildNode:right];
    [box addChildNode:front];
    [box addChildNode:back];
    
    return box;
}
@end

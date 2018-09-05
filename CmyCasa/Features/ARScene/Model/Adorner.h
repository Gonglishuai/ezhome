//
//  Dimension.h
//  ardemo
//
//  Created by lvwei on 23/10/2017.
//  Copyright © 2017 juran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>

@interface Adorner : NSObject 

+ (SCNNode*)buildDimensions:(SCNNode*)target min:(SCNVector3)min max:(SCNVector3)max;

+ (SCNNode*)buildBasement:(SCNNode*)target min:(SCNVector3)min max:(SCNVector3)max;

+ (SCNNode*)buildMarker:(SCNNode*)target;

+ (SCNNode*)buildBox:(SCNNode*)target;


@end


//
//  Model.h
//  ardemo
//
//  Created by lvwei on 04/09/2017.
//  Copyright © 2017 juran. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface ARModel : SCNNode

@property (nonatomic, copy) NSString* id;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* brand;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat level;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL isLocked;

- (instancetype)initWithObj:(NSString*)obj withMaterial:(NSString*)url2 position:(SCNVector3)position;
- (void)remove;

- (void)showDimension;
- (void)hideDimension;
- (void)updateDimension;

- (void)showBasement;
- (void)hideBasement;

- (void)showBox;
- (void)hideBox;

@end

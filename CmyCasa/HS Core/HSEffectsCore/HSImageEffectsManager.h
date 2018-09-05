//
//  HSImageEffectsManager.h
//  HSMacawDemo
//
//  Created by Berenson Sergei on 10/10/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HSImageEffectsInstanceProtocol <NSObject>

-(NSInteger)getNumberOfAvailableEffects;
-(id)getEffectAtIndex:(NSInteger)effectIndex;
-(NSString*)getEffectNameAtIndex:(NSInteger)effectIndex;
-(UIImage*)applyEffect:(id)effect onImage:(UIImage*)in_image;


@end

@interface HSImageEffectsManager : NSObject



+ (instancetype)sharedInstance;

-(UIImage*)applyCurrentEffectOnImage:(UIImage*)in_image withEffectIndex:(NSInteger)effectIndex;

-(void)setupEffects:(NSMutableArray*)effects withDefaultEffect:(NSInteger)index;

-(NSInteger)getNumberOfCurrentEffects;

-(NSString*)getNameOfEffectAtIndex:(NSInteger)effectIndex;

-(BOOL)isAnyEffectInstanceActive;
@end

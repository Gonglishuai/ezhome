//
//  HSImageEffectsManager.m
//  HSMacawDemo
//
//  Created by Berenson Sergei on 10/10/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import "HSImageEffectsManager.h"
@interface HSImageEffectsManager()


@property (nonatomic, strong) id<HSImageEffectsInstanceProtocol> currentEffect;
@property( nonatomic,strong) NSMutableArray * availableEffects;

@end

@implementation HSImageEffectsManager



static HSImageEffectsManager *sharedInstance = nil;


+ (instancetype)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[HSImageEffectsManager alloc] init];
        
    });
    
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.availableEffects=[NSMutableArray arrayWithCapacity:0];
    }
    return self;
}



-(UIImage*)applyCurrentEffectOnImage:(UIImage*)in_image  withEffectIndex:(NSInteger)effectIndex{
    
    if (!sharedInstance.currentEffect) {
        return in_image;
    }
    
    if (!in_image) {
        return in_image;
    }
    
    
    
  id effect=[sharedInstance.currentEffect getEffectAtIndex:effectIndex];
    
    if (effect) {
        UIImage * respImage= [sharedInstance.currentEffect applyEffect:effect onImage:in_image];
        
        return respImage;
    }
    
    return in_image;
}


-(NSInteger)getNumberOfCurrentEffects{
    
    if (self.currentEffect) {
        return [self.currentEffect getNumberOfAvailableEffects];
    }
    return 0;
}

-(NSString*)getNameOfEffectAtIndex:(NSInteger)effectIndex{
    
    
    if (self.currentEffect) {
        return [self.currentEffect getEffectNameAtIndex:effectIndex];
    }
    
    return @"";
    
}
#pragma mark- Effect initialization


-(void)setupEffects:(NSMutableArray*)effects withDefaultEffect:(NSInteger)index{
    
    [sharedInstance.availableEffects removeAllObjects];
    for (int i=0; i<[effects count]; i++) {
        id instance=[effects objectAtIndex:i];
        
        if ([instance conformsToProtocol:@protocol(HSImageEffectsInstanceProtocol)]) {
            [sharedInstance.availableEffects addObject:instance];
        }
    }
    
    if (index<[sharedInstance.availableEffects count]) {
        sharedInstance.currentEffect=[sharedInstance.availableEffects objectAtIndex:index];
    }else{
        if ([sharedInstance.availableEffects count]>0) {
            sharedInstance.currentEffect=[sharedInstance.availableEffects objectAtIndex:0];
        }else
            sharedInstance.currentEffect=nil;
        
    }
    
    
}


-(BOOL)isAnyEffectInstanceActive{
    
    return sharedInstance.currentEffect!=nil;
}


@end













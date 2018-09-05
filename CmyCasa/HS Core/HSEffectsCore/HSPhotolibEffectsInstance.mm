//
//  HSPhotolibEffectsInstance.m
//  Homestyler
//
//  Created by Itamar Berger on 10/15/13.
//
//

#import "HSPhotolibEffectsInstance.h"
#import "effects_composer.h"
#import "ios_opencv_conversions.h"
#import "NSString+JSONHelpers.h"

EffectsComposer effectsComposer;

@interface HSPhotolibEffectsInstance()


//@property (nonatomic, strong) EffectsComposer * effectsComposer;

@end



@implementation HSPhotolibEffectsInstance


-(id)init
{
    self= [super init];

    NSArray * files=  [[NSBundle mainBundle] pathsForResourcesOfType:@".png" inDirectory:@"assets/effects"];
    
    for (NSString* fullPath in files) {
        NSString* fileName = [[fullPath lastPathComponent] stringByDeletingPathExtension];
        
        NSArray* splitFileName = [fileName componentsSeparatedByString: @"-"];
        
        NSString* effectName = splitFileName[0];
        NSString* effectType = splitFileName[1];
        
        
        effectName=[effectName capitalizeFirstChar];
        std::string effectNameCppString([effectName cStringUsingEncoding:NSASCIIStringEncoding]);
        
        UIImage* palleteImg = [UIImage imageWithContentsOfFile:fullPath];
        cv::Mat palleteImageMat;
        ::UIImageToMat(palleteImg, palleteImageMat, true, 3);
        
        if ([effectType isEqualToString:@"map"])
        {
            effectsComposer.addColorEffectMap(palleteImageMat, effectNameCppString);
        }
        else if([effectType isEqualToString:@"lut"])
        {
            effectsComposer.addColorEffectLUT(palleteImageMat, effectNameCppString);
        }
    }
    
    return  self;
}


-(NSInteger)getNumberOfAvailableEffects{
    return effectsComposer.getNumberOfAvailableEffects();
}

-(id)getEffectAtIndex:(NSInteger)effectIndex{
    
    if (effectIndex<effectsComposer.getNumberOfAvailableEffects()) {
        return [NSNumber numberWithInteger:effectIndex];
    }
    
    return nil;
}

-(UIImage*)applyEffect:(id)effect onImage:(UIImage*)in_image
{
    if (!in_image)
        return in_image;

    cv::Mat inImageMat, afterEffectMatImage;
    ::UIImageToMat(in_image, inImageMat, true, 3);

    afterEffectMatImage.create(inImageMat.size(), inImageMat.type());
    effectsComposer.applyEffect((int)[effect integerValue],inImageMat,afterEffectMatImage,0.8);
    
    UIImage* result = MatToUIImage(afterEffectMatImage);
    afterEffectMatImage.release();

    return result;
}



-(NSString*)getEffectNameAtIndex:(NSInteger)effectIndex{

    
    std::string name = effectsComposer.getEffectNameAtIndex((int)effectIndex);

    NSString *effectName = [NSString stringWithCString:name.c_str()
                                                encoding:[NSString defaultCStringEncoding]];
    
    return effectName;
}
@end
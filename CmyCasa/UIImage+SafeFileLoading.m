//
//  UIImage+SafeFileLoading.m
//  Homestyler
//
//  Created by Or Sharir on 5/30/13.
//
//

#import "UIImage+SafeFileLoading.h"

@implementation UIImage (SafeFileLoading)
+(UIImage*)safeImageWithContentsOfFile:(NSString*)file{
    
    NSData * data=[NSData dataWithContentsOfFile:file];
    //check jpg/png file types
    
    if ([file hasSuffix:@".png"] && [ConfigManager isPNGImageValid:data]==false) {
        return nil;
        
    }
    
    if ([file hasSuffix:@".jpg"] && [ConfigManager isJPGImageValid:data]==false) {
        return nil;
        
    }

    return [UIImage imageWithData:data];
}

+ (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}
@end

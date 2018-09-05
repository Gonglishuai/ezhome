//
//  NSString+ImageResizer.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/24/13.
//
//

#import "NSString+ImageResizer.h"

@implementation NSString (ImageResizeUrl)
-(NSString*)generateImageURLforWidth:(int)width andHight:(int)height  andVersion:(NSString*) version
{
    if([[ConfigManager sharedInstance]getMainConfigDict]!=nil){
        
        
        if ([[ConfigManager sharedInstance] isCloudinaryImageCacheUsed]) {
            return [self generateImageURLforWidth:width andHight:height];
        }
    }
    if (version==nil) {
       return [self generateImageURLforWidth:width andHight:height]; 
    }
    
    return [NSString stringWithFormat:@"%@&s=%@",[self generateImageURLforWidth:width andHight:height],version];
}

-(NSString*)generateImagePathForWidth:(int)width andHight:(int)height{
    if([[ConfigManager sharedInstance]getMainConfigDict]!=nil){
        NSString * _filename=[self lastPathComponent];
        NSRange lastComma = [_filename rangeOfString:@"." options:NSBackwardsSearch];
        
        if(lastComma.location != NSNotFound) {
           
            if ([[ConfigManager sharedInstance] isCloudinaryImageCacheUsed]) {
                
                
                _filename = [_filename stringByReplacingCharactersInRange:lastComma
                                                               withString:[NSString stringWithFormat:@"_%@_%@.",[NSString stringWithFormat:@"%d",width],[NSString stringWithFormat:@"%d",height]]];
             
                
            }else{
                //tshirt size mechanism
                
                NSString * tshirtPart=[[ConfigManager sharedInstance] findCorrectTShirtSizeForWidth:width andHeight:height];
                //no tshirt size found
                
                if ([tshirtPart isEqualToString:@""]==false) {
                    _filename = [_filename stringByReplacingCharactersInRange:lastComma
                                                                   withString:[NSString stringWithFormat:@"_%@_%@_%@.",[NSString stringWithFormat:@"%d",width],[NSString stringWithFormat:@"%d",height],tshirtPart]];
                    
                }else
                {
                    _filename = [_filename stringByReplacingCharactersInRange:lastComma
                                                                   withString:[NSString stringWithFormat:@"_%@_%@.",[NSString stringWithFormat:@"%d",width],[NSString stringWithFormat:@"%d",height]]];
                    
                }
            }
           
            
            
            
            
            
            
            
                NSString * pathOnly=[self stringByReplacingOccurrencesOfString:[self lastPathComponent] withString:@""];
                
                return [NSString stringWithFormat:@"%@%@",pathOnly,_filename];
                
            
        }else
            return self;
        
     }else
    
        return self;
   
}

- (NSString *)addSmartfitSuffix
{
    return [NSString stringWithFormat:@"%@&crop=smartfit",self];
}

-(NSString*)generateImageURLforWidth:(int)width andHight:(int)height{
   
    
    
     if([[ConfigManager sharedInstance]getMainConfigDict]!=nil){
        
         
         if ([[ConfigManager sharedInstance] isCloudinaryImageCacheUsed]) {
             NSString * baseurl= [[ConfigManager sharedInstance] couldinaryBaseURL];
             
             baseurl=[baseurl stringByReplacingOccurrencesOfString:@"{{W}}" withString:[NSString stringWithFormat:@"%d",width]];
             baseurl=[baseurl stringByReplacingOccurrencesOfString:@"{{H}}" withString:[NSString stringWithFormat:@"%d",height]];
             
             
             return [NSString stringWithFormat:@"%@%@",baseurl,self];
         }else{
             //tshirt size mechanism
             if ([self  rangeOfString:@"?"].location != NSNotFound)
             {
                 return self;
                 
             }
            
             NSString * tshirtPart=[[ConfigManager sharedInstance] findCorrectTShirtSizeForWidth:width andHeight:height];
             //no tshirt size found
             if ([tshirtPart isEqualToString:@""]) {
                 return self;
             }
             
             NSString * _filename=[self lastPathComponent];
             
             NSRange lastComma = [_filename rangeOfString:@"." options:NSBackwardsSearch];
             
             if(lastComma.location != NSNotFound) {
                 _filename = [_filename stringByReplacingCharactersInRange:lastComma
                                                    withString:[NSString stringWithFormat:@"_%@.",tshirtPart]];
             }else
                 return self;
             
             
             NSString * baseurl= [[ConfigManager sharedInstance] tsBaseURL];
             
             
             
             NSString * pathOnly=[self stringByReplacingOccurrencesOfString:[self lastPathComponent] withString:@""];
             
             return [NSString stringWithFormat:@"%@%@%@?w=%d&h=%d",baseurl,pathOnly,_filename,width,height];
             
         }
         
        
        
    }else
    {
        return self;
    }
    
    
}

-(NSString*)generateImageURLWithEncodingForWidth:(int)width andHight:(int)height{
    
    
    
    if([[ConfigManager sharedInstance]getMainConfigDict]!=nil){
        
        
        if ([[ConfigManager sharedInstance] isCloudinaryImageCacheUsed]) {
            NSString * baseurl= [[ConfigManager sharedInstance] couldinaryBaseURL];
            
            baseurl=[baseurl stringByReplacingOccurrencesOfString:@"{{W}}" withString:[NSString stringWithFormat:@"%d",width]];
            baseurl=[baseurl stringByReplacingOccurrencesOfString:@"{{H}}" withString:[NSString stringWithFormat:@"%d",height]];
            
            
            return [NSString stringWithFormat:@"%@%@",baseurl,self];
        }else{
            //tshirt size mechanism
            if ([self  rangeOfString:@"?"].location != NSNotFound)
            {
                return self;
                
            }
            
            NSString * tshirtPart=[[ConfigManager sharedInstance] findCorrectTShirtSizeForWidth:width andHeight:height];
            //no tshirt size found
            if ([tshirtPart isEqualToString:@""]) {
                return self;
            }
            
            NSString * _filename=[self lastPathComponent];
            
            NSRange lastComma = [_filename rangeOfString:@"." options:NSBackwardsSearch];
            
            if(lastComma.location != NSNotFound) {
                _filename = [_filename stringByReplacingCharactersInRange:lastComma
                                                               withString:[NSString stringWithFormat:@"_%@.",tshirtPart]];
            }else
                return self;
            
            
            NSString * baseurl= [[ConfigManager sharedInstance] tsBaseURL];
            
            
            
            NSString * pathOnly=[self stringByReplacingOccurrencesOfString:[self lastPathComponent] withString:@""];
            
            
            NSString* url =  [NSString stringWithFormat:@"%@%@?w=%d&h=%d", pathOnly,_filename,width,height];
            
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (CFStringRef)url,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 ));
            
            return [NSString stringWithFormat:@"%@%@",baseurl, encodedString];
            
        }
        
        
        
    }else
    {
        return self;
    }
    
    
}


@end


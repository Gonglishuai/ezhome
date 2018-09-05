//
// Created by Berenson Sergei on 12/31/13.
//


#import "FileFactoryGenerator.h"


@implementation FileFactoryGenerator {

}


- (BOOL)isUniqueFileName:(NSString *)string {
    
    NSString * filepart;
     NSRange  range=[string rangeOfString:@"." options:NSBackwardsSearch];
    
    if (range.location != NSNotFound && [string length]>=range.location-1)
    {
        filepart=[ string substringToIndex:range.location-1];
        if([filepart length]>4)
        {
            return YES;
        }
    }
    
    return NO;

}

- (NSString *)getFileNamePartFromURL:(NSString *)string {
    if (!string || [string length]==0) {
        return @"";
    }
    
    //this is one of the servers' urls that we know how to get the filename from
    NSString *strDesigns =[[ConfigManager sharedInstance] designsBaseDomain];
    NSString *strAssets =[[ConfigManager sharedInstance] assetsBaseDomain];
    if(([string rangeOfString:strDesigns options:NSCaseInsensitiveSearch].location!=NSNotFound) || ([string rangeOfString:strAssets options:NSCaseInsensitiveSearch].location!=NSNotFound)){
        return [[string componentsSeparatedByString:@"/"] lastObject];
    }
    //HSMDebugLog(@"Can't find Filename part of url: %@",string);
    //by default, for unknown formats like Facebook, the filename is the whole url
    return string;
}

- (NSString *)getLegacyFileNamePartFromURL:(NSString *)string {
    if (!string || [string length]==0) {
        return @"";
    }
    
    NSArray *arrComps = [string componentsSeparatedByString:@"/"];
    if ([arrComps count] > 2)
    {
        NSString *strCompFirst = [arrComps objectAtIndex:arrComps.count-3];
        NSString *strCompScnd = [arrComps objectAtIndex:arrComps.count-2];
        NSString *strCompLast = [arrComps objectAtIndex:arrComps.count-1];
        
        if (strCompFirst && strCompLast)
        {
            return [NSString stringWithFormat:@"%@_%@_%@", strCompFirst, strCompScnd, strCompLast];
        }
    }
    
    if ([arrComps count] > 1)
    {
        NSString *strCompFirst = [arrComps objectAtIndex:arrComps.count-2];
        NSString *strCompLast = [arrComps objectAtIndex:arrComps.count-1];
        
        if (strCompFirst && strCompLast)
        {
            return [NSString stringWithFormat:@"%@_%@", strCompFirst, strCompLast];
        }
    }
    
    return @"";
}

/*FileFactory class is missing the local path generation methods.
From now and on server will return unique file names of image urls  like :https://hsm-designs.s3.amazonaws.com/eHoeaqZ0m3/b_mJyE-9enTkapvK1zcyEq3Q.jpg
But still there are old urls such as : http://hsm-prod-designs.S3.amazonaws.com/mXxYK5MTd0/f.jpg
For non unique urls the local path file name should be unique. For example  if file is f.jpg it should be translated to mXxYK5MTd0_f.jpg (taking into file name the last path part of url)
Files can be saved on disk in different folders (just keep the existing folders as we use now)*/
- (NSString *)getLocalFilePathFromURL:(NSString *)strUrl withImageSize:(CGSize)size
{    
    NSString *strFilename = [self getFileNamePartFromURL:strUrl];
    
    if ((strFilename == nil) || (strFilename.length == 0))
    {
        return nil;
    }
    
    if ([self isUniqueFileName:strFilename])
    {
        strFilename = [self addSize:size toFileName:strFilename];
        return strFilename;
    }
    
    strFilename = [self getLegacyFileNamePartFromURL:strUrl];
    
    if ((strFilename == nil) || (strFilename.length == 0))
    {
        return nil;
    }
    
    strFilename = [self addSize:size toFileName:strFilename];
    
    return strFilename;
}

- (NSString *)addSize:(CGSize)size toFileName:(NSString *)filename
{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return filename;
    }
    NSRange dotRange = [filename rangeOfString:@"." options:NSBackwardsSearch];
    if (dotRange.location != NSNotFound)
    {
        filename = [filename stringByReplacingCharactersInRange:dotRange withString:[NSString stringWithFormat:@"_%.0f_%.0f.", size.width, size.height]];
    }
    else
    {
        filename = [filename stringByAppendingString:[NSString stringWithFormat:@"_%.0f_%.0f", size.width, size.height]];
    }
    
    return filename;
}

- (NSString *)getURLPathPartFromUrl:(NSString *)url {
    
    NSString * filePart=[self getFileNamePartFromURL:url];
    
    NSRange range=[url rangeOfString:filePart options:NSBackwardsSearch];
    
    
    
    return [url substringToIndex:range.location];
}


- (NSString *)getFileNameExtensionFromURL:(NSString *)url {

    NSString *filename=[self getFileNamePartFromURL:url];
    NSRange range=[filename rangeOfString:@"." options:NSBackwardsSearch];
    
    NSString *strExt = @"";
    
    if (range.location != NSNotFound)
    {
        strExt = [filename substringFromIndex:range.location+1];
        if ([strExt rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\\/*%#[]=_"]].location == NSNotFound)
        {
            return strExt;
        }
    }

    return @"";
}

- (NSString *)createNewFilName:(NSString *)url withSize:(CGSize)size smartfit:(BOOL)smartfit {
    NSString * filename=[self getFileNamePartFromURL:url];
    NSString * ext=[self getFileNameExtensionFromURL:url];
    NSString * originalFilename=[NSString stringWithString:filename];
    if (ext.length > 0)
    {
        filename=[filename stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",ext] withString:@""];
    }
    
    if (CGSizeEqualToSize(size,CGSizeZero))
    {
        if (smartfit == YES)
        {
            return [NSString stringWithFormat:@"%@_smartfit.%@",filename,ext];
        }
        else
        {
            return originalFilename;
        }
    }else
    {
        if (smartfit == YES)
        {
            return [NSString stringWithFormat:@"%@_w%.0f_h%.0f_smartfit.%@",filename,size.width,size.height,ext] ;
        }
        else
        {
            return [NSString stringWithFormat:@"%@_w%.0f_h%.0f.%@",filename,size.width,size.height,ext] ;
        }
    }
}

- (NSString *)createCloudURLWithoutResizing:(NSString *)url{
   
    //url = [url lowercaseString];
    //1. create cloud base url
    NSString * cloudDomain=[self replaceDomainPartToCorrectCloud:url];
    //2. update file name
    NSString * newFileName=[self createNewFilName:cloudDomain withSize:CGSizeZero smartfit:NO];
    
    //3. add resized part to url
    
    NSString * urlPath=[self getURLPathPartFromUrl:cloudDomain];
    
    
    
    return [NSString stringWithFormat:@"%@%@",urlPath,newFileName];

}

- (NSString *)createCloudURL:(NSString *)url withSize:(CGSize)size smartfit:(BOOL)smartfit {
    
    //debug
    //url = @"https://graph.facebook.com/100001030441561/picture";
    
    //url = [url lowercaseString];
    //2. update file name
    NSString * newFileName=[self createNewFilName:url withSize:size smartfit:smartfit];
    
    //3. add resized part to url
    
    NSString * urlPath=[self getURLPathPartFromUrl:url];
   
    
    //1. create cloud base url
    NSString * cloudDomain=[self replaceDomainPartToCorrectCloud:urlPath];
  
    NSString *finalUrl = [NSString stringWithFormat:@"%@resized/%@",cloudDomain,newFileName];
    
    return finalUrl;
}



- (NSString *)replaceDomainPartToCorrectCloud:(NSString *)url {

    //http://hsm-dev-cms.S3.amazonaws.com/74aebe3a-1e03-4f9c-b232-ade974fa8890.jpg”
    
    NSString * replacement=@"";
    NSString * domainPart=@"s3.amazonaws.com";
    if([[url lowercaseString] rangeOfString:@"designs.s3.amazonaws.com"].location!=NSNotFound){
        //
        replacement=[[ConfigManager sharedInstance] designsCloudURL];


    }
    if([[url lowercaseString]rangeOfString:@"modellers-assets.s3.amazonaws.com"].location!=NSNotFound)
    {
        replacement=[[ConfigManager sharedInstance] modellersAssetsCloudURL];
    }
    else if([[url lowercaseString]rangeOfString:@"assets.s3.amazonaws.com"].location!=NSNotFound)
    {
        replacement=[[ConfigManager sharedInstance] assetsCloudURL];
    }

  

    
    
    NSRange range=[[url lowercaseString] rangeOfString:domainPart];

    NSString * newurl = @"";
    NSString *finalUrl = @"";
    if (range.location != NSNotFound)
    {
        newurl = [url substringFromIndex:range.location+[domainPart length]];
        finalUrl = [NSString stringWithFormat:@"https://%@%@",replacement,newurl];
    }
    else
    {
        finalUrl = url;
    }

    return finalUrl;
}

- (BOOL)isValidServerUrl:(NSString *)url
{
    return ([[url lowercaseString] rangeOfString:@"designs.s3.amazonaws.com"].location!=NSNotFound) || ([[url lowercaseString]rangeOfString:@"assets.s3.amazonaws.com"].location!=NSNotFound);
}

- (NSString *)createUrl:(NSString *)url withSize:(CGSize)size{
    return nil;
}

@end



//
//  NSObject+MultiShare.m
//  Homestyler
//
//  Created by Ma'ayan on 10/28/13.
//
//

#import "NSObject+MultiShare.h"
#import <objc/runtime.h>
#import "ServerUtils.h"

@implementation NSObject (MultiShare)

#pragma mark - Core Sharing
- (void)startSharingProccessWithMessage:(HSShareObject*)shareObj
{
    void (^openShareViewControllerBlock) (void) = ^
    {
        shareObj.designShareLink = (NSString*)[self _multiShareShareUrl];
        NSLog(@"designShareLink %@", shareObj.designShareLink);
        shareObj.pictureURL = [self _multiShareImageUrl];

        [self doShareWithText:shareObj];
        
        [self didFinishPreparingForShare];
    };
    
    NSString *orignalUrl = shareObj.designShareLink;
    NSString * url = [self _multiShareShareUrl];
    NSString * pervObjUrl = @"";

    if (url) {
        pervObjUrl = url;
    }
    
    BOOL isSameUrl = ([orignalUrl isEqualToString:pervObjUrl]) ? YES : NO;
    
    if ([self _multiShareImageUrl] && [self _multiShareShareUrl] && isSameUrl){
        openShareViewControllerBlock();
    }else{
        //need to upload the image
        [self updateImage:shareObj.picture
                   andUrl:shareObj.designShareLink
           andShareObject:shareObj
      withCompletionBlock:openShareViewControllerBlock];
    }
}

- (void)updateImage:(UIImage *)img andUrl:(NSString *)strUrl andShareObject:(HSShareObject*)shareObj withCompletionBlock:(void (^)(void))block
{
    void (^shortenUrlBlock) (void) = ^
    {
        [self updateUrl:strUrl andShareObject:shareObj withCompletionBlock:block];
    };
    
    if (!shareObj.pictureURL) {
        [self updateImage:img andShareObject:shareObj withCompletionBlock:shortenUrlBlock];
    }else{
        [self set_multiShareImageUrl:shareObj.pictureURL];
        shortenUrlBlock();
    }
}

- (void)updateImage:(UIImage *)img andShareObject:(HSShareObject*)shareObj withCompletionBlock:(void (^)(void))block
{
    [[ServerUtils sharedInstance] uploadImage:img andParmaters:nil andComplitionBlock:^(id serverResponse, id error)
     {
         if ((error == nil) && (serverResponse != nil))
         {
             if (!shareObj.pictureURL) {
                 shareObj.pictureURL=[NSURL URLWithString:(NSString *) serverResponse];
             }
             [self set_multiShareImageUrl:[NSURL URLWithString:(NSString *) serverResponse]];
         }
         
         block();
     }];
}

- (void)updateUrl:(NSString *)strUrl  andShareObject:(HSShareObject*)shareObj  withCompletionBlock:(void (^)(void))block
{
    [self set_multiShareShareUrl:strUrl];
    shareObj.designShareLink=strUrl;
    block();
}

#pragma mark - Private iVars

- (void)set_multiShareImageUrl:(NSURL *)value
{
    objc_setAssociatedObject(self, "_multiShareImageUrl", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)_multiShareImageUrl
{
    return objc_getAssociatedObject(self, "_multiShareImageUrl");
}

- (void)set_multiShareShareUrl:(NSString *)value
{
    objc_setAssociatedObject(self, "_multiShareShareUrl", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)_multiShareShareUrl
{
    return objc_getAssociatedObject(self, "_multiShareShareUrl");
}

#pragma mark - Supportive

- (NSString *)stringFromItemType:(ItemType)type
{
    NSString *strType = @"";
    
    switch (type) {
        case eArticle:
            strType = @"3";
            break;
        case e2DItem:
            strType = @"2";
            break;
        case e3DItem:
            strType = @"1";
            break;
        default:
            strType = @"1";
            break;
    }
    
    return strType;
}

#pragma mark - Overrideables
- (void)didStartPreparingForShare
{
    
}

- (void)didFinishPreparingForShare
{
    
}

- (void)doShareWithText:(HSShareObject*)shareObj
{
    
}

@end

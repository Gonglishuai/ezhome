//
// Created by Berenson Sergei on 12/31/13.
//


#import <Foundation/Foundation.h>


@interface FileFactoryGenerator : NSObject


- (NSString *)createUrl:(NSString *)url withSize:(CGSize)size;

- (NSString *)createCloudURLWithoutResizing:(NSString *)url;

- (BOOL)isUniqueFileName:(NSString *)string;

- (NSString *)getFileNamePartFromURL:(NSString *)string;

- (NSString *)getLocalFilePathFromURL:(NSString *)strUrl withImageSize:(CGSize)size;

- (NSString *)getURLPathPartFromUrl:(NSString *)url;

- (NSString *)getFileNameExtensionFromURL:(NSString *)url;

- (NSString *)createNewFilName:(NSString *)url withSize:(CGSize)size smartfit:(BOOL)smartfit ;

- (NSString *)createCloudURL:(NSString *)url withSize:(CGSize)size smartfit:(BOOL)smartfit;

- (NSString *)replaceDomainPartToCorrectCloud:(NSString *)url;

- (BOOL)isValidServerUrl:(NSString *)url;

@end
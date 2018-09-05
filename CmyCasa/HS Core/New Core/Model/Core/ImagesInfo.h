//
//  ImagesInfo.h
//  Homestyler
//
//  Created by Yiftach Ringel on 02/07/13.
//
//

#import "BaseResponse.h"

@interface ImagesResponse : BaseResponse

@property (strong, nonatomic) NSArray* images;

@end

@interface ImageInfo : NSObject <RestkitObjectProtocol>

@property (strong, nonatomic) NSString* imageId;
@property (strong, nonatomic) NSString* url;
@property (nonatomic) BOOL needClearCache;

@end

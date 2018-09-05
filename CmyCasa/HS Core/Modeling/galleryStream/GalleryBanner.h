//
//  GalleryBanner.h
//  EZHome
//
//  Created by xiefei on 31/10/17.
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"

@interface GalleryBanneItem : BaseResponse
@property(nonatomic,strong) NSString * link;
@property(nonatomic,strong) NSString * image;
@end

@interface GalleryBanner : BaseResponse <RestkitObjectProtocol>
@property(nonatomic,strong) NSMutableArray * image_link;

@end

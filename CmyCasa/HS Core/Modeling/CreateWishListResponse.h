//
//  CreateWishListResponse.h
//  Homestyler
//
//
//

#import "BaseResponse.h"

@interface CreateWishListResponse : BaseResponse

@property (nonatomic, strong) NSString * wishlistId;
@property (nonatomic, strong) NSString * wishlistName;
@property (nonatomic, strong) NSString * wishlistDescription;
@property (nonatomic, strong) NSString * wishlistProductCount;

@end

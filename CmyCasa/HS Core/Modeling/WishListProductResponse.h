//
//  WishListProductResponse.h
//  Homestyler
//
//
//

#import "BaseResponse.h"

@interface WishListProductResponse : BaseResponse

@property (nonatomic,copy) NSString * wishlistId;
@property (nonatomic,copy) NSString * wishlistName;
@property (nonatomic,copy) NSString * wishlistDescription;
@property (nonatomic,copy) NSString * wishlistProductCount;
@property (nonatomic,copy) NSMutableArray * wishListProducts;

@end

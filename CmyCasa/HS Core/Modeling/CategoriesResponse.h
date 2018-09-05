//
//  CategoriesResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/2/13.
//
//

#import "BaseResponse.h"

@interface CategoriesResponse : BaseResponse



@property(nonatomic,copy) NSMutableArray    *topLevelCategories;
@property(nonatomic,copy) NSDictionary      *allCategories;


@end

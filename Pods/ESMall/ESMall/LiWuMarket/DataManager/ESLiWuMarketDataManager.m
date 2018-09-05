//
//  ESLiWuMarketDataManager.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLiWuMarketDataManager.h"
#import "ESCaseAPI.h"

@implementation ESLiWuMarketDataManager

+ (void)getLiWuHomeDataWithSuccess:(void(^)(ESLiWuHomeModel *model))success
                        andFailure:(void(^)(void))failure {
    [ESCaseAPI getLiWuMarketHomeSuccess:^(NSDictionary *dict) {
        ESLiWuHomeModel *homeModel = [ESLiWuHomeModel objFromDict:dict];
        if (success) {
            success(homeModel);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (NSInteger)getCategoryNumsWithModel:(ESLiWuHomeModel *)homeModel {
    @try {
        return homeModel.category.count;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return 0;
    }
}

+ (NSInteger)getProductNumsWithModel:(ESLiWuHomeModel *)homeModel {
    @try {
        return homeModel.product.elementList.count;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return 0;
    }
}

+ (ESLiWuCategoryModel *)getCategoryWithModel:(ESLiWuHomeModel *)homeModel andIndex:(NSInteger)index {
    @try {
        ESLiWuCategoryModel *model = [homeModel.category objectAtIndex:index];
        return model;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}

+ (ESCMSModel *)getProductWithModel:(ESLiWuHomeModel *)homeModel andIndex:(NSInteger)index {
    @try {
        ESCMSModel *model = [homeModel.product.elementList objectAtIndex:index];
        return model;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}

+ (NSArray <NSString *>*)getLoopImageUrlsWithModel:(ESLiWuHomeModel *)homeModel {
    NSMutableArray *urls = [NSMutableArray array];
    @try {
        for (ESCMSModel *model in homeModel.banner) {
            [urls addObject:model.extend_dic.image];
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    } @finally {
        return urls;
    }
}

+ (ESCMSModel *)getBannerWithModel:(ESLiWuHomeModel *)homeModel andIndex:(NSInteger)index {
    @try {
        ESCMSModel *model = [homeModel.banner objectAtIndex:index];
        return model;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}
@end

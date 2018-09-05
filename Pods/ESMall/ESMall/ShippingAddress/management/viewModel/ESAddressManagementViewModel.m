//
//  ESAddressManagementViewModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESAddressManagementViewModel.h"

@implementation ESAddressManagementViewModel

+ (void)retrieveAddressListWithSuccess: (void(^)(NSArray <ESAddress *> *))success
                            andFailure: (void(^)(NSString *msg))failure {
    
    [ESAddrerssAPI getAddressListWithSuccess:^(NSArray *array) {
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSDictionary *dic in array) {
            ESAddress *addr = [ESAddress objFromDict:dic];
            [arr addObject:addr];
        }
        
        if (success) {
            success(arr);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure(@"网络崩溃了");
        }
    }];
}

+ (ESAddress *)getAddressFromArray:(NSArray *)array withIndex:(NSInteger)index {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        return addr;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return nil;
    }
}

+ (NSString *)getAddressNameFromArray:(NSArray *)array
                            withIndex:(NSInteger)index {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        return addr.name;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getAddressPhoneFromArray:(NSArray *)array
                             withIndex:(NSInteger)index {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        return addr.phone;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getAddressDetailFromArray:(NSArray *)array
                              withIndex:(NSInteger)index {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        NSString *detail = [NSString stringWithFormat:@"%@ %@ %@ %@", addr.province, addr.city, addr.district, addr.addressInfo];
        return detail;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (BOOL)isDefaultAddressFromArray:(NSArray *)array
                        withIndex:(NSInteger)index {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        return addr.isPrimary;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return false;
    }
}

+ (void)setDefaultAddressFromArray:(NSArray *)array
                         withIndex:(NSInteger)index
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(void))failure {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        for (ESAddress *temp in array) {
            if (temp.isPrimary) {
                temp.isPrimary = NO;
            }
        }
        addr.isPrimary = YES;
        
        [ESAddrerssAPI setDefaultAddressWithAddressID:addr.addressId withSuccess:^{
            if (success) {
                success();
            }
        } andFailure:^(NSError *error) {
            if (failure) {
                failure();
            }
        }];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        if (failure) {
            failure();
        }
    }
}

+ (void)deleteAddressFromArray:(NSMutableArray *)array
                     withIndex:(NSInteger)index
                   withSuccess:(void(^)(BOOL shouldRefresh))success
                    andFailure:(void(^)(void))failure {
    @try {
        ESAddress *addr = [array objectAtIndex:index];
        BOOL refresh = addr.isPrimary;
        [ESAddrerssAPI deleteAddressWithAddressID:addr.addressId withSuccess:^{
            [array removeObject:addr];
            if (success) {
                success(refresh);
            }
        } andFailure:^(NSError *error) {
            if (failure) {
                failure();
            }
        }];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        if (failure) {
            failure();
        }
    }
}
@end

//
//  ESSelectAddrViewModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESSelectAddrViewModel.h"
#import "JRLocationServices.h"

@implementation ESSelectAddresses


@end

@implementation ESSelectAddrViewModel

+ (void)retrieveAddressListWithSuccess: (void(^)(NSArray <ESSelectAddresses *> *addressArray))success
                            andFailure: (void(^)(NSString *msg))failure {
    
    [ESAddrerssAPI getAddressListWithSuccess:^(NSArray *array) {
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSDictionary *dic in array) {
            ESAddress *addr = [ESAddress objFromDict:dic];
            [arr addObject:addr];
        }
        
        NSString *curCityCode = [JRLocationServices sharedInstance].locationCityInfo.cityCode;
        ESSelectAddresses *validAddr = nil;
        ESSelectAddresses *invalidAddr = nil;
        
        if (arr.count > 0) {
            for (ESAddress *addr in arr) {
                if ([addr.cityCode isEqualToString:curCityCode]) {
                    if (validAddr == nil) {
                        validAddr = [[ESSelectAddresses alloc] init];
                        validAddr.address = [NSMutableArray array];
                    }
                    validAddr.valid = YES;
                    [validAddr.address addObject:addr];
                }else {
                    if (invalidAddr == nil) {
                        invalidAddr = [[ESSelectAddresses alloc] init];
                        invalidAddr.address = [NSMutableArray array];
                    }
                    invalidAddr.valid = NO;
                    [invalidAddr.address addObject:addr];
                }
            }
        }
        
        NSMutableArray *result = [NSMutableArray array];
        if (validAddr) {
            [result addObject:validAddr];
        }
        if (invalidAddr) {
            [result addObject:invalidAddr];
        }
        
        
        if (success) {
            success(result);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure(@"网络崩溃了");
        }
    }];
}

+ (BOOL)getAddressValidFromArray:(NSArray *)array
                     withSection:(NSInteger)section {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        return selectedAddr.valid;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (NSInteger)getAddressNumsFromArray:(NSArray *)array
                         withSection:(NSInteger)section {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        return selectedAddr.address.count;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return 0;
    }
}

+ (ESAddress *)getSelectedAddrFromArray:(NSArray *)array
                            withSection:(NSInteger)section
                              withIndex:(NSInteger)index {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        ESAddress *addr = [selectedAddr.address objectAtIndex:index];
        return addr;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return nil;
    }
}

+ (NSString *)getAddressNameFromArray:(NSArray *)array
                          withSection:(NSInteger)section
                            withIndex:(NSInteger)index {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        ESAddress *addr = [selectedAddr.address objectAtIndex:index];
        return addr.name;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getAddressPhoneFromArray:(NSArray *)array
                           withSection:(NSInteger)section
                             withIndex:(NSInteger)index {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        ESAddress *addr = [selectedAddr.address objectAtIndex:index];
        return addr.phone;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getAddressDetailFromArray:(NSArray *)array
                            withSection:(NSInteger)section
                              withIndex:(NSInteger)index {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        ESAddress *addr = [selectedAddr.address objectAtIndex:index];
        NSString *detail = [NSString stringWithFormat:@"%@ %@ %@ %@", addr.province, addr.city, addr.district, addr.addressInfo];
        return detail;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (BOOL)isDefaultAddressFromArray:(NSArray *)array
                      withSection:(NSInteger)section
                        withIndex:(NSInteger)index {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        ESAddress *addr = [selectedAddr.address objectAtIndex:index];
        return addr.isPrimary;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (BOOL)isSelectedAddressFromArray:(NSArray *)array
                       withSection:(NSInteger)section
                         withIndex:(NSInteger)index
                     andSelectedId:(NSString *)selectedId {
    @try {
        ESSelectAddresses *selectedAddr = [array objectAtIndex:section];
        ESAddress *addr = [selectedAddr.address objectAtIndex:index];
        if (selectedId) {
            return [selectedId isEqualToString:addr.addressId];
        }
        
        return NO;
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (ESAddress *)getAddressWithId:(NSString *)addressId
                      fromArray:(NSArray *)array{
    @try {
        if (addressId == nil) {
            return nil;
        }
        for (ESSelectAddresses *selectedAddr in array) {
            if (selectedAddr.valid == YES) {
                for (ESAddress *addr in selectedAddr.address) {
                    if ([addr.addressId isEqualToString:addressId]) {
                        return addr;
                    }
                }
            }
        }
        return nil;
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return nil;
    }
}
@end

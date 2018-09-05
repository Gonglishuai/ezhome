//
//  ESAreaModel.m
//  Consumer
//
//  Created by shiyawei on 17/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendShareCustomer.h"

@interface ESRecommendShareCustomer ()

@end

@implementation ESRecommendShareCustomer

- (NSArray *)getHolderProvince {
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area"ofType:@"js"] encoding:NSUTF8StringEncoding error:&error];
    if (jsonString == nil) {
        return nil;
    }
    NSError *err = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData  options:NSJSONReadingMutableContainers error:&err];
    if (dic == nil) {
        return nil;
    }
    NSDictionary *provinceDic = [dic objectForKey:@"100000"];
    NSArray *keys = provinceDic.allKeys;
    NSArray *sortKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i = 0; i < sortKeys.count; i++) {
        [values addObject:provinceDic[sortKeys[i]]];
    }
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:sortKeys];
    [arr addObject:values];
    return arr;
}

- (NSArray *)getHolderCityWithProvinceCode:(NSString *)provinceCode {
    if (provinceCode == nil || provinceCode.length == 0) {
        return nil;
    }
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area"ofType:@"js"] encoding:NSUTF8StringEncoding error:&error];
    if (jsonString == nil) {
        return nil;
    }
    NSError *err = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData  options:NSJSONReadingMutableContainers error:&err];
    if (dic == nil) {
        return nil;
    }
    NSDictionary *provinceDic = [dic objectForKey:provinceCode];
    if (provinceDic == nil) {
        return nil;
    }
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:provinceDic.allKeys];
    [arr addObject:provinceDic.allValues];
    return arr;
}

- (NSArray *)getHolderDistrictWithProvinceCode:(NSString *)provinceCode cityCode:(NSString *)cityCode {
    if (provinceCode == nil || provinceCode.length == 0 || cityCode == nil || cityCode.length == 0) {
        return nil;
    }
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area"ofType:@"js"] encoding:NSUTF8StringEncoding error:&error];
    
    NSError *err = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData  options:NSJSONReadingMutableContainers error:&err];
    if (dic == nil) {
        return nil;
    }
    NSDictionary *districtDic = [dic objectForKey:cityCode];
    if (districtDic == nil || districtDic.count == 0) {
        return nil;
    }
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:districtDic.allKeys];
    [arr addObject:districtDic.allValues];
    return arr;
}
@end

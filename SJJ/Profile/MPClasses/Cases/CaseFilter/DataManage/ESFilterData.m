//
//  ESDesignFilterData.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilterData.h"

@implementation ESFilterData

+ (void)initFilterData:(NSArray *)tags
           withAllTags:(NSArray *)allTags
              withList:(NSMutableArray <ESFilter *> *)filterList
          withSelected:(NSMutableSet <ESFilterItem *> *)selectItems
            andRefresh:(void(^)(void))refresh {
    
    @try {
        for (NSDictionary *dic in allTags) {
            ESFilter *filter = [ESFilter objFromDict:dic];
            [filterList addObject:filter];
        }
        
        ///初始化筛选项
        if (tags && tags.count > 0) {
            
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            for (NSDictionary *dic in tags) {
                ESFilterItem *tag = [ESFilterItem objFromDict:dic];
                if (tag.type && tag.value) {
                    [mDic setObject:tag.value forKey:tag.type];
                }
            }
            
            for (ESFilter *filter in filterList) {
                NSString *tagValue = [mDic objectForKey:filter.type];
                if (tagValue) {
                    for (ESFilterItem *item in filter.tagsBeans) {
                        if ([item.value isEqualToString:tagValue]) {
                            [selectItems addObject:item];
                        }
                    }
                }
            }
        }else {
            for (ESFilter *filter in filterList) {
                [selectItems addObject:[filter.tagsBeans firstObject]];
            }
        }
        
    } @catch (NSException *exception) {
        SHLog(@"初始化案例筛选失败：%@", exception.description);
    }
    
}

+ (NSInteger)getTagsNum:(NSInteger)section
                andList:(NSMutableArray <ESFilter *> *)filterList {
    @try {
        ESFilter *filter = [filterList objectAtIndex:section];
        return filter.tagsBeans.count;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return 0;
    }
}

+ (void)selectTagWithSection:(NSInteger)section
                   withIndex:(NSInteger)index
                    withList:(NSMutableArray <ESFilter *> *)filterList
                 andSelected:(NSMutableSet <ESFilterItem *> *)selectItems {
    @try {
        ESFilter *filter = [filterList objectAtIndex:section];
        ESFilterItem *item = [filter.tagsBeans objectAtIndex:index];
        if ([selectItems containsObject:item]) {
            return;
        }else {
            for (ESFilterItem *selTag in selectItems) {
                if ([selTag.type isEqualToString:item.type]) {
                    [selectItems addObject:item];
                    [selectItems removeObject:selTag];
                    break;
                }
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (NSString *)getTagsHeader:(NSInteger)section
                    andList:(NSMutableArray <ESFilter *> *)filterList {
    @try {
        ESFilter *filter = [filterList objectAtIndex:section];
        return filter.name;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return @"";
    }
}

+ (NSString *)getTagTitle:(NSInteger)section
                withIndex:(NSInteger)index
                  andList:(NSMutableArray <ESFilter *> *)filterList {
    @try {
        ESFilter *filter = [filterList objectAtIndex:section];
        ESFilterItem *item = [filter.tagsBeans objectAtIndex:index];
        return item.name;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return @"";
    }
}

+ (BOOL)tagIsSelected:(NSInteger)section
            withIndex:(NSInteger)index
             withList:(NSMutableArray <ESFilter *> *)filterList
          andSelected:(NSMutableSet <ESFilterItem *> *)selectItems {
    @try {
        ESFilter *filter = [filterList objectAtIndex:section];
        ESFilterItem *item = [filter.tagsBeans objectAtIndex:index];
        return [selectItems containsObject:item];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return NO;
    }
}

+ (void)resetFilter:(NSMutableArray <ESFilter *> *)filterList
        andSelected:(NSMutableSet <ESFilterItem *> *)selectItems {
    @try {
        [selectItems removeAllObjects];
        for (ESFilter *filter in filterList) {
            [selectItems addObject:[filter.tagsBeans firstObject]];
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (NSArray *)getFilterResult:(NSMutableSet <ESFilterItem *> *)selectItems {
    @try {
        NSMutableArray *result = [NSMutableArray array];
        for (ESFilterItem *item in selectItems) {
            NSDictionary *dict = [ESFilterItem dictFromObj:item];
            [result addObject:dict];
        }
        return result;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}
@end

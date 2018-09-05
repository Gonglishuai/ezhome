
#import "MPCaseModel.h"
#import "MPTranslate.h"

@implementation MPCaseModel

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([@"is_new" isEqualToString:key])
    {
        if (value
            && ![value isKindOfClass:[NSNull class]])
        {
            NSString *str = [NSString stringWithFormat:@"%@",value];
            self.is_new = [str boolValue];
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        
        self.case_id = value;
    }
    else if ([key isEqualToString:@"description"]) {
        
        self.description_designercase = value;
    }
    else if ([key isEqualToString:@"designer_info"]) {
        
    }
    else if ([key isEqualToString:@"images"]) {
        
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self createModelWithDict:dict];
    }
    return self;
}

- (void)createModelWithDict:(NSDictionary *)dict {
    
    if (![dict isKindOfClass:[NSDictionary class]]) return;
    
    [self setValuesForKeysWithDictionary:dict];
    
    MPDesignerInfoModel *model = [[MPDesignerInfoModel alloc] initWithDictionary:dict[@"designer_info"]];
    self.designer_info = model;
    
    if ([dict[@"images"] isKindOfClass:[NSNull class]]) return;

    NSMutableArray *arrayImage = [NSMutableArray array];
    for (NSDictionary *dic in dict[@"images"]) {
        MPCaseImageModel *model = [[MPCaseImageModel alloc] initWithDictionary:dic];
        [arrayImage addObject:model];
    }
    self.images = (id)arrayImage;
}

- (NSString *)project_style {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_project_style lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_project_style:str;
}

- (NSString *)room_type {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_room_type lowercaseString]];
    
    return ([str isEqualToString:@"(null)"])?_room_type:str;
}

- (NSString *)bedroom {//_living _toilet
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[NSString stringWithFormat:@"%@_toilet",[_bedroom lowercaseString]]];
    
    return ([str isEqualToString:@"(null)"])?_bedroom:str;
}
- (NSString *)restroom {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[NSString stringWithFormat:@"%@_living", [_restroom lowercaseString]]];
    
    return ([str isEqualToString:@"(null)"])?_restroom:str;
}


//- (NSNumber *)room_area {
//    NSString *roomArea = [NSString stringWithFormat:@"%@_area",_room_area];
//    roomArea = [MPModel stringTypeEnglishToChineseWithString:roomArea];
//    return ([roomArea isEqualToString:@"(null)"])?_room_area:(id)roomArea;
//}

@end

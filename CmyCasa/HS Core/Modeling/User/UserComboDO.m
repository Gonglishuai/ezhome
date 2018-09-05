//
//  UserComboDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "UserComboDO.h"

@implementation UserComboDO


+ (RKObjectMapping*)jsonMapping
{
    
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"id" : @"comboId",
       @"desc" : @"comboName"
       }];
    
    
    return entityMapping;
}
-(void)applyPostServerActions{
    
    
    
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self=[super init];

    self.comboId=[aDecoder decodeObject];
    self.comboName=[aDecoder decodeObject];

    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.comboId];
    [aCoder encodeObject:self.comboName];

}
- (id)copyWithZone:(NSZone *)zone {
    UserComboDO *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.comboId = [self.comboId copy];
        copy.comboName = [self.comboName copy];
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToADo:other];
}

- (BOOL)isEqualToADo:(UserComboDO *)aDo {
    if (self == aDo)
        return YES;
    if (aDo == nil)
        return NO;
    if (self.comboId != aDo.comboId && ![self.comboId isEqualToString:aDo.comboId])
        return NO;
    if (self.comboName != aDo.comboName && ![self.comboName isEqualToString:aDo.comboName])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.comboId hash];
    hash = hash * 31u + [self.comboName hash];
    return hash;
}

@end

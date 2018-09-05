//
//  ProfessionalsResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 9/18/13.
//
//

#import "ProfessionalsResponse.h"

@implementation ProfessionalsResponse


+ (RKObjectMapping*)jsonMapping{
    
    
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
    // @"id" : @"designIDnew"
     
     }];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                 toKeyPath:@"professionals"
                                               withMapping:[ProfessionalDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"pf"
                                                 toKeyPath:@"currentProfessional"
                                               withMapping:[ProfessionalDO jsonMapping]]];
    
    
    return entityMapping;
}

- (void)applyPostServerActions{
    
    for (int i=0; i<[self.professionals count]; i++) {
        [[self.professionals objectAtIndex:i] applyPostServerActions];
    }
    if (self.currentProfessional) {
        [self.currentProfessional applyPostServerActions];
    }
}
@end

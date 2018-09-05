//
//  UserCombosResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "UserCombosResponse.h"
#import "UserComboDO.h"

@implementation UserCombosResponse


-(instancetype)init{

    self=[super init];

    self.styles=[NSMutableArray array];
    self.profs=[NSMutableArray array];
    self.userTypes=[NSMutableArray array];
    self.tools=[NSMutableArray array];

    return  self;
}
+ (RKObjectMapping*)jsonMapping{

    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"prof"
                                                 toKeyPath:@"profs"
                                               withMapping:[UserComboDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"tools"
                                                 toKeyPath:@"tools"
                                               withMapping:[UserComboDO jsonMapping]]];
   
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"styles"
                                                 toKeyPath:@"styles"
                                               withMapping:[UserComboDO jsonMapping]]];
   
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"utype"
                                                 toKeyPath:@"userTypes"
                                               withMapping:[UserComboDO jsonMapping]]];

    [entityMapping addPropertyMapping:
            [RKRelationshipMapping relationshipMappingFromKeyPath:@"gender"
                                                        toKeyPath:@"genders"
                                                      withMapping:[UserComboDO jsonMapping]]];

    return entityMapping;
}
- (void)applyPostServerActions{
   //sort combo values by name

    
    
    if (self.userTypes) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"comboName" ascending:YES];
        [self.userTypes sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    if (self.styles) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"comboName" ascending:YES];
        [self.styles sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
 
    if (self.tools) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"comboName" ascending:YES];
        [self.tools sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }

    if (self.profs) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"comboName" ascending:YES];
        [self.profs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }

}

-(UserComboDO *)getMaleComboObject{

    for(UserComboDO * combo in self.genders){

        if([combo.comboName isEqualToString:@"M"])
        {
            return combo;
        }

    }
    return  nil;
}

-(UserComboDO *)getFemaleComboObject{
    for(UserComboDO * combo in self.genders){

        if([combo.comboName isEqualToString:@"F"])
        {
            return combo;
        }

    }
    return  nil;

}
-(UserComboDO *)getUnkonwnGenderObject{
    for(UserComboDO * combo in self.genders){

        if([combo.comboName isEqualToString:@"O"])
        {
            return combo;
        }

    }
    return  nil;
}

@end

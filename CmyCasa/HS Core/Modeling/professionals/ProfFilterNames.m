//
//  ProfFilterNames.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "ProfFilterNames.h"

@implementation ProfFilterNames
@synthesize locations;
@synthesize professions;


-(id)initWithDict:(NSArray * )dictList{
    self=[super init];
    
    self.locations=[NSMutableArray arrayWithCapacity:0];
    self.professions=[NSMutableArray arrayWithCapacity:0];
    
    
    
    ProfFilterNameItemDO * pfn1=[[ProfFilterNameItemDO alloc] init];
    
    pfn1.name=NSLocalizedString(@"prof_filter_all_key", @"");
    
    [self.professions addObject:pfn1];
    [self.locations addObject:pfn1];
    
    
    for (int i=0; i<[dictList count];i++) {
        NSArray * combo=[[dictList objectAtIndex:i] objectForKey:@"combo"];
        if ([[[dictList objectAtIndex:i] objectForKey:@"key"] isEqualToString:@"prof"]) {
            for (int j=0; j<[combo count]; j++) {
                ProfFilterNameItemDO * pfn=[[ProfFilterNameItemDO alloc] initWithDict:[combo objectAtIndex:j]];
                [self.professions addObject:pfn];
            }
            
        }
        
        if ([[[dictList objectAtIndex:i] objectForKey:@"key"] isEqualToString:@"loc"]) {
            for (int j=0; j<[combo count]; j++) {
                ProfFilterNameItemDO * pfn=[[ProfFilterNameItemDO alloc] initWithDict:[combo objectAtIndex:j]];
                [self.locations addObject:pfn];
            }
            
        }
    }
    return self;
}

-(BOOL)isFiltersReady{
    
    return  [self.locations count]>0 && [self.professions count]>0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}
@end

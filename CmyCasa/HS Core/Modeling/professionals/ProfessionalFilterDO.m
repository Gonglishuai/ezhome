//
//  ProfessionalFIlterDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/8/13.
//
//

#import "ProfessionalFilterDO.h"

@implementation ProfessionalFilterDO
@synthesize startIndex;
@synthesize count;
@synthesize professionFilter;
@synthesize locationFilter;
@synthesize professionals;

-(id)initWithStartIndex:(int)_startIndex withLimit:(int)limit forProfKey:(NSString*)profkey forLocKey:(NSString*)lockey{
    self=[super init];
    
    self.startIndex=[NSNumber numberWithInt:_startIndex];
    self.count=[NSNumber numberWithInt:limit];
    self.professionFilter=profkey;
    self.locationFilter=lockey;
    self.professionals=[NSMutableArray arrayWithCapacity:0];
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

@end

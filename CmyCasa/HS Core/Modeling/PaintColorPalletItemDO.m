//
//  PaintColorPalletItemDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "PaintColorPalletItemDO.h"
#import "PaintColorDO.h"

@interface PaintColorPalletItemDO ()


@property(nonatomic)NSMutableArray * paintColors;
@property(nonatomic)NSString * categoryID;
@end
@implementation PaintColorPalletItemDO


-(id)initWithDict:(NSDictionary*)dict{
    self=[super init];
    
    self.categoryID=[dict objectForKey:@"cat_id"];
    
    NSArray * list=[dict objectForKey:@"list"];
    
    self.paintColors=[NSMutableArray  arrayWithCapacity:0];
    
    
    for (int i=0; i<[list count]; i++) {
        PaintColorDO * p=[[PaintColorDO alloc] initWithDict:[list objectAtIndex:i]];
        [self.paintColors addObject:p];
    }
    
    return self;
}

-(NSArray*)getColorsForPallet{
    
    return (NSArray*)self.paintColors;
}
-(PaintColorDO*)getPaintColorObjectByName:(NSString*)name{
    
    for (PaintColorDO * p  in self.paintColors) {
        if ([p.colorID isEqualToString:name]) {
            return p;
        }
    }
    return nil;
}

@end

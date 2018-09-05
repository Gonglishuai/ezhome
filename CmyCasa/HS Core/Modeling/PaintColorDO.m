//
//  PaintColorDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "PaintColorDO.h"

@interface PaintColorDO ()

@property (nonatomic, readwrite) NSString * colorHex;
@property (nonatomic, readwrite) NSString * colorID;

@end
@implementation PaintColorDO

-(id)initWithDict:(NSDictionary*)dict{
    self=[super init];
    
    if (self) {
        self.colorHex = dict[@"color"];
        self.colorID = dict[@"title"];
    }
    
    return  self;
}
@end

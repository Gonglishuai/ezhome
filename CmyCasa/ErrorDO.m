//
//  ErrorDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 3/11/13.
//
//

#import "ErrorDO.h"

@implementation ErrorDO

-(id)initErrorWithDetails:(NSString*)msg withErrorCode:(HSServerErrorCode)errcode{
    self = [super init];
    if (self) {
        self.errorCode=errcode;
        self.message=msg;
        self.erroDatetime=[NSDate date];

    }
    return  self;
}

@end

//
//  HSViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/18/14.
//
//

#import "HSViewController.h"

@interface HSViewController ()

@end

@implementation HSViewController
@synthesize eventLoadOrigin= _eventLoadOrigin;


-(NSString*)eventLoadOrigin{
    return (_eventLoadOrigin)?_eventLoadOrigin:@"";
}


@end

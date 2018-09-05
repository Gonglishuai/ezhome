//
//  SaveReminderItem.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/5/13.
//
//

#import "SaveReminderItem.h"
#define  MAX_ITEMS_BEFORE_ALERT 10
#define  MAX_TIME_BEFORE_ALERT_SEC 180 
@implementation SaveReminderItem



-(void)resetCounters{
    self.lastAlertDate=nil;
    self.tickCount=0;
}
-(BOOL)updateCounter{
    
    self.tickCount++;
    BOOL status=false;
    if (self.tickCount>=MAX_ITEMS_BEFORE_ALERT) {
       
        if (self.lastAlertDate) {
            NSDate * now=[NSDate date];
            
            NSTimeInterval intrev=MAX_TIME_BEFORE_ALERT_SEC;
            
            NSDate * expdate=[self.lastAlertDate dateByAddingTimeInterval:intrev];
            
            
            if ([now compare:expdate]==NSOrderedDescending ) {
                self.lastAlertDate=[NSDate date];
                self.tickCount=0;
                status=YES;
            }
        }else{
            self.tickCount=0;
            self.lastAlertDate=[NSDate date];
            status=YES;
        }
        
                 
        
    }else
    {
        status=NO;
    }
    
return  status;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.tickCount = [coder decodeIntForKey:@"self.tickCount"];
        self.lastAlertDate = [coder decodeObjectForKey:@"self.lastAlertDate"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.tickCount forKey:@"self.tickCount"];
    [coder encodeObject:self.lastAlertDate forKey:@"self.lastAlertDate"];
}

- (id)copyWithZone:(NSZone *)zone {
    SaveReminderItem *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.tickCount = self.tickCount;
        copy.lastAlertDate = self.lastAlertDate;
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToItem:other];
}

- (BOOL)isEqualToItem:(SaveReminderItem *)item {
    if (self == item)
        return YES;
    if (item == nil)
        return NO;
    if (self.tickCount != item.tickCount)
        return NO;
    if (self.lastAlertDate != item.lastAlertDate && ![self.lastAlertDate isEqualToDate:item.lastAlertDate])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) self.tickCount;
    hash = hash * 31u + [self.lastAlertDate hash];
    return hash;
}

@end

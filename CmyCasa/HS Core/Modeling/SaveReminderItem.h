//
//  SaveReminderItem.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/5/13.
//
//

#import <Foundation/Foundation.h>

@interface SaveReminderItem : NSObject <NSCoding, NSCopying>


@property(nonatomic)NSInteger tickCount;
@property(nonatomic,strong)NSDate * lastAlertDate;

-(void)resetCounters;
-(BOOL)updateCounter;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToItem:(SaveReminderItem *)item;

- (NSUInteger)hash;
@end

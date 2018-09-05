//
//  AddrBookFriendDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "AddrBookFriendDO.h"
#import "NSString+EmailValidation.h"
#import "HelpersRO.h"
@implementation AddrBookFriendDO


+ (RKObjectMapping*)jsonMapping{
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
    
    
    
    return entityMapping;
}

- (void)applyPostServerActions{
    [super applyPostServerActions];
    self.socialFriendType=kSocialFriendNotSocial;
    
}


-(id)initWithContactFromAddressBook:(ABRecordRef)person{
    self=[super init];
    self.currentStatus=kFriendUnknown;
    
    NSString *displayName = (__bridge NSString *)ABRecordCopyCompositeName(person);
    
    if (displayName) {
        self.firstName=displayName;
    }
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
    
    if (emailAddresses && [emailAddresses count]>0) {
        NSString* _eml=[emailAddresses objectAtIndex:0];
        
        if (_eml && [_eml length]>0 && [_eml isStringValidEmail]) {
            self.email=_eml;
            self.hashedEmail=[HelpersRO encodeMD5:[self.email lowercaseString]];
        }
        
    }
    
    self.nsContactImageData= (__bridge NSData *)ABPersonCopyImageData(person);
    
    self.isFacebookFriend=NO;
    
    return self;
}
-(UIImage*)getLocalImage{
    
    if (self.nsContactImageData) {
        return [UIImage imageWithData:self.nsContactImageData];
    }
    return nil;
}


@end

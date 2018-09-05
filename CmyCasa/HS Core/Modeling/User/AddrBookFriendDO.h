//
//  AddrBookFriendDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "UserBaseFriendDO.h"

@interface AddrBookFriendDO : UserBaseFriendDO


@property(nonatomic,strong) NSData * nsContactImageData;

-(id)initWithContactFromAddressBook:(ABRecordRef)person;

@end

//
//  ProfileProfessionalsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileInstanceBaseViewController.h"

@protocol ProfessionalCellDelegate;

@interface ProfileProfessionalsViewController : ProfileInstanceBaseViewController


@property(nonatomic,assign)id<ProfessionalCellDelegate,ProfileInstanceDataDelegate,ProfileCountersDelegate> rootProfsDelegate;
@end

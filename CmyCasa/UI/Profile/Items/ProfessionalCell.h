//
//  ProfessionalCell.h
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePageBaseViewController.h"

#define PROFESSIONAL_CELL_HEIGHT     125
#define PROFESSIONAL_CELL_IDENTIFIER @"ProfessionalCell"

@protocol ProfessionalCellDelegate <NSObject>

- (void)professionalPressed:(NSString*)professionalId;

@end

@interface ProfessionalCell : UITableViewCell<ProfileCellUnifiedInitProtocol>

@property (nonatomic, strong) ProfessionalDO* professional;
@property (nonatomic, weak) id<ProfessionalCellDelegate> delegate;

@end

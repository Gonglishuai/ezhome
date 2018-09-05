//
//  ProfessionalProjectCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/1/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfProjects.h"
#import "iphoneProfProjectAssetController.h"

@interface ProfessionalProjectCell : UITableViewCell<ProfessionalProjectDelegate,UIScrollViewDelegate>



-(void)initWithProject:( ProfProjects *)project;
@property (weak, nonatomic) IBOutlet UIScrollView *assetsScroller;

@property(nonatomic)ProfProjects * projects;
@property(nonatomic)NSMutableArray * scrolledItems;
@end

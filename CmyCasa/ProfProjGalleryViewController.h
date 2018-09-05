//
//  ProfProjGalleryViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/31/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfProjects.h"
@interface ProfProjGalleryViewController : UIViewController
{
@private
    NSMutableArray* _designIds;
}

@property (nonatomic, assign) id<ProfessionalPageDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic) ProfProjects * mproject;
- (void) setProject:(ProfProjects*) project;
@end

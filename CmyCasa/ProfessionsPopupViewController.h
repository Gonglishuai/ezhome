//
//  ProfessionsPopupViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import <UIKit/UIKit.h>

@protocol ProfessionsDelegate
- (void)professionSelected:(NSString*) key :(NSString*) value;
@end

@interface ProfessionsPopupViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property(nonatomic,assign) id<ProfessionsDelegate>  delegate;
@property(nonatomic)NSMutableArray * profs;

- (void) setProfessions:(NSMutableArray*) professions;

@end

//
//  LayersViewController.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 6/2/15.
//
//

#import <UIKit/UIKit.h>
#import "Entity.h"

@protocol LayersViewDelegate <NSObject>

-(void)entitySelected:(Entity*)entity;

@end

@interface LayersViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView  *tableView;
@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL isDockingToLeft;
@property (nonatomic, weak) id<LayersViewDelegate> delegate;

@end

//
//  LocationsPopupViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import "LocationsPopupViewController.h"
#import "ProfFilterNameItemDO.h"
@interface LocationsPopupViewController ()

@end

@implementation LocationsPopupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void) setLocations:(NSMutableArray*) locations {
    self.locs=locations;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locs count];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    ProfFilterNameItemDO * pf = nil;
    if (self.locs && indexPath.row < [self.locs count]) {
        pf = [self.locs objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = pf.name;
    cell.textLabel.accessibilityLabel = pf.name;
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	  ProfFilterNameItemDO * pf=[self.locs objectAtIndex:indexPath.row];
    
    if (self.delegate != nil) {
        [self.delegate locationSelected:pf.key :pf.name];
    }
}

@end

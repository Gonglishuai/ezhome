//
//  ProfessionsPopupViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import "ProfessionsPopupViewController.h"
#import "ProfFilterNameItemDO.h"

@interface ProfessionsPopupViewController ()

@end

@implementation ProfessionsPopupViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void) setProfessions:(NSMutableArray*) professions {
    self.profs=professions;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.profs count];
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
    if (self.profs && indexPath.row < [self.profs count]) {
        pf = [self.profs objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text =pf.name;
    cell.textLabel.accessibilityLabel = pf.name;
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{

    ProfFilterNameItemDO * pf=[self.profs objectAtIndex:indexPath.row];
    
    if (self.delegate != nil) {
        [self.delegate professionSelected:[pf key]:[pf name]];
    }
}

@end

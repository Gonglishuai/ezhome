//
//  DebugViewController.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/2/14.
//
//

#import "DebugViewController.h"
#import "DesignsManager.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    debugOptions = [NSArray arrayWithObjects:@"Exit Debug menu",
                    @"Delete map file",
                    @"Print map log",
                    @"Delete Design Folder", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [debugOptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reuseIdentifier =  @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [debugOptions objectAtIndex:[indexPath row]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
    [cell.imageView setImage:[UIImage imageNamed:@"skal.jpeg"]];
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath row]) {
        case 0:
            break;
        case 1:
            [[DesignsManager sharedInstance] deleteMapFile];
            break;
        case 2:
            [[DesignsManager sharedInstance] printMapFile];
            break;
        case 3:
            [[DesignsManager sharedInstance] deleteAllFiles];
            break;

        default:
            break;
    }
    // Push the view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

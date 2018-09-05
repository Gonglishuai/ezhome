//
//  NewRecordInputViewController_iPad.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "NewRecordInputViewController_iPad.h"

@interface NewRecordInputViewController_iPad ()

@end

@implementation NewRecordInputViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAction:(id)sender {
}

- (IBAction)cancelAction:(id)sender {
    [super cancelAction:sender];
}
@end

//
//  TblRecordFinishControlsCell_iPad.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/5/14.
//
//

#import "TblRecordFinishControlsCell_iPad.h"
#import "ProfileUserDetailsViewController_iPad.h"
@implementation TblRecordFinishControlsCell_iPad


- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordFinishControlsCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordFinishControlsCell_iPhone" owner:self options:nil][0];
    }

    [self.cancelButton setTitle:NSLocalizedString(@"Cancel_edit_profile_button_title", @"Cancel") forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"Done_edit_profile_button_title", @"Done") forState:UIControlStateNormal];

    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{
    NSLog(@"");
    
    self.profileDetailsDelegate=delegate;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)cancelProfileChanges:(id)sender {
    
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(leaveProfileEditingWithoutChanges)]) {
        [self.profileDetailsDelegate leaveProfileEditingWithoutChanges];
    }
}

- (IBAction)saveProfileChanges:(id)sender {
    
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(leaveProfileEditingWithSaveChanges:)]) {
        [self.profileDetailsDelegate leaveProfileEditingWithSaveChanges:nil];
    }
}
@end

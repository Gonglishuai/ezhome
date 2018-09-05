//
//  TblRecordToggleCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/31/13.
//
//

#import "TblRecordToggleCell.h"
#import "UserComboDO.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "UserCombosResponse.h"
#import "UISegmentedControl+NUI.h"

#define  GENDER_FEMALE 0
#define  GENDER_MALE 1
#define  GENDER_UNKNOWN 2

@interface TblRecordToggleCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeGenderButtonLeading;
@end

@implementation TblRecordToggleCell


- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordToggleCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordToggleCell_iPhone" owner:self options:nil][0];
    }

    [self.tblSegmentControl setTitle:NSLocalizedString(@"Female_segment_option", @"Female") forSegmentAtIndex:0];
    [self.tblSegmentControl setTitle:NSLocalizedString(@"Male_segment_option", @"Male") forSegmentAtIndex:1];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self.tblSegmentControl setValue:@"GenderSelection_SegmentedControlForIOS6" forKeyPath:@"nuiClass"];
        if ([self.tblSegmentControl respondsToSelector:@selector(applyNUI)]) {
            [self.tblSegmentControl performSelector:@selector(applyNUI)];
        }
    }

    [self.removeGenderButton setTitle:NSLocalizedString(@"remove_gender_title", @"Rather not say") forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    return self;
}

-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state
    if (self.isEditing) {
        [self startEditMode];
    }else{
        [self stopEditMode];
    }
    
    
        id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    
    
        if (values && [values isKindOfClass:[UserComboDO class]]) {
            UserComboDO *combo=(UserComboDO*)values;
            self.genderOption=combo;
            if ([[combo.comboName lowercaseString] isEqualToString:@"m"]){
                self.tblSegmentControl.selectedSegmentIndex=1;
            }else
            if ([[combo.comboName lowercaseString] isEqualToString:@"f"]){
                self.tblSegmentControl.selectedSegmentIndex=0;
            } else{
                [self hideGenderOptions:self.removeGenderButton];

            }
        }else{
            [self hideGenderOptions:self.removeGenderButton];

        }
    
     }

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)segmentSelectionChange:(id)sender {


    [self updateGenderOption:(int)self.tblSegmentControl.selectedSegmentIndex];

}

- (void)updateGenderOption:(int)indexSelected {
    [[UserManager sharedInstance] getUserComboOptionsWithCompletionBlock:^(id serverResponse, id error) {

        UserComboDO * newGender;

        UserCombosResponse * combos=serverResponse;


        switch (indexSelected)
        {
            case GENDER_FEMALE:
                newGender=[combos getFemaleComboObject];
                break;
            case GENDER_MALE:
                newGender=[combos getMaleComboObject];
                break;
            case GENDER_UNKNOWN:
                newGender=[combos getUnkonwnGenderObject];
                break;
            default:
                break;


        }

        if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(valueChangedTo:forField:)]) {

            [self.profileDetailsDelegate valueChangedTo:newGender forField:kFieldGender];
        }

    } queue:dispatch_get_main_queue()];
}

- (IBAction)removeGenderData:(id)sender {
    UIButton * btn=(UIButton*)sender;
    if (self.tblSegmentControl.hidden) {
        [self showGenderOptions:btn];
        [self updateGenderOption:0];
        

    }else{
        [self updateGenderOption:2];
        [self hideGenderOptions:btn];

    }
    
}

- (void)hideGenderOptions:(UIButton *)btn {
  
    self.tblSegmentControl.hidden=YES;

    [btn setTitle:NSLocalizedString(@"set_gender_title", @"") forState:UIControlStateNormal];

    if (IS_IPAD) {
        CGRect fram=btn.frame;
        fram.origin.x= self.tblSegmentControl.frame.origin.x;
        btn.frame=fram;
    } else {
        self.removeGenderButtonLeading.constant = 0;
        [self setNeedsLayout];
    }
}

- (void)showGenderOptions:(UIButton *)btn {
    self.tblSegmentControl.hidden=NO;
    [btn setTitle:NSLocalizedString(@"remove_gender_title", @"") forState:UIControlStateNormal];

    if (IS_IPAD) {
        CGRect fram=btn.frame;
        fram.origin.x= self.tblSegmentControl.frame.origin.x + self.tblSegmentControl.frame.size.width + 10;
        btn.frame=fram;
    } else {
        self.removeGenderButtonLeading.constant = self.tblSegmentControl.frame.size.width + 10;
        [btn setNeedsLayout];
    }
}

@end

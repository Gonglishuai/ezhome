//
//  TblRecordReadOnlyIcon.m
//  Homestyler
//
//  Created by Tom Milberg on 4/27/14.
//
//

#import "TblRecordReadOnlyIcon.h"

@implementation TblRecordReadOnlyIcon
    
- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordReadOnlyIcon_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordReadOnlyIcon_iPhone" owner:self options:nil][0];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

    
-(void)initCellWithData:(NSDictionary*)data {
    
    [super initCellWithData:data];
    
    [self.btnIcon setEnabled:YES];
    
    NSString *valueString = nil;
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    if ([values isKindOfClass:[NSString class]]) {
        valueString = (NSString*)values;
        [self.btnIcon setTitle:valueString forState:UIControlStateNormal];
    }
    
    if (self.comboType == kFieldLocation) {
        [self.btnIcon setValue:@"" forKeyPath:@"iconDefaultHexValue"];
    }
    else if (self.comboType == kFieldGender) {
        if ([valueString isEqualToString:NSLocalizedString(@"Male_segment_option", @"")]) { //Male
            [self.btnIcon setValue:@"" forKeyPath:@"iconDefaultHexValue"];
        }
        else { //Female
            [self.btnIcon setValue:@"" forKeyPath:@"iconDefaultHexValue"];
        }
    }

}

@end

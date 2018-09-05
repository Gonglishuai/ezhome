//
//  TblRecordFullNameAndProfessionionCell.m
//  Homestyler
//
//  Created by Tom Milberg on 4/27/14.
//
//

#import "TblRecordFullNameAndProfessionionCell.h"
#import "UILabel+Size.h"

@implementation TblRecordFullNameAndProfessionionCell
    
- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"RecordFullNameAndProfessionCell_iPad" owner:self options:nil][0];
    
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
    
-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state
    
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    
    
    if (values && [values isKindOfClass:[NSString class]]) {
        self.lblProfession.text=(NSString*)values;
    }
    if (values && [values isKindOfClass:[NSMutableAttributedString class]]) {
        self.lblProfession.attributedText=(NSMutableAttributedString*)values;
    }
    
    [self formatForReadOnly];
    
}
-(void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{
    
    [self initCellWithData:data];
    self.profileDetailsDelegate=delegate;
}
    
-(void)formatForReadOnly{
    
    
    //reposition Label as part of total row display, when label empty it will shrink
    CGSize size=[self.recordTitle getActualTextWidthForLabel:300];
    
    CGRect frame=self.recordTitle.frame;
    frame.size.width = size.width;
    self.recordTitle.frame = frame;

    //reposition tbl record text
    CGRect frame2=self.lblProfession.frame;
    
    float newX = (frame.size.width>0)?frame.origin.x+frame.size.width+5:frame.origin.x;
    
    frame2.origin.x = newX;
    if (IS_IPAD) {
        if (frame.size.width == 0) {
            frame2.size.width=620;
        }
    }
    
    self.lblProfession.frame=frame2;
}


@end

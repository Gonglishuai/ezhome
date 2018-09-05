//
//  TblRecordDynamicLabelCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/2/14.
//
//

#import "TblRecordDynamicLabelCell.h"
#import "UILabel+Size.h"

#define kBottomSeparatorOffset 20

@implementation TblRecordDynamicLabelCell

- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordDynamicLabelCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordDynamicLabelCell_iPhone" owner:self options:nil][0];
    }
    [self setBackgroundColor:[UIColor grayColor]];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"about_me", @"")];
    [self.lblTitle sizeToFit];
    
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


-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state

    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    if (values) {
        if ([values isKindOfClass:[NSString class]]) {
             self.tblRecordText.text=(NSString*)values;
        }
        
        if ([values isKindOfClass:[NSAttributedString class]]) {
            self.tblRecordText.attributedText=values;
        }
           

        CGSize size=[self.tblRecordText getActualTextHeightForLabel:90000];
        
        self.tblRecordText.frame= CGRectMake(self.tblRecordText.frame.origin.x,
                                             self.tblRecordText.frame.origin.y,
                                             self.tblRecordText.frame.size.width,
                                             size.height);
    }
    
    //Show the bottom seperator only when fieldType is description
    id fieldType = [data objectForKey:USER_DETAIL_DATA_MODEL_FIELD];
    if (fieldType) {
        if ([fieldType integerValue] != kFieldDescription) {
            self.bottomSeparator.hidden = YES;
        }
    }
}

-(CGSize)getCorrentHightForContentText{
    
    CGSize size=[self.tblRecordText getActualTextHeightForLabel:90000];
    size.height+=self.tblRecordText.frame.origin.y;
    
    //For the bottom separator
    if (self.bottomSeparator.isHidden == NO) {
        size.height += kBottomSeparatorOffset + self.bottomSeparator.frame.size.height;
        
        if (IS_IPAD) {
            size.height += 10;
        }
    }
    else {
        size.height += kBottomSeparatorOffset;
    }
    
    if (!IS_IPAD) {
        //Ensure the default height of iPhone cell
        if (size.height < 35) {
            size.height = 35;
        }
    }

    return  size;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

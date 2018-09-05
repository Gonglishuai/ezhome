//
//  TblRecordDynamicLabelCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/2/14.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordDynamicLabelCell : TableRecordBaseCell
@property (weak, nonatomic) IBOutlet UILabel *tblRecordText;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparator;

- (CGSize)getCorrentHightForContentText;
@end

//
//  TblRecordLabelCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/31/13.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordLabelCell : TableRecordBaseCell
@property (weak, nonatomic) IBOutlet UILabel *tblRecordText;
@property (weak, nonatomic) IBOutlet UIView *topSeperator;

@end

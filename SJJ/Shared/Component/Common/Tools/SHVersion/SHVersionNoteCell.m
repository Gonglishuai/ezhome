//
//  SHVersionNoteCell.m
//  Consumer
//
//  Created by 牛洋洋 on 2017/4/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SHVersionNoteCell.h"

@interface SHVersionNoteCell ()

@property (weak, nonatomic) IBOutlet UILabel *versionNoteLabel;

@end

@implementation SHVersionNoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateVersionCellAtIndex:(NSInteger)index
{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(getVersionNoteAtIndex:)])
    {
        NSString *versionNote = [self.cellDelegate getVersionNoteAtIndex:index];
        self.versionNoteLabel.text = versionNote;
    }
}

@end

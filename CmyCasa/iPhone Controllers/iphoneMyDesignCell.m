//
//  iphoneMyDesignCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "iphoneMyDesignCell.h"

@implementation iphoneMyDesignCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initWithDesign:(MyDesignDO*)design{
    
    self.mydesign=design;
    self.designImage.image=nil;
    
    NSString* strID_Thumb = [NSString stringWithFormat:@"%@_thumb", design._id];
    NSString* imagePath = [[ConfigManager sharedInstance] getStreamFilePath:strID_Thumb];
    imagePath=[imagePath generateImagePathForWidth:self.frame.size.width andHight:self.frame.size.height];
    self.imagePath=imagePath;
    
    
    self.designTitle.text=design.title;
    
    NSTimeInterval timeStamp =[design.timestamp intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM. dd yyyy"];
    
    self.updateDate.text = [dateFormat stringFromDate:date];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)openEditPage:(id)sender {
    if (self.delegate) {
        [self.delegate editDesignPressed:self.mydesign andImage:self.designImage.image];
    }
}
@end

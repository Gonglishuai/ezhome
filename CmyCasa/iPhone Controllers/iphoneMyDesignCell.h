//
//  iphoneMyDesignCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <UIKit/UIKit.h>

@protocol IphoneMyDesignCellDelegate 

-(void)editDesignPressed:(MyDesignDO*)design andImage:(UIImage*)image;

@end

@interface iphoneMyDesignCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *designTitle;
@property (weak, nonatomic) IBOutlet UIImageView *designImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (IBAction)openEditPage:(id)sender;

@property(nonatomic)NSString * imagePath;
@property(nonatomic)MyDesignDO * mydesign;
@property (weak, nonatomic) IBOutlet UILabel *updateDate;

@property(nonatomic)id <IphoneMyDesignCellDelegate> delegate;
-(void)initWithDesign:(MyDesignDO*)design;
@end

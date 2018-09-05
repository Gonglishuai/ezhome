//
//  LayersViewCell.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 6/2/15.
//
//

#import <UIKit/UIKit.h>

@interface LayersViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * productName;
@property (nonatomic, weak) IBOutlet UIImageView * productImage;

-(void)loadImage:(NSString*)url;
@end

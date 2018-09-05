//
//  TableOptionsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/1/14.
//
//

#import <UIKit/UIKit.h>


@protocol TableOptionSelectionDelegate <NSObject>
@optional
-(void)didSelectItemAtIndex:(NSInteger)index withData:(id)object;
-(void)didSelectItemsAtIndexes:(NSMutableDictionary*)indexesDict;
-(void)newRecordEntryUsedWithValue:(id)value forField:(UserViewField)field;
@end

@interface TableOptionsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, TableOptionSelectionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *iamTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *multiChoiseDoneButton;
@property (nonatomic) UserViewField inputFieldReference;
@property (nonatomic, weak) id<TableOptionSelectionDelegate> delegate ;
@property (nonatomic, assign) BOOL multiChoise;
@property (nonatomic, assign) BOOL allowFreeTextInput;
@property (nonatomic, strong) NSMutableDictionary * multiChoiseDict;
@property (nonatomic, strong) NSMutableArray * presentingData;
@property (nonatomic) NSInteger OtherFieldIndex;

- (IBAction)multiChoiseDoneAction:(id)sender;
- (void)refreshTableWithNewContent:(NSMutableArray *)content selectedValues:(NSArray *)selected;
- (IBAction)cancelAction:(id)sender;
@end

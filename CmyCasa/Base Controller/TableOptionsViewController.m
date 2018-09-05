//
//  TableOptionsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/1/14.
//
//

#import "TableOptionsViewController.h"
#import "ComboOptionCell.h"
#import "UserComboDO.h"
#import "ControllersFactory.h"
#import "NewRecordInputBaseViewController.h"

@interface TableOptionsViewController ()

@end

@implementation TableOptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.OtherFieldIndex = 0;
    
    if(!self.multiChoiseDict)
        self.multiChoiseDict = [NSMutableDictionary  dictionaryWithCapacity:0];
    
    
    switch (self.inputFieldReference) {
        case kFieldProfessions:
            self.iamTitle.text=NSLocalizedString(@"i_am_title", @"");
            break;
            
        default:
            self.iamTitle.text = nil;
            break;
    }
    
    self.multiChoiseDoneButton.hidden = !self.multiChoise;
    
    self.lblTitle.text = NSLocalizedString(@"edit_profile", @"");
}

- (void)viewWillAppear:(BOOL)animated {
    
    CGSize size = self.view.frame.size;
    self.preferredContentSize = size;
    [super viewWillAppear:animated];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"dealloc - TableOptionsViewController");
}

#pragma mark -
-(void)setMultiChoise:(BOOL)multiChoise{
    _multiChoise = multiChoise;
}

- (IBAction)multiChoiseDoneAction:(id)sender {
    
    if (self.multiChoise) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemsAtIndexes:)]){
            
            [self.delegate didSelectItemsAtIndexes:self.multiChoiseDict];
        }
    }
    
    self.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshTableWithNewContent:(NSMutableArray *)content selectedValues:(NSArray *)selected {
    
    self.presentingData= [content copy];
    if(!self.multiChoiseDict)
        self.multiChoiseDict = [NSMutableDictionary  dictionaryWithCapacity:0];
    
    if (!selected)return;
    
    NSMutableArray * arr=[NSMutableArray arrayWithArray:self.presentingData];
    [self.multiChoiseDict removeAllObjects];
    for(int i=0;i<selected.count;i++){
        UserComboDO * combo=[selected objectAtIndex:i];
        [self.multiChoiseDict setObject:combo forKey:combo.comboId];
        if([self.presentingData indexOfObject:combo]==NSNotFound){
            [arr addObject:combo];
        }
    }
    if ([arr count]>0) {
        self.presentingData=[arr copy];
    }
    //also check if selected values not exists in presentingData like "other" stuff
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    self.OtherFieldIndex=(self.presentingData.count==0)?0:self.presentingData.count;
    
    if (!self.allowFreeTextInput) {
        self.OtherFieldIndex=NSNotFound;
        return self.presentingData.count;
    }
    return self.presentingData.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *const identifierContent = @"OptionCell";
    ComboOptionCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierContent];
    UserComboDO * item;
    if(indexPath.row==self.OtherFieldIndex && self.allowFreeTextInput){
        item=[UserComboDO  new];
        item.comboName= NSLocalizedString(@"user_detail_other_input_field", @"Other...");
    }else{
        if (self.presentingData && indexPath.row < [self.presentingData count]) {
            item = [self.presentingData objectAtIndex:indexPath.row];
        }
    }
    
    [cell initWithComboData:item];
    
    if ([self.multiChoiseDict objectForKey:item.comboId]) {
        [cell updateSelection:YES];
    }else{
        [cell updateSelection:NO];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.OtherFieldIndex==indexPath.row && self.allowFreeTextInput){
        //open edit free text ui
        
        NewRecordInputBaseViewController * newRecord=[ControllersFactory instantiateViewControllerWithIdentifier:@"newRecordInputViewController" inStoryboard:kProfileStoryboard];
        //TODO:6571847
        newRecord.inputFieldReference = self.inputFieldReference;
        newRecord.delegate = self;
        
        [self.navigationController pushViewController:newRecord animated:YES];
        
    }else{
        if (self.multiChoise) {
            UserComboDO * item = [self.presentingData objectAtIndex:indexPath.row];
            
            if ([self.multiChoiseDict objectForKey:item.comboId]) {
                [self.multiChoiseDict removeObjectForKey:item.comboId];
            }else{
                [self.multiChoiseDict setObject:item forKey:item.comboId];
            }
            [self.tableView reloadData];
        }else{
            //send option selection to delegate
            if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndex:withData:)]){
                [self.delegate didSelectItemAtIndex:indexPath.row withData:self.presentingData[indexPath.row]];
                [self cancelAction:nil];
            }
        }
    }
    return nil;
}

- (IBAction)cancelAction:(id)sender {
    self.delegate = nil;
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -TableOptionSelectionDelegate
-(void)newRecordEntryUsedWithValue:(id)value forField:(UserViewField)field{
    if (self.multiChoise) {
        UserComboDO * combo=[UserComboDO new];
        combo.comboName=value;
        combo.comboId=value;
        if ([value length]>0) {
            NSMutableArray * arr=[NSMutableArray arrayWithArray:self.presentingData];
            
            [arr addObject:combo];
            self.presentingData=[arr copy];
            [self.multiChoiseDict setObject:combo forKey:combo.comboId];
        }
        [[self tableView] reloadData];
       
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if([value length]>0){
        if (self.delegate && [self.delegate  respondsToSelector:@selector(newRecordEntryUsedWithValue:forField:)]) {
            
            
                            [self.navigationController popViewControllerAnimated:NO];
            [self.delegate newRecordEntryUsedWithValue:value forField:field];
        }
    }
}

@end

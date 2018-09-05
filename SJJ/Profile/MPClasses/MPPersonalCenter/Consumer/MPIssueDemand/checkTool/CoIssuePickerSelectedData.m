
#import "CoIssuePickerSelectedData.h"

@implementation CoIssuePickerSelectedData

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.row1 = @"";
        self.row2 = @"";
        self.row3 = @"";
        self.year = @"";
        self.fen  = @"";
    }
    return self;
}

#pragma mark - Getter
- (NSString *)row1
{
    if (!_row1)
        return @"";
    
    return _row1;
}

- (NSString *)row2
{
    if (!_row2)
        return @"";
    
    return _row2;
}

- (NSString *)row3
{
    if (!_row3)
        return @"";
    
    return _row3;
}

- (NSString *)year
{
    if (!_year)
        return @"";
    
    return _year;
}

- (NSString *)fen
{
    if (!_fen)
        return @"";
    
    return _fen;
}

@end

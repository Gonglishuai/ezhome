//
//  GalleryStreamHeaderView.m
//  EZHome
//
//  Created by liuyufei on 4/16/18.
//

#import "GalleryStreamHeaderView_iPad.h"
#import "RoomTypeDO.h"

static const CGFloat roomTypeBootomLineHeight = 3;
static const CGFloat roomTypeFilterButtonHeight = 47;
static const CGFloat roomTypeFilterButtonTextSpacing = 30;
static const NSUInteger room_tag = 1000;

@interface GalleryStreamHeaderView_iPad()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *roomTypes;
@property (nonatomic, strong) NSMutableArray *roomTypesPosition;
@property (nonatomic, strong) UIView *roomTypeBootomLine;
@property (nonatomic, strong) NSMutableArray *roomTypeSubviews;

@property (nonatomic, assign) NSInteger selectedRoomType;

@end

@implementation GalleryStreamHeaderView_iPad

@synthesize sortTypesArr = _sortTypesArr;
@synthesize roomTypesArr = _roomTypesArr;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedRoomType = 0;
}

- (NSMutableArray *)roomTypes
{
    if (!_roomTypes)
    {
        _roomTypes = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomTypes;
}

- (NSMutableArray *)roomTypesPosition
{
    if (!_roomTypesPosition)
    {
        _roomTypesPosition = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomTypesPosition;
}

- (NSMutableArray *)roomTypeSubviews
{
    if (!_roomTypeSubviews)
    {
        _roomTypeSubviews = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomTypeSubviews;
}

- (void)setSortTypesArr:(NSArray *)sortTypesArr
{
    if ([sortTypesArr count] == 0)
        return;

    if ([_sortTypesArr isEqualToArray:sortTypesArr])
    {
        return;
    }

    _sortTypesArr = sortTypesArr;
    [self.filterListButton setTitle:[self.sortTypesArr[0] objectForKey:@"d"] forState:UIControlStateNormal];
}

- (void)setRoomTypesArr:(NSArray *)roomTypesArr
{
    if ([roomTypesArr count] == 0)
        return;

    if ([_roomTypesArr isEqualToArray:roomTypesArr])
    {
        return;
    }

    _roomTypesArr = roomTypesArr;
    [self setupRoomTypesButtonOnScrollView];
}

- (void)removeRoomTypesButton
{
    [self.roomTypeSubviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL * _Nonnull stop) {
        [subView removeFromSuperview];
    }];
}

- (void)setupRoomTypesButtonOnScrollView
{
    [self removeRoomTypesButton];

    __block CGFloat roomX = 0;
    UIFont *buttonFont = [UIFont systemFontOfSize:16];

    [self.roomTypesPosition removeAllObjects];
    [self.roomTypesArr enumerateObjectsUsingBlock:^(RoomTypeDO *roomType, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat textWidth = [NSLocalizedString(roomType.desc, @"") sizeWithAttributes:
                             @{NSFontAttributeName:buttonFont}].width + roomTypeFilterButtonTextSpacing;
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@(textWidth), roomType.myId, nil];
        [self.roomTypesPosition addObject:dict];

        UIButton *room = [UIButton buttonWithType:UIButtonTypeCustom];
        room.frame = CGRectMake(roomX, 0, textWidth, roomTypeFilterButtonHeight);
        room.tag = room_tag + idx;
        [room setTitle:NSLocalizedString(roomType.desc, @"") forState:UIControlStateNormal];
        [room setValue:@"Text_Body1" forKey:@"nuiClass"];
        [room addTarget:self action:@selector(selectedRoom:) forControlEvents:UIControlEventTouchUpInside];
        [self.roomTypeSubviews addObject:room];
        [self.scrollView addSubview:room];

        if (idx == self.selectedRoomType)
        {
            self.roomTypeBootomLine = [[UIView alloc] init];
            self.roomTypeBootomLine.frame = CGRectMake(roomX + roomTypeFilterButtonTextSpacing / 2,
                                                       self.frame.size.height - roomTypeBootomLineHeight,
                                                       textWidth - roomTypeFilterButtonTextSpacing,
                                                       roomTypeBootomLineHeight);
            self.roomTypeBootomLine.backgroundColor = [UIColor colorWithRed:255.0/255 green:204.0/255 blue:0 alpha:1.0];
            self.roomTypeBootomLine.layer.cornerRadius = 1.5;
            [self.scrollView addSubview:self.roomTypeBootomLine];
            [self.roomTypeSubviews addObject:self.roomTypeBootomLine];
        }
        
        roomX = roomX + textWidth;
        self.scrollView.contentSize = CGSizeMake(roomX, roomTypeFilterButtonHeight);
    }];
}

- (void)selectedRoom:(UIButton *)sender
{
    self.selectedRoomType = sender.tag - room_tag;
    self.roomTypeBootomLine.frame = CGRectMake(sender.frame.origin.x, self.frame.size.height - roomTypeBootomLineHeight, sender.frame.size.width, roomTypeBootomLineHeight);
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedRoomKey:Value:)])
    {
        RoomTypeDO *item = [self.roomTypesArr objectAtIndex:sender.tag - room_tag];
        [self.delegate selectedRoomKey:item.myId Value:NSLocalizedString(item.desc, @"")];
    }
}

- (IBAction)showRoomTypeList:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showRoomTypeList:)])
    {
        [self setRoomTypesButtonState:YES];
        [self.delegate showRoomTypeList:sender];
    }
}

- (void)updateRoomTypePosition:(NSString *)key
{
    __block CGFloat roomX = 0;
    __block CGFloat textWidth = 0;
    [self.roomTypesPosition enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        textWidth = [dict.allValues[0] floatValue];
        if ([dict.allKeys[0] isEqualToString:key])
        {
            self.selectedRoomType = idx;
            *stop = YES;
        }
        else
        {
            roomX += textWidth;
        }
    }];
    [self.scrollView scrollRectToVisible:CGRectMake(roomX, 0, self.scrollView.bounds.size.width, roomTypeFilterButtonHeight) animated:YES];
    self.roomTypeBootomLine.frame = CGRectMake(roomX + roomTypeFilterButtonTextSpacing / 2,
                                               self.frame.size.height - roomTypeBootomLineHeight,
                                               textWidth - roomTypeFilterButtonTextSpacing,
                                               roomTypeBootomLineHeight);
}

@end

//
//  GalleryStreamEmptyRoomHeaderView.m
//  Homestyler
//
//  Created by liuyufei on 4/27/18.
//

#import "GalleryStreamEmptyRoomHeaderView.h"
#import "RoomTypeDO.h"

static const CGFloat EmptyRoomBootomLineHeight = 3;
static const CGFloat EmptyRoomFilterButtonHeight = 47;
static const CGFloat EmptyRoomFilterButtonTextSpacing = 30;
static const NSUInteger emptyRoom_tag = 2000;

@interface GalleryStreamEmptyRoomHeaderView ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *roomTypesList;

@property (nonatomic, strong) NSMutableArray *roomTypes;
@property (nonatomic, strong) NSMutableArray *roomsPosition;
@property (nonatomic, strong) NSMutableArray *roomTypeSubviews;
@property (nonatomic, strong) UIView *roomTypeBootomLine;

@property (nonatomic, assign) NSInteger selectedRoomType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginRightConstraint;

@end

@implementation GalleryStreamEmptyRoomHeaderView

@synthesize roomTypesArr = _roomTypesArr;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (IS_IPAD) {
        self.marginLeftConstraint.constant = 35;
        self.marginRightConstraint.constant = 38;
    } else {
        self.marginLeftConstraint.constant = 1;
        self.marginRightConstraint.constant = 4;
    }
    self.selectedRoomType = 0;
}

- (NSMutableArray *)emptyRooms
{
    if (!_roomTypes)
    {
        _roomTypes = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomTypes;
}

- (NSMutableArray *)roomTypeSubviews
{
    if (!_roomTypeSubviews)
    {
        _roomTypeSubviews = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomTypeSubviews;
}

- (NSMutableArray *)roomsPosition
{
    if (!_roomsPosition)
    {
        _roomsPosition = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomsPosition;
}

- (void)removeRoomTypesButton
{
    [self.roomTypeSubviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL * _Nonnull stop) {
        [subView removeFromSuperview];
    }];
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

- (void)setupRoomTypesButtonOnScrollView
{
    [self removeRoomTypesButton];

    __block CGFloat roomX = 0;
    UIFont *buttonFont = [UIFont systemFontOfSize:16];
    [self.roomTypesList scrollRectToVisible:self.roomTypesList.bounds animated:YES];
    [self.roomsPosition removeAllObjects];
    [self.roomTypesArr enumerateObjectsUsingBlock:^(RoomTypeDO *roomType, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat textWidth = [NSLocalizedString(roomType.desc, @"") sizeWithAttributes:
                             @{NSFontAttributeName:buttonFont}].width + EmptyRoomFilterButtonTextSpacing;

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@(textWidth), roomType.myId, nil];
        [self.roomsPosition addObject:dict];

        UIButton *room = [UIButton buttonWithType:UIButtonTypeCustom];
        room.frame = CGRectMake(roomX, 0, textWidth, EmptyRoomFilterButtonHeight);
        room.tag = emptyRoom_tag + idx;
        [room setTitle:NSLocalizedString(roomType.desc, @"") forState:UIControlStateNormal];
        [room setValue:@"Text_Body1" forKey:@"nuiClass"];
        [room addTarget:self action:@selector(selectedRoom:) forControlEvents:UIControlEventTouchUpInside];
        [self.roomTypeSubviews addObject:room];
        [self.roomTypesList addSubview:room];

        if (idx == self.selectedRoomType)
        {
            self.roomTypeBootomLine = [[UIView alloc] init];
            self.roomTypeBootomLine.frame = CGRectMake(roomX + EmptyRoomFilterButtonTextSpacing / 2,
                                                       EmptyRoomFilterButtonHeight,
                                                       textWidth - EmptyRoomFilterButtonTextSpacing,
                                                       EmptyRoomBootomLineHeight);
            self.roomTypeBootomLine.backgroundColor = [UIColor colorWithRed:255.0/255 green:204.0/255 blue:0 alpha:1.0];
            self.roomTypeBootomLine.layer.cornerRadius = 1.5;
            [self.roomTypesList addSubview:self.roomTypeBootomLine];
            [self.roomTypeSubviews addObject:self.roomTypeBootomLine];
        }

        roomX = roomX + textWidth;
        self.roomTypesList.contentSize = CGSizeMake(roomX, EmptyRoomFilterButtonHeight);
    }];
}

- (void)selectedRoom:(UIButton *)sender
{
    self.selectedRoomType = sender.tag - emptyRoom_tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedRoomKey:Value:)])
    {
        RoomTypeDO *item = [self.roomTypesArr objectAtIndex:sender.tag - emptyRoom_tag];
        [self.delegate selectedRoomKey:item.myId Value:NSLocalizedString(item.desc, @"")];
    }
}

- (IBAction)showAllRoomTypes:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showRoomTypeList:)])
    {
        [self setRoomTypesButtonState:YES];
        [self.delegate showRoomTypeList:sender];
    }
}

- (void)updateEmptyRoomPosition:(NSString *)key
{
    __block CGFloat roomX = 0;
    __block CGFloat textWidth = 0;
    [self.roomsPosition enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
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

    [self.roomTypesList scrollRectToVisible:CGRectMake(roomX, 0, self.roomTypesList.bounds.size.width, EmptyRoomFilterButtonHeight) animated:YES];
    self.roomTypeBootomLine.frame = CGRectMake(roomX + EmptyRoomFilterButtonTextSpacing / 2,
                                               EmptyRoomFilterButtonHeight,
                                               textWidth - EmptyRoomFilterButtonTextSpacing,
                                               EmptyRoomBootomLineHeight);
}

@end

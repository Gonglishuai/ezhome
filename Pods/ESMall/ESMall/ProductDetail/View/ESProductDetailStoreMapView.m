
#import "ESProductDetailStoreMapView.h"
#import <MapKit/MapKit.h>
#import "Masonry.h"
#import "ESProductStoreModel.h"
#import "ESProductBaseCell.h"
#import "ESProductDetailStoreTableView.h"

#define TABLE_NORMAL_HEIGHT 73 * 2.5
#define TABLE_ALL_HEIGHT (SCREEN_HEIGHT - 73.0f)
#define TABLE_SELECTED_HEIGHT 73
#define TABLE_HEADER_HEIGHT 40

@interface ESProductDetailStoreMapView ()<MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation ESProductDetailStoreMapView
{
    MKMapView *_mapView;
    
    ESProductDetailStoreTableView *_storesTableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createStoreMapView];
    }
    return self;
}

- (void)createStoreMapView
{
    _mapView = [[MKMapView alloc] init];
    [self addSubview:_mapView];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.rotateEnabled = NO;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [self addSubview:_mapView];
    __weak typeof (self) weakSelf = self;
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf);
        make.size.mas_equalTo(weakSelf.frame.size);
    }];
    
    CGRect tableFrame = CGRectMake(0, CGRectGetHeight(self.frame) - TABLE_NORMAL_HEIGHT - TABLE_HEADER_HEIGHT, CGRectGetWidth(self.frame), TABLE_NORMAL_HEIGHT + TABLE_HEADER_HEIGHT);
    _storesTableView = [[ESProductDetailStoreTableView alloc] initWithFrame:tableFrame];
    _storesTableView.viewDelegate = (id)self;
    _storesTableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _storesTableView.tableView.delegate = self;
    _storesTableView.tableView.dataSource = self;
    _storesTableView.tableView.estimatedRowHeight = 49.0f;
    _storesTableView.tableView.rowHeight = UITableViewAutomaticDimension;
    [_storesTableView.tableView registerNib:[UINib nibWithNibName:@"ESProductDetailStoreItemCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESProductDetailStoreItemCell"];
    [self addSubview:_storesTableView];
}

- (void)updateAnnotations
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getStoreInformations)])
    {
        NSArray *stores = [self.viewDelegate getStoreInformations];
        if (!stores
            || ![stores isKindOfClass:[NSArray class]])
        {
            return;
        }
        
        MKPointAnnotation *selectedAnnotation = nil;
        for (ESProductStoreModel *model in stores)
        {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:CLLocationCoordinate2DMake([model.latitude doubleValue], [model.longitude doubleValue])];
            [annotation setTitle:model.storeName];
            [annotation setSubtitle:model.address];
            if (model.selectedStatus)
            {
                selectedAnnotation = annotation;
            }
            [_mapView addAnnotation:annotation];
        }
        
        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in _mapView.annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x - 10000, annotationPoint.y - 100, 20000, 20000);
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect;
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
        [_mapView setVisibleMapRect:zoomRect animated:YES];
        
        if (selectedAnnotation)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(selectedAnnotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x - zoomRect.size.width/2.0f, annotationPoint.y - 1000, zoomRect.size.width, zoomRect.size.height);
            [_mapView setVisibleMapRect:pointRect animated:YES];
            [_mapView selectAnnotation:selectedAnnotation animated:YES];
        }

    }
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        static NSString *annotationID = @"MKAnnotationView";
        MKAnnotationView *customPinView = (MKAnnotationView*)[mapView
                                                                    dequeueReusableAnnotationViewWithIdentifier:annotationID];
        if (!customPinView){
            // If an existing pin view was not available, create one.
            customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:annotationID];
        }

        customPinView.canShowCallout = YES;
        customPinView.image = [UIImage imageNamed:@"navigation_annotation"];

        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        rightButton.backgroundColor = [UIColor stec_tabbarBackgroundColor];
        [rightButton setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
        customPinView.rightCalloutAccessoryView = rightButton;
        return customPinView;
    }
    
    return nil;//返回nil代表使用默认样式
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(storeDidTappedWithName:latitude:longitude:)])
    {
        [self.viewDelegate
         storeDidTappedWithName:view.annotation.title
         latitude:view.annotation.coordinate.latitude
         longitude:view.annotation.coordinate.longitude];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(storeDidSelectedWithName:)])
    {
        [self.viewDelegate
         storeDidSelectedWithName:view.annotation.title];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getStoreCount)])
    {
        row = [self.viewDelegate getStoreCount];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ESProductDetailStoreItemCell";
    ESProductBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateCellAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(storeItemDidTappedWithIndexPath:)])
    {
        [self.viewDelegate
         storeItemDidTappedWithIndexPath:indexPath];
    }
}

#pragma mark - ESProductDetailStoreHeaderViewwDelegate
- (void)tapHeaderPointy:(CGFloat)pointY endStatus:(BOOL)endStatus
{
    SHLog(@"拖拽:%lf", pointY);

    _storesTableView.tableView.scrollEnabled = YES;
    if (!endStatus)
    {
        CGRect tableFrame = CGRectMake(0, pointY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - pointY);
        _storesTableView.frame = tableFrame;
        return;
    }
    
    CGRect showFrame = CGRectZero;
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    if (pointY < viewHeight/2.0f)
    {
        showFrame = CGRectMake(
                               0,
                               viewHeight - TABLE_ALL_HEIGHT,
                               viewWidth,
                               TABLE_ALL_HEIGHT)
        ;
    }
    else if (pointY >= viewHeight/2.0f
             && pointY < viewHeight - TABLE_NORMAL_HEIGHT - TABLE_HEADER_HEIGHT)
    {
        showFrame = CGRectMake(
                               0,
                               viewHeight - TABLE_NORMAL_HEIGHT - TABLE_HEADER_HEIGHT
                               ,
                               viewWidth,
                               TABLE_NORMAL_HEIGHT + TABLE_HEADER_HEIGHT
                               );
    }
    else
    {
        _storesTableView.tableView.scrollEnabled = NO;
        showFrame = CGRectMake(
                               0,
                               viewHeight - TABLE_SELECTED_HEIGHT - TABLE_HEADER_HEIGHT,
                               viewWidth,
                               TABLE_SELECTED_HEIGHT + TABLE_HEADER_HEIGHT
                               );
    }
    
    [self animateShowWithFrame:showFrame];
}

#pragma mark - Animate
- (void)animateShowWithFrame:(CGRect)frame
{
    __weak UIView *weakView = _storesTableView;
    [UIView animateWithDuration:0.25 animations:^{
        
        weakView.frame = CGRectMake(
                                    0,
                                    frame.origin.y,
                                    CGRectGetWidth(weakView.frame),
                                    SCREEN_HEIGHT
                                    );
    } completion:^(BOOL finished) {
        
        weakView.frame = frame;
    }];
}

#pragma mark - Setter
- (void)setViewDelegate:(id<ESProductDetailStoreMapViewDelegate>)viewDelegate
{
    _viewDelegate = viewDelegate;
    
    [self updateAnnotations];
    
    [_storesTableView.tableView reloadData];
}

#pragma mark - Super Methods
- (void)refreshView
{
    [self refreshStoresTable];
    
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getStoreInformations)])
    {
        NSArray *stores = [self.viewDelegate getStoreInformations];
        if (!stores
            || ![stores isKindOfClass:[NSArray class]])
        {
            return;
        }
        
        for (NSInteger i = 0; i < stores.count; i++)
        {
            ESProductStoreModel *model = stores[i];
            if (model.selectedStatus)
            {
                for (id <MKAnnotation> annotation in _mapView.annotations)
                {
                    if ([model.storeName isEqualToString:annotation.title])
                    {
                        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                        MKMapRect pointRect = MKMapRectMake(annotationPoint.x - 20000, annotationPoint.y - 5000, 40000, 40000);
                        [_mapView setVisibleMapRect:pointRect animated:YES];
                        [_mapView selectAnnotation:annotation animated:YES];
                    }
                }
            }
        }
    }
    
    [self showSelectedStore];
}

- (void)refreshStoresTable
{    
    NSInteger section = [_storesTableView.tableView numberOfSections];
    if (section > 0)
    {
        [_storesTableView.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)showSelectedStore
{
    [_storesTableView.tableView scrollsToTop];
    
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGRect selectedFrame = CGRectMake(
                                      0,
                                      viewHeight - TABLE_SELECTED_HEIGHT - TABLE_HEADER_HEIGHT,
                                      viewWidth,
                                      TABLE_SELECTED_HEIGHT + TABLE_HEADER_HEIGHT
                                      );
    [self animateShowWithFrame:selectedFrame];
    
    _storesTableView.tableView.scrollEnabled = NO;
}

@end

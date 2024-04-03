#import "AppIconOptionsController.h"

@interface AppIconOptionsController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *iconPreview;

@property (strong, nonatomic) NSArray<NSString *> *appIcons;

@end

@implementation AppIconOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];

    self.iconPreview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    [self.view addSubview:self.iconPreview];

    self.appIcons = @[@"AppIcon1", @"AppIcon2", @"AppIcon3"];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.appIcons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImage *appIconImage = [UIImage imageNamed:self.appIcons[indexPath.row]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:appIconImage];
    imageView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *selectedIconImage = [UIImage imageNamed:self.appIcons[indexPath.row]];
    self.iconPreview.image = selectedIconImage;
}

@end

#import "AppIconOptionsController.h"

@interface AppIconOptionsController () <UICollectionViewDataSource, UICollectionViewDelegate>

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
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:self.collectionView];

    self.iconPreview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    [self.view addSubview:self.iconPreview];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    self.appIcons = [bundle pathsForResourcesOfType:@"png" inDirectory:@"AppIcons"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.appIcons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    UIImage *appIconImage = [UIImage imageWithContentsOfFile:self.appIcons[indexPath.row]];
    UIImage *resizedIconImage = [self resizedImageWithImage:appIconImage];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedIconImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:imageView];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *selectedIconImage = [UIImage imageWithContentsOfFile:self.appIcons[indexPath.row]];
    UIImage *resizedSelectedIconImage = [self resizedImageWithImage:selectedIconImage];
    self.iconPreview.image = resizedSelectedIconImage;
}

- (UIImage *)resizedImageWithImage:(UIImage *)image {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize newSize = CGSizeMake(image.size.width / scale, image.size.height / scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

@end

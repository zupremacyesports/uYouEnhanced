#import "AppIconOptionsController.h"

@interface AppIconOptionsController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *iconPreview;
@property (strong, nonatomic) NSArray<NSString *> *appIcons;
@property (strong, nonatomic) NSString *selectedIconFile;

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
    
    UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeSystem];
    defaultButton.frame = CGRectMake(20, 100, 100, 40);
    [defaultButton setTitle:@"Default" forState:UIControlStateNormal];
    [defaultButton addTarget:self action:@selector(setDefaultIcon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defaultButton];
    
    self.iconPreview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 150, 60, 60)];
    self.iconPreview.layer.cornerRadius = 10.0;
    self.iconPreview.clipsToBounds = YES;
    [self.view addSubview:self.iconPreview];
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    self.appIcons = [bundle pathsForResourcesOfType:@"png" inDirectory:@"AppIcons"];
} else {
    NSLog(@"Alternate icons are not supported on this device.");
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
    imageView.layer.cornerRadius = 10.0;
    imageView.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIconFile = self.appIcons[indexPath.row];
    UIImage *selectedIconImage = [UIImage imageWithContentsOfFile:self.selectedIconFile];
    UIImage *resizedSelectedIconImage = [self resizedImageWithImage:selectedIconImage];
    self.iconPreview.image = resizedSelectedIconImage;
    
    // Set the selected icon as the app's icon
    [[UIApplication sharedApplication] setAlternateIconName:[self.selectedIconFile lastPathComponent] completionHandler:^(NSError * _Nullable error){
        if (error) {
            NSLog(@"Error setting alternate icon: %@", error.localizedDescription);
        } else {
            NSLog(@"Alternate icon set successfully");
        }
    }];
}

- (void)setDefaultIcon {
    self.iconPreview.image = nil;
    self.selectedIconFile = nil;
    
    [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError * _Nullable error){
        if (error) {
            NSLog(@"Error setting default icon: %@", error.localizedDescription);
        } else {
            NSLog(@"Default icon set successfully");
        }
    }];
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

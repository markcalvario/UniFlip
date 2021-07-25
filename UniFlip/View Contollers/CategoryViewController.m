//
//  CategoryViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/25/21.
//

#import "CategoryViewController.h"
#import "CategoryCell.h"
#import "ListingCell.h"
#import "Listing.h"

@interface CategoryViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categoryTableView.delegate = self;
    self.categoryTableView.dataSource = self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FirstCell" forIndexPath:indexPath];
        cell.textLabel.text = self.category;
        return cell;
    }
    else{
        CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListingsByCategoryCell" forIndexPath:indexPath];
        cell.listingsByCategoryCollectionView.tag = indexPath.row;
        cell.listingsByCategoryCollectionView.scrollEnabled = NO;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0){
        CategoryCell *tableViewCell = (CategoryCell *) cell;
        tableViewCell.listingsByCategoryCollectionView.delegate = self;
        tableViewCell.listingsByCategoryCollectionView.dataSource = self;
        [tableViewCell.listingsByCategoryCollectionView reloadData];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0){
        CGFloat numOfListings = self.listings.count;
        CGFloat height = (245 * ceil(numOfListings/2)) + 50;
        return height;
    }
    return 100;
    
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

#pragma mark - Collection View

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingByCategory" forIndexPath:indexPath];
    Listing *listing = [self.listings objectAtIndex:indexPath.row];
    cell.listingByCategoryPriceLabel.text = listing.listingPrice;
    cell.listingByCategoryTitleLabel.text = listing.listingTitle;
    PFFileObject *listingImageFile = [listing.photos objectAtIndex:0];
    [cell.listingImage setImage:nil];
    [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            [cell.listingByCategoryImage setImage:image];
           
        }
    }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listings.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionViewLayout;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 2;
    CGFloat numberOfItemsPerRow = 2;
    CGFloat itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing *(numberOfItemsPerRow))/numberOfItemsPerRow;
    CGFloat itemHeight = itemWidth *1.25;
    return CGSizeMake(itemWidth, itemHeight);
    
}



@end

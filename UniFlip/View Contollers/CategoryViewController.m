//
//  CategoryViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/25/21.
//
#import "ListingDetailViewController.h"
#import "CategoryViewController.h"
#import "CategoryCell.h"
#import "ListingCell.h"
#import "Listing.h"
#import "Reachability.h"
#import "User.h"


@interface CategoryViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;
@property (nonatomic) CGFloat categoryLabelHeight;
@property (strong, nonatomic) User *currentUser;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categoryTableView.delegate = self;
    self.categoryTableView.dataSource = self;
    self.currentUser = [User currentUser];
}
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
        CGFloat numberOfItemsPerRow = 2;
        CGFloat itemWidth;
        if (self.view.frame.size.width > 600){
            CGFloat widthRequirement = 290;
            BOOL meetsWidthRequirement = TRUE;
            while (meetsWidthRequirement){
                itemWidth = (tableView.frame.size.width - 3 *(numberOfItemsPerRow))/numberOfItemsPerRow;
                if (itemWidth <= widthRequirement){
                    meetsWidthRequirement = FALSE;
                }
                numberOfItemsPerRow ++;
            }
        }
        itemWidth = (tableView.frame.size.width - 3 *(numberOfItemsPerRow))/numberOfItemsPerRow;
        CGFloat itemHeight = itemWidth;
        
        CGFloat height = (itemHeight * ceil(numOfListings/numberOfItemsPerRow)) + 100;
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
    [cell withTitleLabel:cell.listingByCategoryTitleLabel withSaveButton:cell.listingByCategorySaveButton withPriceLabel:cell.listingByCategoryPriceLabel withListingImage:cell.listingByCategoryImage withListing:listing withCategory:@"" withIndexPath:indexPath withIsFiltered:NO withSearchText:@""];
    [self updateSaveButtonUI:listing.isSaved withButton: cell.listingByCategorySaveButton];
    [cell.listingByCategorySaveButton addTarget:self action:@selector(didTapSaveIcon:) forControlEvents: UIControlEventTouchUpInside];
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
    CGFloat itemWidth;
    if (self.view.frame.size.width > 600){
        CGFloat widthRequirement = 290;
        BOOL meetsWidthRequirement = TRUE;
        while (meetsWidthRequirement){
            itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing *(numberOfItemsPerRow))/numberOfItemsPerRow;
            if (itemWidth <= widthRequirement){
                meetsWidthRequirement = FALSE;
            }
            numberOfItemsPerRow ++;
        }
    }
    itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing *(numberOfItemsPerRow))/numberOfItemsPerRow;
    CGFloat itemHeight = itemWidth *1.25;
    return CGSizeMake(itemWidth, itemHeight);
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Listing *listing = [self.listings objectAtIndex:indexPath.row];
    [User postVisitedListingToCounter:self.currentUser withListing:listing withCompletion:^(BOOL finished) {}];
    [User postVisitedCategoryToCounter:self.currentUser withListing:listing withCompletion:^(BOOL finished) {}];
    
    [self performSegueWithIdentifier:@"ListingsByCategoryToListingDetail" sender:listing];
}

- (BOOL) isConnectedToInternet{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    return [reach isReachable];
}
-(void) displayConnectionErrorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to connect to the internet" message:@"Please check your internet connection and try again." preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{ }];
}
-(void) updateSaveButtonUI:(BOOL)isSaved withButton:(UIButton *)saveButton{
    if (isSaved){
        [saveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
    }
    else{
        [saveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
}
- (IBAction) didTapSaveIcon:(UIButton *)sender {
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        Listing *listing = self.listings[sender.tag];
        if (listing.isSaved){
            [Listing postUnsaveListing:listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded){
                    listing.isSaved = FALSE;
                    [self updateSaveButtonUI:listing.isSaved withButton: sender];
                    [self.categoryTableView reloadData];
                }
                else{
                    NSLog(@"unsuccessful save");
                }
            }];
        }
        else{
            [Listing postSaveListing:listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded){
                    listing.isSaved = TRUE;
                    [self updateSaveButtonUI:listing.isSaved withButton: sender];
                    [self.categoryTableView reloadData];
                }
                else{
                    NSLog(@"unsuccessful save");
                }
            }];
        }
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ListingsByCategoryToListingDetail"]){
        ListingDetailViewController *listingDetailViewController = [segue destinationViewController];
        listingDetailViewController.listing = sender;
    }
}



@end

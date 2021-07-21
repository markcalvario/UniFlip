//
//  HomeViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/12/21.
//

#import "HomeViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "Listing.h"
#import "CategoryCell.h"
#import "ListingCell.h"
#import "User.h"
#import "ListingDetailViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *listingCategoryTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchListingsBar;
@property (strong, nonatomic) NSMutableDictionary *categoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;
@property (strong, nonatomic) User *currentUser;
@property (nonatomic) BOOL hasCalledViewDidLoad;
@property (strong, nonatomic) NSMutableDictionary *filteredCategoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *filteredArrayOfCategories;
@property (strong, nonatomic) NSMutableArray *allListings;
@end

@implementation HomeViewController
BOOL isFiltered;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentUser = [User currentUser];
    isFiltered = NO;
    self.listingCategoryTableView.delegate = self;
    self.listingCategoryTableView.dataSource = self;
    self.searchListingsBar.delegate = self;
    self.hasCalledViewDidLoad = TRUE;
    [self updateListingsByCategory];
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isFiltered = NO;
    if (!self.hasCalledViewDidLoad){
        [self updateListingsByCategory];
    }
    self.hasCalledViewDidLoad = FALSE;

        //-> call updateListingsByCategory function
}


-(void) updateListingsByCategory{
    dispatch_group_t dispatchGroup = dispatch_group_create();

    
    self.categoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.arrayOfCategories = [NSMutableArray array];
    

    self.allListings = [NSMutableArray array];

    PFQuery *query = [Listing query];
    [query includeKey:@"savedBy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    //NSMutableDictionary *categoryToListings = [NSMutableDictionary dictionary];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Listing *> * _Nullable listings, NSError * _Nullable error) {
        if (listings) {
            //NSLog(@"%@", self.categoryToArrayOfPosts);
            for (Listing *listing in listings){
                if ([listing.author.university isEqualToString: self.currentUser.university]){
                    __block BOOL isListingSaved = FALSE;
                    //Adding listing to appropiate dictionary key
                    NSString *category = listing.listingCategory;
                    if ( [self.categoryToArrayOfPosts objectForKey:listing.listingCategory]){
                        NSMutableArray *arrayOfListingsValue = [self.categoryToArrayOfPosts objectForKey:category];
                        [arrayOfListingsValue addObject:listing];
                        [self.categoryToArrayOfPosts setObject:arrayOfListingsValue forKey:category];
                    }
                    else{
                        NSMutableArray *arrayOfListingsValue = [[NSMutableArray alloc] init];
                        [arrayOfListingsValue addObject:listing];
                        [self.arrayOfCategories addObject: category];
                        [self.categoryToArrayOfPosts setObject:arrayOfListingsValue forKey:category];
                    }
                    [self.allListings addObject:listing];
                    dispatch_group_enter(dispatchGroup);
                    //checking for saved listings by user
                    PFRelation *relation = [listing relationForKey:@"savedBy"];
                    PFQuery *query = [relation query];
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
                        if (arrayOfUsers){
                            for (User *user in arrayOfUsers){
                                if ([user.username isEqualToString: self.currentUser.username]){
                                    listing.isSaved = TRUE;
                                    isListingSaved = TRUE;
                                }
                            }
                            if (!isListingSaved){
                                listing.isSaved = FALSE;
                            }
                        }else{
                            NSLog(@"Could not load saved listings");
                        }
                        dispatch_group_leave(dispatchGroup);
                    }];
                }
            }
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
            [self.listingCategoryTableView reloadData];
        });
    }];
}
#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.filteredCategoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.filteredArrayOfCategories = [NSMutableArray array];
    if (searchText.length == 0){
        self.filteredCategoryToArrayOfPosts[@"Suggested Listings"] = [NSArray array];
        [self.filteredArrayOfCategories addObject:@"Suggested Listings"];
        //self.filteredCategoryToArrayOfPosts = self.filteredCategoryToArrayOfPosts;
        isFiltered = YES;
    }
    else{
        isFiltered = YES;
        for (Listing *listing in self.allListings){
            NSRange listingTitleRange = [listing.listingTitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (listingTitleRange.location != NSNotFound){
                if ( [self.filteredCategoryToArrayOfPosts objectForKey:listing.listingCategory]){
                    NSMutableArray *arrayOfListingsValue = [self.categoryToArrayOfPosts objectForKey:listing.listingCategory];
                    [self.filteredArrayOfCategories addObject: listing.listingCategory];
                    [self.filteredCategoryToArrayOfPosts setObject:arrayOfListingsValue forKey:listing.listingCategory];
                }
                else{
                    NSMutableArray *arrayOfListingsValue = [[NSMutableArray alloc] init];
                    [arrayOfListingsValue addObject:listing];
                    [self.filteredArrayOfCategories addObject: listing.listingCategory];
                    [self.filteredCategoryToArrayOfPosts setObject:arrayOfListingsValue forKey:listing.listingCategory];
                }
            }
        }
    }
    [self.listingCategoryTableView reloadData];

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.filteredCategoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.filteredArrayOfCategories = [NSMutableArray array];
    if (searchBar.text.length == 0){
        self.filteredCategoryToArrayOfPosts[@"Suggested Listings"] = [NSArray array];
        [self.filteredArrayOfCategories addObject:@"Suggested Listings"];
        //self.filteredCategoryToArrayOfPosts = self.filteredCategoryToArrayOfPosts;
        isFiltered = YES;
    }
    [self.listingCategoryTableView reloadData];

    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:TRUE];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isFiltered = NO;
    self.searchListingsBar.text = @"";
    [self.view endEditing:TRUE];
    [self.listingCategoryTableView reloadData];
}

#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString *category;
    if (isFiltered){
       category  = self.filteredArrayOfCategories[indexPath.row];
    }
    else{
        category = self.arrayOfCategories[indexPath.row];
    }
    cell.categoryLabel.text = category;
    cell.listingCollectionView.tag = indexPath.row;
    cell.listingCollectionView.scrollEnabled = NO;
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered){
        return [self.filteredCategoryToArrayOfPosts count];
    }
    return [self.categoryToArrayOfPosts count];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCell *tableViewCell = (CategoryCell *) cell;
    tableViewCell.listingCollectionView.delegate = self;
    tableViewCell.listingCollectionView.dataSource = self;
    [tableViewCell.listingCollectionView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *category = self.arrayOfCategories[indexPath.row];
    NSArray *listings = self.categoryToArrayOfPosts[category];
    CGFloat numOfListings = listings.count;
    CGFloat height = (245 * ceil(numOfListings/2)) + 50;
    return height;
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger tableViewIndex = collectionView.tag;
    NSString *tableViewCategory;
    NSArray *currentCategoryArray;
    if (isFiltered){
        tableViewCategory = self.filteredArrayOfCategories[tableViewIndex];
        currentCategoryArray = self.filteredCategoryToArrayOfPosts[tableViewCategory];
    }
    else{
        tableViewCategory = self.arrayOfCategories[tableViewIndex];
        currentCategoryArray = self.categoryToArrayOfPosts[tableViewCategory];
    }
    //NSLog(@"%@", currentCategoryArray);
    return currentCategoryArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListingCell *listingCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeScreenListingCell" forIndexPath:indexPath];
    NSInteger tableViewIndex = collectionView.tag;
    NSString *tableViewCategory;
    NSArray *currentCategoryArray;
    if (isFiltered){
        tableViewCategory = self.filteredArrayOfCategories[tableViewIndex];
        currentCategoryArray = self.filteredCategoryToArrayOfPosts[tableViewCategory];
    }
    else{
        tableViewCategory = self.arrayOfCategories[tableViewIndex];
        currentCategoryArray = self.categoryToArrayOfPosts[tableViewCategory];
    }
    Listing *listing = currentCategoryArray[indexPath.row];
    
    //Setting up cell
    listingCell.titleLabel.text = listing.listingTitle;
    NSString *price = listing.listingPrice;
    listingCell.priceLabel.text = [@"$" stringByAppendingString: price];
    listingCell.profileListingTitleLabel.text = listing.listingTitle;
    
    PFFileObject *listingImageFile = listing.listingImage;
    [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [listingCell.listingImage setImage:image];
                }
        }];
    
    /*UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSaveIcon:)];
    tapGesture.numberOfTapsRequired = 2;
    [listingCell.listingImage addGestureRecognizer:tapGesture];*/
    
    listingCell.saveButton.tag = indexPath.row;
    [listingCell.saveButton setTitle: listing.listingCategory forState:UIControlStateNormal];
    listingCell.saveButton.titleLabel.font = [UIFont systemFontOfSize:0];
    [self updateSaveButtonUI:listing.isSaved withButton: listingCell.saveButton];
    [listingCell.saveButton addTarget:self action:@selector(didTapSaveIcon:) forControlEvents: UIControlEventTouchUpInside];
    return listingCell;
    
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *category = self.arrayOfCategories[collectionView.tag];
    Listing *listing = self.categoryToArrayOfPosts[category][indexPath.row];
    if (isFiltered){
        category = self.filteredArrayOfCategories[collectionView.tag];
        listing = self.filteredCategoryToArrayOfPosts[category][indexPath.row];
    }
    else{
        category = self.arrayOfCategories[collectionView.tag];
        listing = self.categoryToArrayOfPosts[category][indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"HomeToListingDetail" sender:listing];
}

#pragma mark - Action Handlers
- (IBAction)didTapLogOut:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {    }];
}

- (IBAction)didTapSaveIcon:(UIButton *)sender {
    Listing *listing = self.categoryToArrayOfPosts[[sender currentTitle]][sender.tag];
    if (listing.isSaved){
        NSLog(@"was saved but is now not saved");
        [Listing postUnsaveListing:listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                listing.isSaved = FALSE;
                [self updateSaveButtonUI:listing.isSaved withButton: sender];
                [self.listingCategoryTableView reloadData];

            }
        }];
    }
    else{
        NSLog(@"was not saved but now is saved");
        [Listing postSaveListing:listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                listing.isSaved = TRUE;
                [self updateSaveButtonUI:listing.isSaved withButton: sender];
                [self.listingCategoryTableView reloadData];

            }
        }];
    }
    
}
-(void) updateSaveButtonUI:(BOOL )isSaved withButton:(UIButton *)saveButton{
    if (isSaved){
        [saveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
    }
    else{
        [saveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"HomeToListingDetail"]){
        ListingDetailViewController *listingDetailViewController = [segue destinationViewController];
        listingDetailViewController.listing = sender;
    }
}


@end

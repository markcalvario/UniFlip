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
#import "Reachability.h"
#import "CategoryViewController.h"
#import "ProfileCell.h"
#import "ProfileViewController.h"

#import <SystemConfiguration/SystemConfiguration.h>


@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *listingCategoryTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchListingsBar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) NSMutableDictionary *categoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSMutableDictionary *filteredCategoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *filteredArrayOfCategories;
@property (strong, nonatomic) NSMutableArray *allListings;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *suggestedListings;
@property (strong, nonatomic) NSArray *allUsersOfUniversity;
@property (strong, nonatomic) NSMutableArray *filteredUsers;
@property (strong, nonatomic) NSString *searchText;

@property (strong, nonatomic) NSString *selectedFilter;
@property (nonatomic) CGFloat categoryLabelHeight;
@end

@implementation HomeViewController
BOOL isFiltered;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchListingsBar.delegate = self;
    [self.searchListingsBar setUserInteractionEnabled:NO];
    isFiltered = NO;
    self.searchListingsBar.showsScopeBar = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateListingsByCategory) forControlEvents:UIControlEventValueChanged];
    [self.listingCategoryTableView insertSubview:self.refreshControl atIndex:0];
    self.listingCategoryTableView.delegate = self;
    self.listingCategoryTableView.dataSource = self;
    self.currentUser = [User currentUser];
    
    self.tabBarItem.image.isAccessibilityElement = YES;
    self.tabBarItem.image.accessibilityValue = @"Home Tab";
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self displayHomeScreen];
}
-(void) displayHomeScreen{
    if ([self isConnectedToInternet]){
        [self updateListingsByCategory];
        [User getAllUsersOfUniversity:self.currentUser.university withCompletion:^(NSArray * users) {
            if (users){
                self.allUsersOfUniversity = [NSMutableArray array];
                self.allUsersOfUniversity = users;
            }
        }];
    }
    else{
        [self displayConnectionErrorAlert];
    }
}
-(void) updateListingsByCategory{
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        [self.loadingSpinner startAnimating];
        self.loadingSpinner.hidden = NO;
        [self.view setAlpha:0.75];

        
        self.categoryToArrayOfPosts = [NSMutableDictionary dictionary];
        self.arrayOfCategories = [NSMutableArray array];
        self.allListings = [NSMutableArray array];
        
        __block NSMutableArray *allListings = [NSMutableArray array];
        PFQuery *query = [Listing query];
        [query includeKey:@"savedBy"];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"author"];
        [query findObjectsInBackgroundWithBlock:^(NSArray<Listing *> * _Nullable listings, NSError * _Nullable error) {
            if (listings) {
                allListings = [NSMutableArray arrayWithArray:listings];
                for (Listing *listing in allListings){
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
                        //checking for saved listings by user
                        PFRelation *relation = [listing relationForKey:@"savedBy"];
                        PFQuery *query = [relation query];
                        __block NSArray *savedByUsers = [NSArray array];
                        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
                            if (arrayOfUsers){
                                savedByUsers = arrayOfUsers;
                                for (User *user in savedByUsers){
                                    if ([user.username isEqualToString: self.currentUser.username]){
                                        listing.isSaved = TRUE;
                                        isListingSaved = TRUE;
                                    }
                                }
                                if (!isListingSaved){
                                    listing.isSaved = FALSE;
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.loadingSpinner stopAnimating];
                                    self.loadingSpinner.hidden = YES;
                                    [self.view setAlpha:1];
                                    [self.refreshControl endRefreshing];
                                    [self.listingCategoryTableView reloadData];
                                    [self updateSuggestedListings];
                                });
                            }else{
                                NSLog(@"Could not load saved listings");
                            }
                        }];
                    }
                }
            }
            else{
                NSLog(@"%@", error.localizedDescription);
            }
            
        }];
    }
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self updateSearchResults:searchText];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self displayScopeBar];
    self.searchListingsBar.showsCancelButton = YES;
    [self updateSearchResults:searchBar.text];
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:TRUE];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isFiltered = NO;
    self.searchListingsBar.showsScopeBar = NO;
    self.searchListingsBar.showsCancelButton = NO;
    self.searchListingsBar.text = @"";
    [self.view endEditing:TRUE];
    [self.listingCategoryTableView reloadData];
}
- (void) displayScopeBar{
    self.searchListingsBar.scopeButtonTitles = @[@"Listings", @"Users"];
    self.searchListingsBar.showsScopeBar = YES;
    self.selectedFilter = @"Listings";
}
- (void) updateSearchResults:(NSString *)searchText{
    self.filteredCategoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.filteredArrayOfCategories = [NSMutableArray array];
    self.filteredUsers = [NSMutableArray array];
    isFiltered = YES;
    self.searchText = searchText;
    NSString *searchBy = [self.searchListingsBar.scopeButtonTitles objectAtIndex:self.searchListingsBar.selectedScopeButtonIndex];
    if ([searchBy isEqualToString:@"Listings"]){
        if (searchText.length == 0){
            self.filteredCategoryToArrayOfPosts[@"Suggested Listings"] = self.suggestedListings;
            if (self.suggestedListings.count > 5){
                self.filteredCategoryToArrayOfPosts[@"Suggested Listings"] = [self.suggestedListings subarrayWithRange:NSMakeRange(0, 5)];
            }
            [self.filteredArrayOfCategories addObject:@"Suggested Listings"];
        }
        else{
            for (Listing *listing in self.allListings){
                NSRange listingTitleRange = [listing.listingTitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (listingTitleRange.location != NSNotFound){
                    if ( [self.filteredCategoryToArrayOfPosts objectForKey:listing.listingCategory]){
                        NSMutableArray *arrayOfListingsValue = [self.filteredCategoryToArrayOfPosts objectForKey:listing.listingCategory];
                        [arrayOfListingsValue addObject:listing];
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
    }
    else{
        for (User *user in self.allUsersOfUniversity){
            NSRange usernameRange = [user.username rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (usernameRange.location != NSNotFound){
                [self.filteredUsers addObject:user];
            }
        }
    }
    [self.listingCategoryTableView reloadData];
    
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    if (self.searchListingsBar.scopeButtonTitles.count > 0){
        NSString *searchBy = [self.searchListingsBar.scopeButtonTitles objectAtIndex:self.searchListingsBar.selectedScopeButtonIndex];
        self.selectedFilter = searchBy;
        [self updateSearchResults:self.searchText];
    }
}

#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    /*if (self.arrayOfCategories.count == 0 || self.categoryToArrayOfPosts.count == 0 || self.filteredArrayOfCategories.count == 0 || self.filteredCategoryToArrayOfPosts == 0){
        return nil;
    }*/
    if (isFiltered && ([self.selectedFilter isEqualToString:@"Users"]) && self.filteredUsers.count > 0){
        tableView.allowsSelection = YES;
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        User *user = [self.filteredUsers objectAtIndex:indexPath.row];
        [cell populateProfileCellInWithUser:user withIndexPath:indexPath withSearchText:self.searchText];
        return cell;
    }
    else{
        tableView.allowsSelection = NO;
        CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
        NSString *category;
        if (isFiltered && self.filteredArrayOfCategories.count > 0){
            category  = [self.filteredArrayOfCategories objectAtIndex:indexPath.row];
        }
        else{
            if (self.arrayOfCategories.count > 0){
                category = [self.arrayOfCategories objectAtIndex: indexPath.row];
            }
        }
        [cell populateCategoryCellInHomeWithCategory:category withIndexPath:indexPath];
        self.categoryLabelHeight = cell.categoryLabel.frame.size.height + cell.categoryLabelTopConstraint.constant + cell.categoryLabelBottomConstraint.constant;
        [cell.viewAllButton addTarget:self action:@selector(didTapViewAll:) forControlEvents:UIControlEventTouchUpInside];
        return cell;

    }
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered){
        if ([self.selectedFilter isEqualToString:@"Users"]){
            return [self.filteredUsers count];
        }
        return [self.filteredArrayOfCategories count];
    }
    return [self.categoryToArrayOfPosts count];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( ([self.selectedFilter isEqualToString:@"Listings"]) || (!isFiltered)){
        CategoryCell *tableViewCell = (CategoryCell *) cell;
        tableViewCell.listingCollectionView.delegate = self;
        tableViewCell.listingCollectionView.dataSource = self;
        [tableViewCell.listingCollectionView reloadData];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( ([self.selectedFilter isEqualToString:@"Users"]) && (isFiltered) && self.filteredUsers.count > 0){
        User *user = [self.filteredUsers objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"HomeToProfile" sender:user];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tableViewCategory;
    NSArray *currentCategoryArray;
    if (isFiltered && ([self.selectedFilter isEqualToString:@"Users"])){
        return 66;
    }
    if (isFiltered){
        tableViewCategory = self.filteredArrayOfCategories[indexPath.row];
        currentCategoryArray = self.filteredCategoryToArrayOfPosts[tableViewCategory];
    }
    else{
        tableViewCategory = self.arrayOfCategories[indexPath.row];
        currentCategoryArray = self.categoryToArrayOfPosts[tableViewCategory];
    }
    CGFloat numOfListings = currentCategoryArray.count;
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
        itemWidth = (tableView.frame.size.width - 3 *(numberOfItemsPerRow))/numberOfItemsPerRow;
        CGFloat itemHeight = itemWidth;
        
        CGFloat height = (itemHeight * ceil(numOfListings/numberOfItemsPerRow)) + self.categoryLabelHeight + 70;
        return height;
    }
    else{
        CGFloat numOfListings = currentCategoryArray.count;
        CGFloat height = (245 * ceil(numOfListings/2)) + 50;
        return height;
    }

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
    [listingCell withTitleLabel: listingCell.titleLabel withSaveButton:listingCell.saveButton withPriceLabel:listingCell.priceLabel withListingImage:listingCell.listingImage withListing:listing withCategory:tableViewCategory withIndexPath:indexPath withIsFiltered:isFiltered withSearchText:self.searchText];
    [self updateSaveButtonUI:listing.isSaved withButton: listingCell.saveButton];
    [listingCell.saveButton addTarget:self action:@selector(didTapSaveIcon:) forControlEvents: UIControlEventTouchUpInside];
    return listingCell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionViewLayout;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 3;
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
    NSString *category;
    Listing *listing;
    
    if (isFiltered){
        category = self.filteredArrayOfCategories[collectionView.tag];
        listing = self.filteredCategoryToArrayOfPosts[category][indexPath.row];
    }
    else{
        category = self.arrayOfCategories[collectionView.tag];
        listing = self.categoryToArrayOfPosts[category][indexPath.row];
    }
    [User postVisitedListingToCounter:self.currentUser withListing:listing withCompletion:^(BOOL finished) {}];
    [User postVisitedCategoryToCounter:self.currentUser withListing:listing withCompletion:^(BOOL finished) {}];
    
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
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        [self.loadingSpinner startAnimating];
        self.loadingSpinner.hidden = NO;
        [self.view setAlpha:0.75];
        Listing *listing;
        if (isFiltered){
            listing = self.filteredCategoryToArrayOfPosts[[sender currentTitle]][sender.tag];
        }
        else{
            listing = self.categoryToArrayOfPosts[[sender currentTitle]][sender.tag];
        }
        if (listing.isSaved){
            NSLog(@"was saved but is now not saved");
            [Listing postUnsaveListing:listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded){
                    listing.isSaved = FALSE;
                    [self updateSaveButtonUI:listing.isSaved withButton: sender];
                    [self.listingCategoryTableView reloadData];
                    [self.loadingSpinner stopAnimating];
                    self.loadingSpinner.hidden = YES;
                    [self.view setAlpha:1];
                }
                else{
                    NSLog(@"unsuccessful save");
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
                    [self.loadingSpinner stopAnimating];
                    self.loadingSpinner.hidden = YES;
                    [self.view setAlpha:1];
                }
                else{
                    NSLog(@"unsuccessful save");
                }
            }];
        }
    }
    
}
-(void) didTapViewAll: (UIButton *)button{
    NSArray *listings;
    NSString *category;
    
    if (!isFiltered && (self.arrayOfCategories.count > 0 && self.categoryToArrayOfPosts.count > 0)){
        category = [self.arrayOfCategories objectAtIndex:button.tag];
        listings = self.categoryToArrayOfPosts[category];
    }
    else{
        if (self.filteredArrayOfCategories.count > 0 && self.filteredCategoryToArrayOfPosts > 0){
            category = [self.filteredArrayOfCategories objectAtIndex:button.tag];
            listings = self.filteredCategoryToArrayOfPosts[category];
        }
    }
    [self performSegueWithIdentifier:@"HomeToViewByCategory" sender:listings];
}
-(void) updateSaveButtonUI:(BOOL)isSaved withButton:(UIButton *)saveButton{
    if (isSaved){
        [saveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
    }
    else{
        [saveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
}

-(void) updateSuggestedListings{
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        NSMutableArray *sortedListings = [NSMutableArray array];
        for (Listing *listing in self.allListings){
            if (![listing.author.objectId isEqualToString:self.currentUser.objectId]){
                [sortedListings addObject:listing];
            }
        }
        /// SORTING HERE
        NSMutableDictionary *categoryToMultiplier = [NSMutableDictionary dictionaryWithDictionary:self.currentUser[@"visitedCategoryToCounter"]];
        NSInteger totalListingsExcludingSelf = (NSInteger) self.allListings.count;
        for (NSString *category in categoryToMultiplier.allKeys){
            NSInteger count = [categoryToMultiplier[category] integerValue];
            float multiplier = count / (float) totalListingsExcludingSelf;
            [categoryToMultiplier setObject:[NSNumber numberWithFloat:multiplier] forKey:category];
        }
        
        NSMutableDictionary *profileToMultiplier = [NSMutableDictionary dictionaryWithDictionary:self.currentUser[@"visitedProfileToCounter"]];
        for (NSString *profileObject in profileToMultiplier.allKeys){
            NSInteger count = [profileToMultiplier[profileObject] integerValue];
            float multiplier = count / (float) totalListingsExcludingSelf;
            [profileToMultiplier setObject:[NSNumber numberWithFloat:multiplier] forKey:profileObject];
        }
        NSMutableDictionary *listingToMultiplier = [NSMutableDictionary dictionaryWithDictionary:self.currentUser[@"visitedListingsToCounter"]];
        for (NSString *listingObject in listingToMultiplier.allKeys){
            NSInteger count = [listingToMultiplier[listingObject] integerValue];
            float multiplier = count / (float) totalListingsExcludingSelf;
            [listingToMultiplier setObject:[NSNumber numberWithFloat:multiplier] forKey:listingObject];
        }
        
        NSMutableDictionary *listingToRanking = [NSMutableDictionary dictionary];
        for (Listing *listing in sortedListings){
            NSString *listingObjectId = listing.objectId;
            NSString *authorObjectId = listing.author.objectId;
            NSString *category = listing.listingCategory;
            
            float listingMultiplier = [listingToMultiplier[listingObjectId] floatValue];
            float authorMultiplier = [profileToMultiplier[authorObjectId] floatValue];
            float categoryMultiplier = [categoryToMultiplier[category] floatValue];
            
            float rankingValue = listingMultiplier + authorMultiplier + categoryMultiplier;
            [listingToRanking setObject:[NSNumber numberWithFloat:rankingValue] forKey:listing.objectId];
        }
        NSArray *listingToRankingKeys = [listingToRanking allKeys];
        NSArray *sortedKeys = [listingToRankingKeys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [[listingToRanking objectForKey:b] compare:[listingToRanking objectForKey:a]];
        }];
        
        NSMutableDictionary *listingIdToListing = [NSMutableDictionary dictionary];
        for (Listing *listing in sortedListings){
            [listingIdToListing setObject:listing forKey:listing.objectId];
        }
        
        sortedListings = [NSMutableArray array];
        for (NSString *listingId in sortedKeys){
            Listing *listing = [listingIdToListing valueForKey:listingId];
            [sortedListings addObject:listing];
        }
        
        self.suggestedListings = [NSArray arrayWithArray:sortedListings];
        [self.searchListingsBar setUserInteractionEnabled:YES];
        
    }
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"HomeToListingDetail"]){
        ListingDetailViewController *listingDetailViewController = [segue destinationViewController];
        listingDetailViewController.listing = sender;
    }
    if ([[segue identifier] isEqualToString:@"HomeToViewByCategory"]){
        CategoryViewController *listingDetailViewController = [segue destinationViewController];
        listingDetailViewController.listings = sender;
        Listing *listing = [sender objectAtIndex:0];
        listingDetailViewController.category = listing.listingCategory;
    }
    if ([[segue identifier] isEqualToString:@"HomeToProfile"]){
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = sender;
    }

}


@end

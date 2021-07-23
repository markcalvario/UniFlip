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
#import "Reachability.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *listingCategoryTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchListingsBar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) NSMutableDictionary *categoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;
@property (strong, nonatomic) User *currentUser;
@property (nonatomic) BOOL hasCalledViewDidLoad;
@property (strong, nonatomic) NSMutableDictionary *filteredCategoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *filteredArrayOfCategories;
@property (strong, nonatomic) NSMutableArray *allListings;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *suggestedListings;



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
    [self.searchListingsBar setUserInteractionEnabled:NO];
    self.hasCalledViewDidLoad = TRUE;
    [self updateSuggestedListings:^(BOOL completed) {
        if (completed){
            [self updateListingsByCategory];
            [self.searchListingsBar setUserInteractionEnabled:YES];

        }
    }];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateListingsByCategory) forControlEvents:UIControlEventValueChanged];
    [self.listingCategoryTableView insertSubview:self.refreshControl atIndex:0];
    
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isFiltered = NO;
    if (!self.hasCalledViewDidLoad && [self isConnectedToInternet]){
        //[self updateListingsByCategory];
        [self updateSuggestedListings:^(BOOL completed) {
            if (completed){
                [self updateListingsByCategory];
                [self.searchListingsBar setUserInteractionEnabled:YES];

            }
        }];
    }
    else if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    
    self.hasCalledViewDidLoad = FALSE;
}
- (BOOL) isConnectedToInternet{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    return [reach isReachable];
}
-(void) displayConnectionErrorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to connect to the internet" message:@"Please check your internet connection and try again." preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{ }];
}
-(void) updateListingsByCategory{
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        dispatch_group_t dispatchGroup = dispatch_group_create();
        [self.loadingSpinner startAnimating];
        NSLog(@"updating listings");
        self.loadingSpinner.hidden = NO;
        [self.view setAlpha:0.75];

        
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
                [self.loadingSpinner stopAnimating];
                self.loadingSpinner.hidden = YES;
                [self.view setAlpha:1];
                [self.refreshControl endRefreshing];
                [self.listingCategoryTableView reloadData];
            });
        }];
    }
    
}
#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.filteredCategoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.filteredArrayOfCategories = [NSMutableArray array];
    if (searchText.length == 0){
        self.filteredCategoryToArrayOfPosts[@"Suggested Listings"] = self.suggestedListings;
        [self.filteredArrayOfCategories addObject:@"Suggested Listings"];
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
        self.filteredCategoryToArrayOfPosts[@"Suggested Listings"] = self.suggestedListings;
        [self.filteredArrayOfCategories addObject:@"Suggested Listings"];
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
    NSString *tableViewCategory;
    NSArray *currentCategoryArray;
    if (isFiltered){
        tableViewCategory = self.filteredArrayOfCategories[indexPath.row];
        currentCategoryArray = self.filteredCategoryToArrayOfPosts[tableViewCategory];
    }
    else{
        tableViewCategory = self.arrayOfCategories[indexPath.row];
        currentCategoryArray = self.categoryToArrayOfPosts[tableViewCategory];
    }
    CGFloat numOfListings = currentCategoryArray.count;
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
    
    PFFileObject *listingImageFile = [listing.listingImages objectAtIndex:0];
    if (listingImageFile){
        [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [listingCell.listingImage setImage:image];
               
            }
        }];
    }
    else{
        listingImageFile = listing.listingImage;
        [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [listingCell.listingImage setImage:image];
               
            }
        }];
    }
    
    
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
    [self updateListingsToClicks:listing];
    [self updateCategoriesVisitedToClick:listing];
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
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        [self.loadingSpinner startAnimating];
        self.loadingSpinner.hidden = NO;
        [self.view setAlpha:0.75];
        Listing *listing = self.categoryToArrayOfPosts[[sender currentTitle]][sender.tag];
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
            }];
        }
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
-(void) updateListingsToClicks: (Listing *)listing{
    NSMutableDictionary *listingsToClicks = self.currentUser[@"listingsToClicks"];
    if (!listingsToClicks){
        listingsToClicks = [NSMutableDictionary dictionary];
    }
    if ([listingsToClicks objectForKey:listing.objectId]){
        //increment
        NSNumber *clicks = [listingsToClicks valueForKey:listing.objectId];
        int value = [clicks intValue];
        clicks = [NSNumber numberWithInt:value + 1];
        [listingsToClicks setValue:clicks forKey:listing.objectId];
    }
    else{
        [listingsToClicks setValue:@(1) forKey:listing.objectId];
    }
    self.currentUser[@"listingsToClicks"] = listingsToClicks;
    [self.currentUser saveInBackground];
}

-(void) updateCategoriesVisitedToClick: (Listing *)listing{
    NSMutableDictionary *categoriesVisitedToClick = self.currentUser[@"categoriesVisitedToClick"];
    if (!categoriesVisitedToClick){
        categoriesVisitedToClick = [NSMutableDictionary dictionary];
    }
    if ([categoriesVisitedToClick objectForKey:listing.listingCategory]){
        //increment
        NSNumber *clicks = [categoriesVisitedToClick valueForKey:listing.listingCategory];
        int value = [clicks intValue];
        clicks = [NSNumber numberWithInt:value + 1];
        [categoriesVisitedToClick setValue:clicks forKey:listing.listingCategory];
    }
    else{
        [categoriesVisitedToClick setValue:@(1) forKey:listing.listingCategory];
    }
    self.currentUser[@"categoriesVisitedToClick"] = categoriesVisitedToClick;
    [self.currentUser saveInBackground];
}

-(void) updateSuggestedListings:(void (^)(BOOL))completion{
    if (![self isConnectedToInternet]){
        [self displayConnectionErrorAlert];
    }
    else{
        dispatch_group_t dispatchGroup = dispatch_group_create();

        NSDictionary *categoriesVisitedToCount = self.currentUser[@"categoriesVisitedToClick"];
        //NSLog(@"%@", categoriesVisitedToCount);
        NSNumber *highestCount = 0;
        NSString *mostViewedCategory = @"";
        for (NSString *category in categoriesVisitedToCount){
            NSNumber *count = categoriesVisitedToCount[category];
            if ([count doubleValue] > [highestCount doubleValue]){
                highestCount = count;
                mostViewedCategory = category;
            }
        }
        NSDictionary *usersVisitedToCounter = self.currentUser[@"visitedProfileToCounter"];
        //NSLog(@"%@", usersVisitedToCounter);
        highestCount = 0;
        NSString *mostViewedUser = @"";
        for (NSString *user in usersVisitedToCounter){
            NSNumber *count = usersVisitedToCounter[user];
            if ([count doubleValue] > [highestCount doubleValue]){
                highestCount = count;
                mostViewedUser = user;
            }
        }
        PFQuery *query = [Listing query];
        [query includeKey:@"savedBy"];
        [query orderByDescending:@"saveCount"];
        [query includeKey:@"author"];
        //__block NSMutableArray *mutableArrayOfAllListings = [NSMutableArray array];
        __block NSMutableArray *sortedListings = [NSMutableArray array];
        dispatch_group_enter(dispatchGroup);
        [query findObjectsInBackgroundWithBlock:^(NSArray<Listing *> * _Nullable allListings, NSError * _Nullable error) {
            if (allListings) {
                //mutableArrayOfAllListings = [NSMutableArray arrayWithArray:allListings];
                sortedListings = [NSMutableArray array];
                NSInteger numberOfListingsWithHighestCategory = 0;
                for (Listing *listing in allListings){
                    if (![listing.author.objectId isEqualToString:self.currentUser.objectId]){
                        [sortedListings addObject:listing];
                        if ([listing.listingCategory isEqualToString:mostViewedCategory]){
                            numberOfListingsWithHighestCategory++;
                        }
                    }
                    
                }
                
                NSInteger length_of_array = (NSInteger) sortedListings.count;
                NSInteger starting_index = 0;
                NSInteger ending_index = (length_of_array - 1);

                while (ending_index > starting_index){
                    
                    Listing *starting_listing = [sortedListings objectAtIndex:starting_index];
                    Listing *ending_listing = [sortedListings objectAtIndex:ending_index];
                    //NSLog(@"%@", starting_listing[@"savedBy"]);
                    if ([starting_listing.listingCategory isEqualToString:mostViewedCategory]){
                        starting_index += 1;
                    }
                    else if (![starting_listing.listingCategory isEqualToString:mostViewedCategory] && [ending_listing.listingCategory isEqualToString:mostViewedCategory]){
                        [sortedListings exchangeObjectAtIndex:starting_index withObjectAtIndex:ending_index];
                        starting_index += 1;
                        ending_index -= 1;
                        
                    }
                    else{
                        //starting_index
                        ending_index -= 1;
                    }
                    

                }

                NSArray *mostViewedCategorySubarray = [sortedListings subarrayWithRange:NSMakeRange(0, numberOfListingsWithHighestCategory)];
                length_of_array = (NSInteger) mostViewedCategorySubarray.count;
                starting_index = 0;
                ending_index = (length_of_array - 1);
                while (ending_index > starting_index){
                    
                    Listing *starting_listing = [sortedListings objectAtIndex:starting_index];
                    Listing *ending_listing = [sortedListings objectAtIndex:ending_index];
                    //NSLog(@"%@", starting_listing[@"savedBy"]);
                    if ([starting_listing.author.objectId isEqualToString:mostViewedUser]){
                        starting_index += 1;
                    }
                    else if (![starting_listing.author.objectId isEqualToString:mostViewedUser] && [ending_listing.author.objectId isEqualToString:mostViewedUser]){
                        [sortedListings exchangeObjectAtIndex:starting_index withObjectAtIndex:ending_index];
                        starting_index += 1;
                        ending_index -= 1;
                    }
                    else{
                        //starting_index
                        ending_index -= 1;
                    }
                }
                
                
                
            }
            else{
                NSLog(@"%@", error.localizedDescription);
            }
            dispatch_group_leave(dispatchGroup);
        }];
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
            //NSLog(@"updated listings: %@", sortedListings);
            self.suggestedListings  = sortedListings;
            completion(TRUE);
        });
        //NSLog(@"%@ %@", mostViewedUser, mostViewedCategory);
        
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

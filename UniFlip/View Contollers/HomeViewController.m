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

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listingCategoryTableView;
@property (strong, nonatomic) NSMutableDictionary *categoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;
@property (strong, nonatomic) NSArray *arrayOfListings;
@property (strong, nonatomic) NSString *currentCategory;
@property (strong, nonatomic) NSMutableArray *arrayOfTableViewCells;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listingCategoryTableView.delegate = self;
    self.listingCategoryTableView.dataSource = self;
    self.categoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.arrayOfCategories = [NSMutableArray array];
    self.arrayOfTableViewCells = [NSMutableArray array];
    //[self getListingsByCategory];
    

}
-(void) viewWillAppear:(BOOL)animated{
    [self getListingsByCategory];
}

-(void) getListingsByCategory{
    PFQuery *queryListings = [PFQuery queryWithClassName:@"Listing"];
    [queryListings orderByDescending:@"createdAt"];
    [queryListings includeKey:@"listingCategory"];
    // fetch data asynchronously
    [queryListings findObjectsInBackgroundWithBlock:^(NSArray<Listing *> * _Nullable listings, NSError * _Nullable error) {
        if (listings) {
            // do something with the data fetched
            for (Listing *listing in listings){
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
            }
            [self.listingCategoryTableView reloadData];
        }
        else {        }
    }];
}

-(void) getSavedListingsByUser: (Listing *)listing completion:(void(^)(BOOL hasSavedListing))hasSavedListing{
    __block bool hasUserLikedListing = YES;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [listing relationForKey:@"savedBy"];
    PFQuery *queryForUsers = [relation query];
    [queryForUsers findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
        //NSLog(@"%@", arrayOfUsers);
        for (PFUser *user in arrayOfUsers){
            if ([user.objectId isEqualToString:currentUser.objectId]){
                NSLog(@"user has not saved this listing");
                hasUserLikedListing = NO;
                hasSavedListing(true);
            }
        }
        if (hasUserLikedListing){
            NSLog(@"user has saved this listing");
            hasSavedListing(false);
        }
    }];
}

#pragma mark - Action Handlers

- (IBAction)didTapLogOut:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {    }];
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}

#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString *category = self.arrayOfCategories[indexPath.row];
    self.currentCategory = category;
    cell.categoryLabel.text = category;
    cell.listingCollectionView.delegate = self;
    cell.listingCollectionView.dataSource = self;
    cell.listingCollectionView.tag = indexPath.row;
    
    //cell.listingCollectionView.parent
    //NSLog(@"from cellForRow...: %@", cell.categoryLabel.text);
    cell.listingCollectionView.scrollEnabled = NO;

    [self.arrayOfTableViewCells addObject:cell];
    
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoryToArrayOfPosts count];
}


#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSString *category = self.arrayOfCategories[collectionView.tag];
    //NSInteger lengthOfArray = [self.categoryToArrayOfPosts[self.currentCategory] count];
    NSInteger lengthOfArray = [self.categoryToArrayOfPosts[category] count];

    return lengthOfArray;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingCell" forIndexPath:indexPath];
    NSString *category = self.arrayOfCategories[collectionView.tag];
    //Listing *listing = self.categoryToArrayOfPosts[self.currentCategory][indexPath.row];
    Listing *listing = self.categoryToArrayOfPosts[category][indexPath.row];
    NSLog(@"loading listing title: %@", listing.listingTitle);
    cell.titleLabel.text = listing.listingTitle;
    NSString *price = listing.listingPrice;
    cell.priceLabel.text = [@"$" stringByAppendingString: price];
    PFFileObject *listingImageFile = listing.listingImage;
    [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [cell.imageButton setImage:image forState:UIControlStateNormal];
                }
            }];
    //like button
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton setTitle: listing.listingCategory forState:UIControlStateNormal];
    cell.likeButton.titleLabel.font = [UIFont systemFontOfSize:0];
    //[cell.likeButton addTarget:self action:@selector(didTapLikeIcon:) forControlEvents:UIControlEventTouchUpInside];
    /*[self getSavedListingsByUser:listing completion:^(BOOL hasSavedListing) {
        NSLog(@"%@", listing.listingTitle);
        if (hasSavedListing){
            [cell.likeButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
        }
        else{
            [cell.likeButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
        }
    }];*/
    
    return cell;
}

-(void) didTapLikeIcon:(UIButton *)sender{
    NSString *category = [sender currentTitle];
    self.currentCategory = category;
    CategoryCell *cell = self.arrayOfTableViewCells[ [self.arrayOfCategories indexOfObject:category]];
    Listing *listing = self.categoryToArrayOfPosts[category][sender.tag];
    NSLog(@"updating listing title: %@", listing.listingTitle);
    NSLog(@"updating this table view cell: %@", cell.categoryLabel.text);
    PFUser *currentUser = [PFUser currentUser];
    __block bool hasUserLikedListing = YES;
    PFRelation *relation = [listing relationForKey:@"savedBy"];
    PFQuery *queryForUsers = [relation query];
    [queryForUsers findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
        for (PFUser *user in arrayOfUsers){
            if ([user.username isEqualToString:currentUser.username]){
                NSLog(@"user has not saved this listing");
                hasUserLikedListing = NO;
                sender.selected = YES;
                [Listing postUserUnsave:listing withUser:currentUser withCompetion:^(BOOL succeeded, NSError * _Nullable error) {}];
                [cell.listingCollectionView reloadData];
            }
        }
        if (hasUserLikedListing){
            NSLog(@"user has saved this listing");
            sender.selected = NO;
            [Listing postUserSave:listing withUser:currentUser withCompetion:^(BOOL succeeded, NSError * _Nullable error) {}];
            [cell.listingCollectionView reloadData];

        }
    }];
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

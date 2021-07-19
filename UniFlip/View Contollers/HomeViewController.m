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

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UITableView *listingCategoryTableView;
@property (strong, nonatomic) NSMutableDictionary *categoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;
@property (strong, nonatomic) NSArray *arrayOfListings;
@property (strong, nonatomic) User *currentUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentUser = [User currentUser];
    self.listingCategoryTableView.delegate = self;
    self.listingCategoryTableView.dataSource = self;
    self.categoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.arrayOfCategories = [NSMutableArray array];
    [self updateListingsByCategory];
}
-(void) viewWillAppear:(BOOL)animated{
    [self.listingCategoryTableView reloadData];
}
-(void) updateListingsByCategory{
    dispatch_group_t dispatchGroup = dispatch_group_create();
    PFQuery *query = [Listing query];
    [query includeKey:@"savedBy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Listing *> * _Nullable listings, NSError * _Nullable error) {
        if (listings) {
            
            for (Listing *listing in listings){
                __block BOOL isListingSaved = FALSE;
                dispatch_group_enter(dispatchGroup);
                
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
        else{
            NSLog(@"%@", error.localizedDescription);
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
            [self.listingCategoryTableView reloadData];
        });
    }];
}

#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString *category = self.arrayOfCategories[indexPath.row];
    cell.categoryLabel.text = category;
    cell.listingCollectionView.tag = indexPath.row;
    cell.listingCollectionView.scrollEnabled = NO;
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    NSString *tableViewCategory = self.arrayOfCategories[tableViewIndex];
    NSArray *currentCategoryArray = self.categoryToArrayOfPosts[tableViewCategory];
    
    return currentCategoryArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListingCell *listingCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeScreenListingCell" forIndexPath:indexPath];
    NSInteger tableViewIndex = collectionView.tag;
    NSString *tableViewCategory = self.arrayOfCategories[tableViewIndex];
    NSArray *currentCategoryArray = self.categoryToArrayOfPosts[tableViewCategory];
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
    listingCell.saveButton.tag = indexPath.row;
    [listingCell.saveButton setTitle: listing.listingCategory forState:UIControlStateNormal];
    listingCell.saveButton.titleLabel.font = [UIFont systemFontOfSize:0];
    [self updateSaveButtonUI:listing.isSaved withButton: listingCell.saveButton];
    [listingCell.saveButton addTarget:self action:@selector(didTapSaveIcon:) forControlEvents: UIControlEventTouchUpInside];

    
    /*UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(didTapListing:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    listingCell.userInteractionEnabled = YES;
    [listingCell addGestureRecognizer:tapRecognizer];*/
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

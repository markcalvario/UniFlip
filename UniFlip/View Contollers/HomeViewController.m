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
@property (strong, nonatomic) NSString *currentCategory;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listingCategoryTableView.delegate = self;
    self.listingCategoryTableView.dataSource = self;
    self.categoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.arrayOfCategories = [NSMutableArray array];
    [self getListingsByCategory];
    
    
    /*CGFloat postsPerRow = 3;
    CGFloat itemWidth = (self.postsCollectionView.frame.size.width - layout.minimumInteritemSpacing * (postsPerRow) )/ postsPerRow;
    CGFloat itemHeight = itemWidth * 1;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);*/
}
/*-(void) viewWillAppear:(BOOL)animated{
    [self getListingsByCategory];
}
*/

- (IBAction)didTapLogOut:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
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
            //[self.]
        }
        else {
            // handle error
        }
    }];
}


#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString *category = self.arrayOfCategories[indexPath.row];
    self.currentCategory = category;
    cell.categoryLabel.text = category;
    cell.listingCollectionView.delegate = self;
    cell.listingCollectionView.dataSource = self;
    [cell.listingCollectionView reloadData];
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoryToArrayOfPosts count];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger lengthOfArray = [self.categoryToArrayOfPosts[self.currentCategory] count];
    return lengthOfArray;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingCell" forIndexPath:indexPath];
    Listing *listing = self.categoryToArrayOfPosts[self.currentCategory][indexPath.row];
    NSLog(@"%@", listing);
    cell.titleLabel.text = listing.listingTitle;
    cell.priceLabel.text = listing.listingPrice;
    PFFileObject *listingImageFile = listing.listingImage;
    [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [cell.imageButton setImage:image forState:UIControlStateNormal];
                }
            }];
   
    return cell;
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

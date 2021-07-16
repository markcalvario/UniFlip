//
//  ProfileViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/15/21.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "User.h"
#import "Listing.h"
#import "ListingCell.h"
#import <SystemConfiguration/SystemConfiguration.h>


@interface ProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *listingsCollectionView;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *arrayOfListings;


@end

@implementation ProfileViewController
BOOL showUserListings = TRUE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.user){
        self.user = [User currentUser];
    }
    [self setProfileScreen];
    [self setCollectionViewStyle];

    
}

-(void) setProfileScreen{
    self.arrayOfListings = [NSMutableArray array];

    self.listingsCollectionView.dataSource = self;
    self.listingsCollectionView.delegate = self;
    self.usernameLabel.text = self.user.username;
    self.userBioLabel.text = self.user.biography;
    /*if (self.user.profilePicture){
        [self.profilePicButton setImage:self.user.profilePicture forState:UIControlStateNormal];
    }
    */
    if (showUserListings){
        [self getListingsBasedOnSavedButton:TRUE];
    }
    else{
        [self getListingsBasedOnSavedButton:FALSE];
    }
}

#pragma mark - If User wants their saved listings
-(void) getListingsBasedOnSavedButton: (BOOL) getAllUserListings {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    PFQuery *query = [Listing query];
    [query includeKey:@"savedBy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    if (getAllUserListings){
        [query whereKey:@"author" equalTo:self.user];
    }
    NSMutableArray *savedListings = [NSMutableArray array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *listings, NSError *error) {
        if (listings != nil) {
            for (Listing *listing in listings){
                dispatch_group_enter(dispatchGroup);
                PFRelation *relation = [listing relationForKey:@"savedBy"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
                    NSLog(@"%@", listing);
                    if (arrayOfUsers){
                        for (User *user in arrayOfUsers){
                            if ([user.username isEqualToString: self.user.username]){
                                NSLog(@"user has saved this listing");
                                listing.isSaved = TRUE;
                                [savedListings addObject:listing];
                            }
                        }
                        if (getAllUserListings && (!listing.isSaved)){
                            listing.isSaved = FALSE;
                            [savedListings addObject:listing]; //maybe refactor
                            NSLog(@"user has not saved this listing");

                        }
                        self.arrayOfListings = savedListings;
                    }else{
                        NSLog(@"Could not load saved listings");
                    }
                    dispatch_group_leave(dispatchGroup);
                }];
            
            }
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
             [self.listingsCollectionView reloadData];
        });
    }];
}

#pragma mark - Action Handlers
- (IBAction)didTapGetOwnListings:(id)sender {
    showUserListings = TRUE;
    [self setProfileScreen];
}
- (IBAction)didTapGetSavedListings:(id)sender {
    showUserListings = FALSE;
    [self setProfileScreen];
}


#pragma mark - Collection View

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingCell" forIndexPath:indexPath];
    Listing *listing = self.arrayOfListings[indexPath.row];
    [Listing PFFileToUIImage:listing.listingImage completion:^(UIImage* image, NSError * error) {
        [cell.profileListingImageButton setImage:image forState:UIControlStateNormal];
    }];
    NSString *price = [@"$" stringByAppendingString:listing.listingPrice];
    cell.profileListingPriceLabel.text = price;
    cell.profileListingTitleLabel.text = listing.listingTitle;
    NSLog(@"listing: %@ isSaved: %d", listing.listingTitle, listing.isSaved);
    if (listing.isSaved){
        [cell.profileListingSaveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
    }
    else{
        [cell.profileListingSaveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
    
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrayOfListings.count;
}

-(void) setCollectionViewStyle{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.listingsCollectionView.collectionViewLayout;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    CGFloat postsPerRow = 2;
    CGFloat itemWidth = (self.listingsCollectionView.frame.size.width - layout.minimumInteritemSpacing * (postsPerRow) )/ postsPerRow;
    CGFloat itemHeight = itemWidth * 1;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
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

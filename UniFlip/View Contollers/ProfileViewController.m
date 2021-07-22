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
#import "ListingDetailViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>

#import <objc/runtime.h>
#import <MaterialComponents/MaterialTabs+TabBarView.h>




@interface ProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, MDCTabBarViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *listingsCollectionView;
@property (strong, nonatomic) NSMutableArray *arrayOfListings;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) NSMutableArray *toolbarButtons;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) UIAlertController *photoSelectorAlert;
@property (strong, nonatomic) User *currentUser;

@property (strong, nonatomic) IBOutlet UIView *profileView;
@property (strong, nonatomic) MDCTabBarView *tabBarView;
@property (readwrite, strong, nonatomic, nullable) UITabBarItem *selectedItem;

@end

@implementation ProfileViewController
BOOL showUserListings = TRUE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentUser = [User currentUser];
    [self displayTabBar];
    
    [self setProfileScreen];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self setProfileScreen];
}

-(void) setProfileScreen{
    if (!self.user){
        self.user = self.currentUser;
    }
    //User is viewing themselves
    if ([self.user.objectId isEqualToString: self.currentUser.objectId]){
        self.settingsButton.hidden = NO;
    }
    //User is viewing a different user
    else{
        self.settingsButton.hidden = YES;
        //[self.usersListingsButton setTitle:@"Listings Posted" forState:UIControlStateNormal];
    }
    
    self.toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    self.arrayOfListings = [NSMutableArray array];
    self.listingsCollectionView.dataSource = self;
    self.listingsCollectionView.delegate = self;
    self.usernameLabel.text = self.user.username;
    self.userBioLabel.text = self.user.biography;
    self.profilePicButton.layer.cornerRadius = self.profilePicButton.frame.size.width / 2;
    self.profilePicButton.clipsToBounds = YES;
    
    PFFileObject *userProfilePicture = self.user.profilePicture;
    if (userProfilePicture){
        [Listing PFFileToUIImage:userProfilePicture completion:^(UIImage * image, NSError * error) {
            if (image){
                [self.profilePicButton setImage: [ListingDetailViewController imageWithImage:image scaledToWidth:414] forState:UIControlStateNormal];
            }
            else{
                [self.profilePicButton setImage: [UIImage imageNamed:@"default_profile_pic"] forState:UIControlStateNormal];
                
            }
        }];
    }
    showUserListings ? [self getListingsBasedOnSavedButton:TRUE] : [self getListingsBasedOnSavedButton:FALSE];
   
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
        if (listings) {
            for (Listing *listing in listings){
                __block BOOL isSaved = FALSE;
                dispatch_group_enter(dispatchGroup);
                PFRelation *relation = [listing relationForKey:@"savedBy"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
                    if (arrayOfUsers){
                        if (getAllUserListings && ([listing.author.username isEqualToString: self.user.username])){
                            for (User *user in arrayOfUsers){
                                if ([user.username isEqualToString: self.currentUser.username]){
                                    //NSLog(@"user has saved this listing");
                                    listing.isSaved = TRUE;
                                    isSaved = TRUE;
                                    [savedListings addObject:listing];
                                }
                            }
                            if (getAllUserListings && (!isSaved)){
                                //NSLog(@"user has not saved this listing");
                                listing.isSaved = FALSE;
                                [savedListings addObject:listing];
                            }

                        }else{
                            for (User *user in arrayOfUsers){
                                if ([user.username isEqualToString: self.user.username]){
                                    //NSLog(@"user has saved this listing");
                                    //listing.isSaved = TRUE;
                                    [savedListings addObject:listing];
                                }
                                if ([user.username isEqualToString: self.currentUser.username]){
                                    //NSLog(@"user has saved this listing");
                                    listing.isSaved = TRUE;
                                }
                            }
        
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

-(void) updateSaveButtonUI:(BOOL )isSaved withButton:(UIButton *)saveButton{
    if (isSaved){
        [saveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
    }
    else{
        [saveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
}
#pragma mark - Action Handlers
- (IBAction)didTapSettingButton:(id)sender {
}
- (void) didTapSaveIcon:(UIButton *)sender {
    Listing *listing = self.arrayOfListings[sender.tag];
    if (listing.isSaved){
        NSLog(@"was saved but is now not saved");
        [Listing postUnsaveListing:listing withUser:self.user completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                listing.isSaved = FALSE;
                [self updateSaveButtonUI:listing.isSaved withButton: sender];
                [self.listingsCollectionView reloadData];

            }
        }];
    }
    else{
        NSLog(@"was not saved but now is saved");
        [Listing postSaveListing:listing withUser:self.user completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                listing.isSaved = TRUE;
                [self updateSaveButtonUI:listing.isSaved withButton: sender];
                [self.listingsCollectionView reloadData];

            }
        }];
    }
    
}


#pragma mark - Collection View

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingCell" forIndexPath:indexPath];
    Listing *listing = self.arrayOfListings[indexPath.row];
    [Listing PFFileToUIImage:listing.listingImage completion:^(UIImage* image, NSError * error) {
        [cell.profileListingImage setImage:image];
    }];
    NSString *price = [@"$" stringByAppendingString:listing.listingPrice];
    cell.profileListingPriceLabel.text = price;
    cell.profileListingTitleLabel.text = listing.listingTitle;
    if (listing.isSaved){
        [cell.profileListingSaveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
    }
    else{
        [cell.profileListingSaveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
    cell.profileListingSaveButton.tag = indexPath.row;
    [self updateSaveButtonUI:listing.isSaved withButton: cell.profileListingSaveButton];
    [cell.profileListingSaveButton addTarget:self action:@selector(didTapSaveIcon:) forControlEvents: UIControlEventTouchUpInside];
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrayOfListings.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionViewLayout;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 3;

    
    CGFloat numberOfItemsPerRow = 2;
    CGFloat itemWidth = (collectionView.frame.size.width - (layout.minimumInteritemSpacing * (numberOfItemsPerRow)) )/numberOfItemsPerRow;
    CGFloat itemHeight = itemWidth *1.25;
    return CGSizeMake(itemWidth, itemHeight);
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Listing *listing = self.arrayOfListings[indexPath.row];
    [self updateListingsToClicks: listing];
    [self updateCategoriesVisitedToClick: listing];

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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ProfileToListingDetail"]){
        ListingCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.listingsCollectionView indexPathForCell:tappedCell];
        Listing *listing = self.arrayOfListings[indexPath.row];
        ListingDetailViewController *listingDetailViewController = [segue destinationViewController];
        listingDetailViewController.listing = listing;
        
    }
}

- (void)tabBarView:(MDCTabBarView *)tabBarView didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString:@"Listings"]){
        showUserListings = TRUE;
    }
    else{
        showUserListings = FALSE;
    }
    [self setProfileScreen];
}

-(void) displayTabBar{
    self.tabBarView = [[MDCTabBarView alloc] init];
    
    self.tabBarView.items = @[
        [[UITabBarItem alloc] initWithTitle:@"Listings" image:nil tag:0],
        [[UITabBarItem alloc] initWithTitle:@"Saved" image:nil tag:0],
    ];
    self.tabBarView.preferredLayoutStyle = MDCTabBarViewLayoutStyleFixed; // or MDCTabBarViewLayoutStyleFixed
    self.tabBarView.frame = CGRectMake(8, 157.5, 394, 15);
    self.tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.profileView addSubview:self.tabBarView];
    //[self.tabBarView setBarTintColor:[UIColor blackColor]];
    //[self.tabBarView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[self.tabBarView setSelectionIndicatorStrokeColor:[UIColor whiteColor]];
    self.tabBarView.tabBarDelegate = self;
    [self.tabBarView setSelectedItem:[self.tabBarView.items objectAtIndex:0]];

    /* Leading space to superview */
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                    constraintWithItem: self.tabBarView
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem: self.userBioLabel.superview
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                    constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.tabBarView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem: self.userBioLabel.superview
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0
                                       constant:0];
    /* Top space to superview Y*/
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual toItem:self.userBioLabel attribute:
                                                 NSLayoutAttributeBottom multiplier:1.0 constant:4];
    /* Bottom space to superview Y*/
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeBottom
                                                 relatedBy:NSLayoutRelationEqual toItem:self.listingsCollectionView attribute:
                                                 NSLayoutAttributeTop multiplier:1.0 constant:-4];
    
    /* 4. Add the constraints to button's superview*/
    [self.profileView addConstraint:leading];
    [self.profileView addConstraint:trailing];
    [self.profileView addConstraint:top];
    [self.profileView addConstraint:bottom];
}




@end

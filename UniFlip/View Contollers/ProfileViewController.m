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


@interface ProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *listingsCollectionView;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *arrayOfListings;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveSettingsButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) NSMutableArray *toolbarButtons;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;



@end

@implementation ProfileViewController
BOOL showUserListings = TRUE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setProfileScreen];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self setProfileScreen];
}

-(void) setProfileScreen{
    if (!self.user){
        self.user = [User currentUser];
    }
    self.toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    if ([self.user isEqual:[User currentUser]]){
        self.settingsButton.hidden = NO;
        self.cancelButton.hidden = YES;
        self.saveSettingsButton.hidden = YES;
    }
    

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
        if (listings) {
            for (Listing *listing in listings){
                dispatch_group_enter(dispatchGroup);
                PFRelation *relation = [listing relationForKey:@"savedBy"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
                    if (arrayOfUsers){
                        if (getAllUserListings){
                            listing.isSaved = !listing.isSaved;
                            [savedListings addObject:listing]; //maybe refactor
                            //NSLog(@"user has not saved this listing");

                        }else{
                            for (User *user in arrayOfUsers){
                                if ([user.username isEqualToString: self.user.username]){
                                    NSLog(@"user has saved this listing");
                                    listing.isSaved = TRUE;
                                    [savedListings addObject:listing];
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
-(void) showSettingsIcon{
    if (![self.toolbarButtons containsObject:self.settingsBarButton]) {
        [self.toolbarButtons insertObject:self.settingsBarButton atIndex:0];
        [self.navigationItem setRightBarButtonItems:self.toolbarButtons animated:YES];
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
#pragma mark - Action Handlers
- (IBAction)didTapGetOwnListings:(id)sender {
    showUserListings = TRUE;
    [self showSettingsIcon];
    [self setProfileScreen];
    
}
- (IBAction)didTapGetSavedListings:(id)sender {
    showUserListings = FALSE;
    [self showSettingsIcon];
    [self setProfileScreen];
}
- (IBAction)didTapSettingButton:(id)sender {
    self.cancelButton.hidden = NO;
    self.saveSettingsButton.hidden = NO;
    [self.toolbarButtons removeObject:self.settingsBarButton];
    [self.navigationItem setRightBarButtonItems:self.toolbarButtons animated:YES];
}
- (IBAction)didTapCancelButton:(id)sender {
    self.cancelButton.hidden = YES;
    self.saveSettingsButton.hidden = YES;
    [self showSettingsIcon];

}
- (IBAction)saveSettingsButton:(id)sender {
    self.saveSettingsButton.hidden = YES;
    self.cancelButton.hidden = YES;
    [self showSettingsIcon];
    
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ProfileToListingDetail"]){
        ListingCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.listingsCollectionView indexPathForCell:tappedCell];
        Listing *listing = self.arrayOfListings[indexPath.row];
        ListingDetailViewController *listingDetailViewController = [segue destinationViewController];
        listingDetailViewController.listing = listing;
        
    }
}




@end

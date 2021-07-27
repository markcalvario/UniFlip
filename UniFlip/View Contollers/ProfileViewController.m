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
#import <MessageUI/MessageUI.h>


@interface ProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, MDCTabBarViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *listingsCollectionView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIView *profileView;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (strong, nonatomic) IBOutlet UIButton *followersButton;
@property (strong, nonatomic) IBOutlet UIButton *composeMailButton;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) NSMutableArray *arrayOfListings;
@property (strong, nonatomic) NSMutableArray *toolbarButtons;
@property (strong, nonatomic) UIAlertController *photoSelectorAlert;
@property (strong, nonatomic) User *currentUser;
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
    
    if ([self.tabBarView.selectedItem.title isEqualToString:@"Listings"]){
        showUserListings = TRUE;
    }
    else{
        showUserListings = FALSE;
    }
    
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
    [userProfilePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            [self.profilePicButton setImage:image forState:UIControlStateNormal];
        }
        else{
            [self.profilePicButton setImage: [UIImage imageNamed:@"default_profile_pic"] forState:UIControlStateNormal];
        }
    }];
    showUserListings ? [self updateListingsBasedOnTabBar:TRUE] : [self updateListingsBasedOnTabBar:FALSE];
   
    CALayer *imageLayer = self.composeMailButton.superview.layer;
    [imageLayer setCornerRadius:15];
    [imageLayer setBorderWidth:2];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    
    CGFloat widthOfButton = self.followButton.layer.frame.size.height/ 2;
    [[self.followButton layer] setCornerRadius: widthOfButton];
    [self.followButton setClipsToBounds:TRUE];
    [self.followButton setBackgroundColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1]];
    
}

#pragma mark - If User wants their saved listings
-(void) updateListingsBasedOnTabBar: (BOOL) getAllUserListings {
    //dispatch_group_t dispatchGroup = dispatch_group_create();
    self.arrayOfListings = [NSMutableArray array];
    __block NSMutableArray *usersListings = [NSMutableArray array];
    PFQuery *query = [Listing query];
    [query includeKey:@"savedBy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    if (getAllUserListings){
        [query whereKey:@"author" equalTo:self.user];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray * listings, NSError * _Nullable error) {
        if (listings){
            usersListings = [NSMutableArray arrayWithArray:listings];
        }
        for (Listing *listing in listings){
            __block BOOL isSaved = FALSE;
            PFRelation *relation = [listing relationForKey:@"savedBy"];
            PFQuery *query = [relation query];
            __block NSArray *savedByUsers = [NSArray array];
            [query findObjectsInBackgroundWithBlock:^(NSArray * users, NSError * _Nullable error) {
                if (!error){
                    savedByUsers = users;
                }
                for (User *user in savedByUsers){
                    if ([user.username isEqualToString:self.user.username]){
                        isSaved = TRUE;
                        listing.isSaved = TRUE;
                    }
                }
                if (!isSaved){
                    listing.isSaved = FALSE;
                    if (!getAllUserListings){
                        [usersListings removeObject:listing];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.arrayOfListings = [NSMutableArray arrayWithArray:usersListings];
                    [self.listingsCollectionView reloadData];
                });
            }];
        }
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
- (IBAction)didTapComposeEmail:(id)sender {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    __block NSString *email;
    [self.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        User *user = (User *)object;
        email = user.schoolEmail;
        [mc setToRecipients:[NSArray arrayWithObjects: email , nil]];
        // displaying our modal view controller on the screen with standard transition
        if (mc){
            [self presentViewController:mc animated:true completion:nil];
        }
    }];
   
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");

            break;

        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");

            break;

        case MFMailComposeResultSent:
            NSLog(@"Mail sent");

            break;

        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@",error.description);
            break;
    }
    // Dismiss the mail compose view controller.
    [controller dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - Collection View

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingCell" forIndexPath:indexPath];
    Listing *listing = self.arrayOfListings[indexPath.row];
    PFFileObject *listingImageFile = [listing.photos objectAtIndex:0];
    [Listing PFFileToUIImage: listingImageFile completion:^(UIImage* image, NSError * error) {
        [cell.profileListingImage setImage:image];
    }];
    
    NSString *price = [@"$" stringByAppendingString:listing.listingPrice];
    cell.profileListingPriceLabel.text = price;
    cell.profileListingTitleLabel.text = listing.listingTitle;
    cell.profileListingImage.image = nil;
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
    [User postVisitedListingToCounter:self.currentUser withListing:listing withCompletion:^(BOOL finished) {}];
    [User postVisitedCategoryToCounter:self.currentUser withListing:listing withCompletion:^(BOOL finished) {}];
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
    self.tabBarView.preferredLayoutStyle = MDCTabBarViewLayoutStyleFixed;
    //self.tabBarView.frame = CGRectMake(8, 157.5, 394, 15);
    self.tabBarView.frame = CGRectMake(8, self.followingButton.frame.origin.y+35, self.followingButton.superview.frame.size.width, 15);
    self.tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.profileView addSubview:self.tabBarView];
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
                                                 relatedBy:NSLayoutRelationEqual toItem:self.followingButton attribute:
                                                 NSLayoutAttributeBottom multiplier:1.0 constant:2];
    /* Bottom space to superview Y*/
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeBottom
                                                 relatedBy:NSLayoutRelationEqual toItem:self.listingsCollectionView attribute:
                                                 NSLayoutAttributeTop multiplier:1.0 constant:-2];
    
    NSLayoutConstraint *height = [NSLayoutConstraint
                                   constraintWithItem:self.tabBarView
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:0
                                   constant:35];
    
    /* 4. Add the constraints to button's superview*/
    [self.profileView addConstraint:leading];
    [self.profileView addConstraint:trailing];
    [self.profileView addConstraint:top];
    [self.profileView addConstraint:bottom];
    
    [self.tabBarView addConstraint:height];
}




@end

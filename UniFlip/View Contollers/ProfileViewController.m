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
@property (strong, nonatomic) IBOutlet UIView *backgroundViewForMailIcon;

@property (strong, nonatomic) NSArray *arrayOfListings;
@property (strong, nonatomic) UIAlertController *photoSelectorAlert;
@property (strong, nonatomic) User *currentlyLoggedInUser;
@property (strong, nonatomic) MDCTabBarView *tabBarView;
@property (readwrite, strong, nonatomic, nullable) UITabBarItem *selectedItem;
@property (strong, nonatomic) NSNumber *followersCount;

@end

@implementation ProfileViewController
BOOL showUserListings = TRUE;
BOOL isFollowingUserOfThisProfile = FALSE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentlyLoggedInUser = [User currentUser];
    if (!self.userOfProfileToView){
        self.userOfProfileToView = self.currentlyLoggedInUser;
    }
    self.listingsCollectionView.dataSource = self;
    self.listingsCollectionView.delegate = self;
    [self displayTabBar];
    [self addAccessibility];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self displayProfileScreen];
    [self.tabBarView setBackgroundColor:[UIColor systemBackgroundColor]];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        [self darkModeStyle];
    }
}
-(void) darkModeStyle{
    [self.tabBarView setSelectionIndicatorStrokeColor:[UIColor whiteColor]];
}

-(void) displayProfileScreen{
    if ([self.tabBarView.selectedItem.title isEqualToString:@"Listings"]){
        showUserListings = TRUE;
    }
    else{
        showUserListings = FALSE;
    }
    if ([self.userOfProfileToView.objectId isEqualToString: self.currentlyLoggedInUser.objectId]){
        self.settingsButton.hidden = NO;
        self.followButton.hidden = YES;
        self.composeMailButton.hidden = YES;
        self.backgroundViewForMailIcon.hidden = YES;
    }
    else{
        self.settingsButton.hidden = YES;
    }
    [self updateFollowerAndFollowingCount];
    
    self.usernameLabel.text = self.userOfProfileToView.username;
    self.userBioLabel.text = self.userOfProfileToView.biography;
    PFFileObject *userProfilePicture = self.userOfProfileToView.profilePicture;
    [userProfilePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            [self.profilePicButton setImage:image forState:UIControlStateNormal];
        }
        else{
            [self.profilePicButton setImage: [UIImage imageNamed:@"default_profile_pic"] forState:UIControlStateNormal];
        }
    }];
    [self styleProfileAndMailAndFollowButtons];
    showUserListings ? [self updateListingsBasedOnTabBar:TRUE] : [self updateListingsBasedOnTabBar:FALSE];
}
-(void) updateFollowerAndFollowingCount{
    PFRelation *relation = [self.userOfProfileToView relationForKey:@"following"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
        if (arrayOfUsers){
            for (User *user in arrayOfUsers){
                if ([user.objectId isEqualToString: self.userOfProfileToView.objectId]){
                    isFollowingUserOfThisProfile = TRUE;
                }
            }
            if (!isFollowingUserOfThisProfile){
                isFollowingUserOfThisProfile = FALSE;
            }
            PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
            [query whereKey:@"userFollowed" equalTo:self.userOfProfileToView.objectId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable followers, NSError * _Nullable error) {
                if (followers){
                    self.followersCount = followers[@"followersCount"];
                }
                if (!followers){
                    self.followersCount = @(0);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateFollowButtonUI: isFollowingUserOfThisProfile];
                    [self updateFollowerandFollowingButtonsUI];
                });
            }];
            
        }else{
            NSLog(@"Could not load users");
        }
    }];
}
-(void) styleProfileAndMailAndFollowButtons{
    CALayer *imageLayer = self.composeMailButton.superview.layer;
    [imageLayer setCornerRadius:15];
    [imageLayer setBorderWidth:2];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];

    CGFloat widthOfButton = self.followButton.layer.frame.size.height/ 2;
    [[self.followButton layer] setCornerRadius: widthOfButton];
    [self.followButton setClipsToBounds:TRUE];
    
    self.profilePicButton.layer.cornerRadius = self.profilePicButton.frame.size.width / 2;
    self.profilePicButton.clipsToBounds = YES;
}

#pragma mark - TabBar Action Handler
-(void) updateListingsBasedOnTabBar: (BOOL) getAllUserListings {
    __block NSMutableArray *usersListings = [NSMutableArray array];
    PFQuery *query = [Listing query];
    [query includeKey:@"savedBy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    if (getAllUserListings){
        [query whereKey:@"author" equalTo:self.userOfProfileToView];
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
                    if ([user.username isEqualToString:self.userOfProfileToView.username]){
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
                    self.arrayOfListings = [NSArray arrayWithArray:usersListings];
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
        [Listing postUnsaveListing:listing withUser:self.userOfProfileToView completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                listing.isSaved = FALSE;
                [self updateSaveButtonUI:listing.isSaved withButton: sender];
                [self.listingsCollectionView reloadData];

            }
        }];
    }
    else{
        NSLog(@"was not saved but now is saved");
        [Listing postSaveListing:listing withUser:self.userOfProfileToView completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                listing.isSaved = TRUE;
                [self updateSaveButtonUI:listing.isSaved withButton: sender];
                [self.listingsCollectionView reloadData];

            }
        }];
    }
    
}
- (IBAction)didTapComposeEmail:(id)sender {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    __block NSString *email;
    [self.userOfProfileToView fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        User *user = (User *)object;
        email = user.schoolEmail;
        [mailComposeViewController setToRecipients:[NSArray arrayWithObjects: email , nil]];
        if (mailComposeViewController){
            [self presentViewController:mailComposeViewController animated:true completion:nil];
        }
    }];
   
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;

        case MFMailComposeResultSaved:
            break;

        case MFMailComposeResultSent:
            break;

        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@",error.description);
            break;
    }
    [controller dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)didTapFollowButton:(id)sender {
    if (isFollowingUserOfThisProfile){
        [User postUnfollowingUser:self.userOfProfileToView withUnfollowedBy:self.currentlyLoggedInUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            succeeded ? NSLog(@"now not following user") : NSLog(@"error");
        }];
        [User postUnfollowedUser:self.userOfProfileToView withUnfollowedBy:self.currentlyLoggedInUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            succeeded ? NSLog(@"now user viewed has one less follower") : NSLog(@"error");
        }];
        self.followersCount = @([self.followersCount integerValue] - 1);
    }
    else{
        [User postFollowingUser:self.userOfProfileToView withFollowedBy:self.currentlyLoggedInUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            succeeded ? NSLog(@"now following user") : NSLog(@"error");
        }];
        [User postFollowedUser:self.userOfProfileToView withFollowedBy:self.currentlyLoggedInUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            succeeded ? NSLog(@"now user viewed has a follower") : NSLog(@"error");
        }];
        self.followersCount = @([self.followersCount integerValue] + 1);
    }
    isFollowingUserOfThisProfile = !isFollowingUserOfThisProfile;
    [self updateFollowButtonUI: isFollowingUserOfThisProfile];
    [self updateFollowerandFollowingButtonsUI];
}

- (void) updateFollowButtonUI:(BOOL) isFollowing{
    if (isFollowing){
        [self.followButton setBackgroundColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1]];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
    }
    if (!isFollowing){
        [self.followButton setBackgroundColor:[UIColor whiteColor]];
        [self.followButton setTitleColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1] forState:UIControlStateNormal];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton.layer setBorderWidth:2];
        [self.followButton.layer setBorderColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1].CGColor];
    }
}
- (void) updateFollowerandFollowingButtonsUI{
    if (!self.userOfProfileToView){
        NSString *followingTitle = [[self.currentlyLoggedInUser.followingCount stringValue] stringByAppendingString:@" following"];
        NSString *followersTitle = [[self.followersCount stringValue] stringByAppendingString:@" followers"];
        [self.followingButton setTitle:followingTitle forState:UIControlStateNormal];
        [self.followersButton setTitle:followersTitle forState:UIControlStateNormal];
    }
    else{
        NSString *followingTitle = [[self.userOfProfileToView.followingCount stringValue] stringByAppendingString:@" following"];
        NSString *followersTitle = [[self.followersCount stringValue] stringByAppendingString:@" followers"];
        [self.followingButton setTitle:followingTitle forState:UIControlStateNormal];
        [self.followersButton setTitle:followersTitle forState:UIControlStateNormal];
    }
    
}

#pragma mark - Collection View

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ListingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListingCell" forIndexPath:indexPath];
    Listing *listing = self.arrayOfListings[indexPath.row];
    [cell withTitleLabel:cell.profileListingTitleLabel withSaveButton:cell.profileListingSaveButton withPriceLabel:cell.profileListingPriceLabel withListingImage:cell.profileListingImage withListing:listing withCategory:@"" withIndexPath:indexPath withIsFiltered:NO withSearchText:@""];
    [self updateSaveButtonUI:listing.isSaved withButton: cell.profileListingSaveButton];
    [cell.profileListingSaveButton addTarget:self action:@selector(didTapSaveIcon:) forControlEvents: UIControlEventTouchUpInside];
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrayOfListings.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionViewLayout;
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 3;
    CGFloat numberOfItemsPerRow = 2;
    CGFloat itemWidth;
    if (self.view.frame.size.width > 600){
        CGFloat widthRequirement = 290;
        BOOL meetsWidthRequirement = TRUE;
        while (meetsWidthRequirement){
            itemWidth = (collectionView.frame.size.width - (layout.minimumInteritemSpacing * (numberOfItemsPerRow)) )/numberOfItemsPerRow;
            if (itemWidth <= widthRequirement){
                meetsWidthRequirement = FALSE;
            }
            numberOfItemsPerRow ++;
        }
    }
    itemWidth = (collectionView.frame.size.width - (layout.minimumInteritemSpacing * (numberOfItemsPerRow)) )/numberOfItemsPerRow;
    CGFloat itemHeight = itemWidth * 1.25;
    return CGSizeMake(itemWidth, itemHeight);
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Listing *listing = self.arrayOfListings[indexPath.row];
    [User postVisitedListingToCounter:self.currentlyLoggedInUser withListing:listing withCompletion:^(BOOL finished) {}];
    [User postVisitedCategoryToCounter:self.currentlyLoggedInUser withListing:listing withCompletion:^(BOOL finished) {}];
}

#pragma mark - TabBar
- (void)tabBarView:(MDCTabBarView *)tabBarView didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString:@"Listings"]){
        showUserListings = TRUE;
    }
    else{
        showUserListings = FALSE;
    }
    [self displayProfileScreen];
}

-(void) displayTabBar{
    self.tabBarView = [[MDCTabBarView alloc] init];
    
    self.tabBarView.items = @[
        [[UITabBarItem alloc] initWithTitle:@"Listings" image:nil tag:0],
        [[UITabBarItem alloc] initWithTitle:@"Saved" image:nil tag:0],
    ];
    self.tabBarView.preferredLayoutStyle = MDCTabBarViewLayoutStyleFixed;
    self.tabBarView.frame = CGRectMake(8, self.followingButton.frame.origin.y+35, self.followingButton.superview.frame.size.width, 15);
    self.tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.profileView addSubview:self.tabBarView];
    self.tabBarView.tabBarDelegate = self;
    [self.tabBarView setSelectedItem:[self.tabBarView.items objectAtIndex:0]];
    
    [self addConstraintsToTabBar];
}
-(void) addConstraintsToTabBar{
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
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.followingButton attribute:
                                                 NSLayoutAttributeBottom multiplier:1.0 constant:2];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeBottom
                                                 relatedBy:NSLayoutRelationEqual toItem:self.listingsCollectionView attribute:
                                                 NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *height = [NSLayoutConstraint
                                   constraintWithItem:self.tabBarView
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:0
                                   constant:35];
    
    [self.profileView addConstraint:leading];
    [self.profileView addConstraint:trailing];
    [self.profileView addConstraint:top];
    [self.profileView addConstraint:bottom];
    
    [self.tabBarView addConstraint:height];
}
-(void) addAccessibility{
    self.profilePicButton.isAccessibilityElement = YES;
    self.usernameLabel.isAccessibilityElement = YES;
    self.userBioLabel.isAccessibilityElement = YES;
    self.settingsButton.isAccessibilityElement = YES;
    self.composeMailButton.isAccessibilityElement = YES;
    self.followButton.isAccessibilityElement = YES;
    self.followingButton.isAccessibilityElement = YES;
    self.followersButton.isAccessibilityElement = YES;
    self.tabBarView.isAccessibilityElement = YES;
    self.tabBarView.accessibilityValue = @"Choose to view either a user's posted listings or their saved listings";
    for (UITabBarItem *item in self.tabBarView.items){
        item.isAccessibilityElement = YES;
        if ([item.title isEqualToString:@"Listings"]){
            item.accessibilityValue = [[@"Tap to view " stringByAppendingString:self.userOfProfileToView.username] stringByAppendingString:@"'s posted listings"];
        }
        else{
            item.accessibilityValue = [[@"Tap to view " stringByAppendingString:self.userOfProfileToView.username] stringByAppendingString:@"'s saved listings"];
        }
    }
    
    self.profilePicButton.accessibilityValue = [self.userOfProfileToView.username stringByAppendingString:@"'s profile picture"];
    self.usernameLabel.accessibilityValue = [@"User's username is " stringByAppendingString:self.userOfProfileToView.username];
    self.userBioLabel.accessibilityValue = [[self.userOfProfileToView.username stringByAppendingString:@"'s bio is "] stringByAppendingString:self.userOfProfileToView.biography];
    self.settingsButton.accessibilityValue = @"Tap to change your profile settings";
    self.composeMailButton.accessibilityValue = [@"Tap to send an e-mail to " stringByAppendingString:self.userOfProfileToView.username];
    self.followButton.accessibilityValue = [@"Tap to follow " stringByAppendingString:self.userOfProfileToView.username];
    self.followingButton.accessibilityValue = [[[self.userOfProfileToView.username stringByAppendingString:@" is following "] stringByAppendingString:self.followingButton.titleLabel.text] stringByAppendingString:@" other users"];
    self.followersButton.accessibilityValue = [[[self.userOfProfileToView.username stringByAppendingString:@" has "] stringByAppendingString:self.followersButton.titleLabel.text] stringByAppendingString:@" followers"];
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

@end

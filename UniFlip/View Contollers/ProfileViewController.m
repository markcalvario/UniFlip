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


@interface ProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *listingsCollectionView;
@property (strong, nonatomic) NSMutableArray *arrayOfListings;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveSettingsButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) NSMutableArray *toolbarButtons;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) UIAlertController *photoSelectorAlert;



@end

@implementation ProfileViewController
BOOL showUserListings = TRUE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setProfileScreen];
    
}
/*- (void)viewWillAppear:(BOOL)animated{
    [self setProfileScreen];
}*/

-(void) setProfileScreen{
    User *currentUser = [User currentUser];
    if (!self.user){
        self.user = currentUser;
    }
    //User is viewing themselves
    if ([self.user.objectId isEqualToString: currentUser.objectId]){
        self.settingsButton.hidden = NO;
        self.cancelButton.hidden = YES;
        self.saveSettingsButton.hidden = YES;
        [self.profilePicButton addTarget:self action:@selector(didTapChangeProfilePic:) forControlEvents: UIControlEventTouchUpInside];

    }
    //User is viewing a different user
    else{
        self.settingsButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.saveSettingsButton.hidden = YES;
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
    
    [User postSaveSettings:self.user withProfileImage: self.profilePicButton.currentImage withBiography:@""];
    
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
-(void) didTapChangeProfilePic: (UIButton *) profileButton{
    [self showPhotoAlert];
}
- (void)showPhotoAlert {
    // Add code to be run periodically
     UIImagePickerController *imagePickerVC = [UIImagePickerController new];
     imagePickerVC.delegate = self;
     imagePickerVC.allowsEditing = YES;
     self.photoSelectorAlert = [UIAlertController alertControllerWithTitle:@"Select a photo" message:@""
                                preferredStyle:UIAlertControllerStyleActionSheet];

     
     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
         UIAlertAction *didSelectCamera = [UIAlertAction actionWithTitle:@"Camera"
                                                       style:UIAlertActionStyleDefault
                                           
                                     handler:^(UIAlertAction * _Nonnull action) {
                                            // handle cancel response here. Doing nothing will dismiss the view.
                                         imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
             [self presentViewController:imagePickerVC animated:YES completion:nil];
                                         
                             }];
         [self.photoSelectorAlert addAction:didSelectCamera];
     }
     UIAlertAction *didSelectCameraRoll = [UIAlertAction actionWithTitle:@"Camera Roll"
                                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                        // handle cancel response here. Doing nothing will dismiss the view.
                                     imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                     [self presentViewController:imagePickerVC animated:YES completion:nil];
         
                                 }];
     [self.photoSelectorAlert addAction:didSelectCameraRoll];
  
     [self presentViewController:self.photoSelectorAlert animated:YES completion:^{
         // optional code for what happens after the alert controller has finished presenting
     }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    //UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // Do something with the images (based on your use case)
    [self.profilePicButton setImage:originalImage forState:UIControlStateNormal];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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

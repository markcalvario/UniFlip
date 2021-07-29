//
//  ListingDetailViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/18/21.
//

#import "ListingDetailViewController.h"
#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h>
#import "User.h"
#import "MaterialTextControls+OutlinedTextAreas.h"
#import "MaterialTextControls+OutlinedTextFields.h"
#import "ReportListingViewController.h"
#import "MaterialSnackbar.h"
#import <MaterialComponents/MaterialTabs+TabBarView.h>
#import "MaterialActionSheet.h"
#import "MDCSnackbarManager.h"
#import "MDCSnackbarManagerDelegate.h"
#import "MDCSnackbarMessage.h"
#import "MDCSnackbarMessageView.h"
#import "PhotoCell.h"


@interface ListingDetailViewController ()<MFMailComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *imageOfAuthorButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *listingImageTapGesture;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *photoIndicator;
@property (strong, nonatomic) IBOutlet UIButton *composeMailButton;
@property (strong, nonatomic) IBOutlet UIScrollView *outerScrollView;
@property (strong, nonatomic) UIImageView *imageToZoom;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSArray *photos;

@property (strong, nonatomic) IBOutlet UIView *innerView;


@end

@implementation ListingDetailViewController
CGFloat lastScale;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentUser = [User currentUser];
    self.listingImageTapGesture.numberOfTapsRequired = 2;
    self.photosCollectionView.delegate = self;
    self.photosCollectionView.dataSource = self;
    self.photos = self.listing.photos;
    self.photoIndicator.numberOfPages = self.photos.count;
    [self loadListingScreenDetais];
    [self addAccessibility];
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadListingScreenDetais];
}

-(void) loadListingScreenDetais{
    self.titleLabel.text = self.listing.listingTitle;
    self.categoryLabel.text = self.listing.listingCategory;
    self.descriptionLabel.text = self.listing.listingDescription;
    self.priceLabel.text = [@"$" stringByAppendingString:self.listing.listingPrice];
    PFFileObject *userProfilePicture = self.listing.author.profilePicture;
    if (userProfilePicture){
        [Listing PFFileToUIImage:userProfilePicture completion:^(UIImage * image, NSError * error) {
            if (image){
                [self.imageOfAuthorButton setImage: [ListingDetailViewController imageWithImage:image scaledToWidth:414] forState:UIControlStateNormal];
            }
            else{
                [self.imageOfAuthorButton setImage: [UIImage imageNamed:@"envelope_icon"] forState:UIControlStateNormal];
            }
        }];
    }
    self.imageOfAuthorButton.layer.cornerRadius = self.imageOfAuthorButton.frame.size.width / 2;
    self.imageOfAuthorButton.clipsToBounds = YES;
    [self updateSaveButtonUI:self.listing.isSaved withButton:self.saveButton];
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;

    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
-(void) updateSaveButtonUI:(BOOL )isSaved withButton:(UIButton *)saveButton{
    if (isSaved){
        [saveButton setImage:[UIImage imageNamed:@"saved_icon"] forState:UIControlStateNormal];
        self.saveButton.accessibilityValue = [[@"You have " stringByAppendingString:self.listing.listingTitle] stringByAppendingString:@" as saved. Tap to unsave this listing"];
    }
    else{
        [saveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
        self.saveButton.accessibilityValue = [[@"You do not have " stringByAppendingString:self.listing.listingTitle] stringByAppendingString:@" as saved. Tap to save this listing"];
    }
}

-(void) openComposeMailViewController{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setToRecipients:[NSArray arrayWithObjects: self.listing.authorEmail , nil]];
    if (mc){
        [self presentViewController:mc animated:true completion:nil];
    }
    // be a good memory manager and release mc, as you are responsible for it because your alloc/init
}
#pragma mark - Action Handlers
- (IBAction)didTapComposeMail:(id)sender {
    [self openComposeMailViewController];
}
- (IBAction)didTapSaveIcon:(id)sender {
    if (self.listing.isSaved){
        NSLog(@"was saved but is now not saved");
        [Listing postUnsaveListing:self.listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.listing.isSaved = FALSE;
                [self updateSaveButtonUI:self.listing.isSaved withButton: sender];
            }
        }];
    }
    else{
        NSLog(@"was not saved but now is saved");
        [Listing postSaveListing:self.listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.listing.isSaved = TRUE;
                [self updateSaveButtonUI:self.listing.isSaved withButton: sender];
            }
        }];
    }
    
}
- (IBAction)didTapViewProfileButton:(id)sender {
    if (![self.listing.author.objectId isEqual:self.currentUser.objectId]){
        [User postVisitedProfileToCounter:self.currentUser withListing:self.listing withCompletion:^(BOOL finished) {}];
    }
    [self performSegueWithIdentifier:@"ListingDetailToProfile" sender:self.listing.author];
}
- (IBAction)didTapImageTwice:(id)sender {
    if (self.listing.isSaved){
        NSLog(@"was saved but is now not saved");
        [Listing postUnsaveListing:self.listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.listing.isSaved = FALSE;
                [self updateSaveButtonUI:self.listing.isSaved withButton: self.saveButton];

            }
        }];
    }
    else{
        NSLog(@"was not saved but now is saved");
        [Listing postSaveListing:self.listing withUser:self.currentUser completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.listing.isSaved = TRUE;
                [self updateSaveButtonUI:self.listing.isSaved withButton: self.saveButton];
            }
        }];
    }
}
- (IBAction)didTapMenuButton:(id)sender {
    MDCActionSheetController *actionSheet =
        [MDCActionSheetController actionSheetControllerWithTitle:@""];
    MDCActionSheetAction *deleteAction =
        [MDCActionSheetAction actionWithTitle:@"Delete Listing"
                                        image:[UIImage systemImageNamed:@"trash"]
                                      handler:^(MDCActionSheetAction *action){
            [Listing deleteListing: self.listing completion:^(BOOL isDeleted, NSError *error) {
                if (isDeleted){
                    [self dismissViewControllerAnimated:TRUE completion:nil];
                }
                else{
                    NSLog(@"%@", error);
                }
            }];
        }];
    MDCActionSheetAction *reportAction = [MDCActionSheetAction actionWithTitle:@"Report"
                                        image:[UIImage imageNamed:@"flag_outline"]
                                        handler:^(MDCActionSheetAction *action){
        [self dismissViewControllerAnimated:TRUE completion:^{

            [self hasUserReportedListing:^(BOOL hasReported, NSError *error) {
                if (!hasReported){
                    [self performSegueWithIdentifier:@"ListingDetailToReport" sender:self.listing];
                }
                else{
                    MDCSnackbarMessage *message = [[MDCSnackbarMessage alloc] init];
                    [message setText:@"You have already reported this listing"];
                    message.duration = 1;
                    [MDCSnackbarManager.defaultManager showMessage:message];
                }
            }];
        }];
    }];
    MDCActionSheetAction *emailAction =
        [MDCActionSheetAction actionWithTitle:@"Email"
                                        image:[UIImage imageNamed:@"envelope_icon"]
                                      handler:^(MDCActionSheetAction *action){
                    [self openComposeMailViewController];
        }];
    if ([self.listing.author.username isEqualToString:self.currentUser.username]){
        [deleteAction setTitleColor:[UIColor redColor]];
        [actionSheet addAction:deleteAction];
    }
    deleteAction.isAccessibilityElement = YES;
    reportAction.isAccessibilityElement = YES;
    emailAction.isAccessibilityElement = YES;
    deleteAction.accessibilityValue = [@"Tap to delete " stringByAppendingString:self.listing.listingTitle];
    reportAction.accessibilityValue = [@"Tap to report " stringByAppendingString:self.listing.listingTitle];
    emailAction.accessibilityValue = [@"Tap to send an e-mail to " stringByAppendingString:self.listing.author.username];
    
    [actionSheet addAction:reportAction];
    [actionSheet addAction:emailAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
-(void) hasUserReportedListing:(void(^)(BOOL, NSError *))hasReported{
    PFRelation *relation = [self.listing relationForKey:@"reportedBy"];
    PFQuery *query = [relation query];
    __block BOOL reported = FALSE;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
        if (arrayOfUsers){
            for (User *user in arrayOfUsers){
                if ([user.username isEqualToString: self.currentUser.username]){
                    hasReported(TRUE, nil);
                    reported = TRUE;
                }
            }
            if (!reported){
                hasReported(FALSE, nil);
            }

        }else{
            NSLog(@"Could not load saved listings");
            hasReported(nil, error);
        }
    }];
}


#pragma mark - Collection View
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SlidePhotoCell" forIndexPath:indexPath];
    PFFileObject *listingImageObject = [self.photos objectAtIndex:indexPath.row];
    [Listing PFFileToUIImage:listingImageObject completion:^(UIImage * image, NSError * error) {
        if (image){
            [cell.detailPhoto setImage: [self scaleImageToSize:image withSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)]];
        }
    }];
    cell.detailPhoto.userInteractionEnabled = YES;
    cell.isAccessibilityElement = YES;
    cell.accessibilityValue = @"Tap this image to view the full size";
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PFFileObject *listingImageObject = [self.photos objectAtIndex:indexPath.row];
    [Listing PFFileToUIImage:listingImageObject completion:^(UIImage * image, NSError * error) {
        if (image){
            [self addImageViewWithImage:image];
            
        }
    }];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage *)scaleImageToSize:(UIImage *)image withSize:(CGSize)size {
    CGRect scaledImageRect = CGRectZero;
      
      CGFloat aspectWidth = size.width / image.size.width;
      CGFloat aspectHeight = size.height / image.size.height;
      CGFloat aspectRatio = MAX ( aspectWidth, aspectHeight );
      
      scaledImageRect.size.width = image.size.width * aspectRatio;
      scaledImageRect.size.height = image.size.height * aspectRatio;
      scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0f;
      scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0f;
      
      UIGraphicsBeginImageContextWithOptions( size, NO, 0 );
      [image drawInRect:scaledImageRect];
      UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      return scaledImage;
}

-(void)addImageViewWithImage:(UIImage*)image {
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(0, self.titleLabel.superview.frame.size.height/4, self.titleLabel.superview.frame.size.width, self.titleLabel.superview.frame.size.height/2);
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.backgroundColor = [UIColor blackColor];
    imgView.userInteractionEnabled = YES;
    imgView.image = image;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.tag = 100;
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.contentSize = imgView.frame.size;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.contentSize = CGSizeMake(imgView.frame.size.width , imgView.frame.size.height);
    scrollView.minimumZoomScale=1;
    scrollView.maximumZoomScale=10;
    scrollView.delegate=self;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImage)];
    dismissTap.numberOfTapsRequired = 1;
    scrollView.tag = 101;
    [scrollView addGestureRecognizer:dismissTap];
    self.imageToZoom = imgView;
    scrollView.alpha = 0;
    imgView.alpha = 0;
    
    [self.innerView addSubview:scrollView];
    [scrollView addSubview:imgView];
    if (scrollView.alpha ==0){
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            scrollView.alpha = 1;
            imgView.alpha = 1;
        }completion:nil];
    }
    
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageToZoom;
}
-(void)removeImage {
    UIImageView *imgView = (UIImageView*)[self.view viewWithTag:100];
    UIScrollView *scrollView = (UIScrollView*)[self.view viewWithTag:101];
    
    if (scrollView.alpha == 1){
        [UIView animateWithDuration:0.75 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imgView.alpha = 0;
            scrollView.alpha = 0;
            
        }completion:^(BOOL completed){
            [imgView removeFromSuperview];
            [scrollView removeFromSuperview];
        
        }];
    }
    
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag != 101){
        self.photoIndicator.currentPage = scrollView.contentOffset.x/ scrollView.frame.size.width;
    }
}

- (void) addAccessibility{
    self.photosCollectionView.isAccessibilityElement = YES;
    self.imageOfAuthorButton.isAccessibilityElement = YES;
    self.titleLabel.isAccessibilityElement = YES;
    self.priceLabel.isAccessibilityElement = YES;
    self.categoryLabel.isAccessibilityElement = YES;
    self.descriptionLabel.isAccessibilityElement = YES;
    self.menuButton.isAccessibilityElement = YES;
    self.saveButton.isAccessibilityElement = YES;
    self.composeMailButton.isAccessibilityElement = YES;
    
    self.photosCollectionView.accessibilityValue = @"Swipe left to view more photos of this image if applicable";
    self.imageOfAuthorButton.accessibilityValue = [[@"Tap " stringByAppendingString: self.listing.author.username] stringByAppendingString:@"'s profile picture to see their profile"];
    self.titleLabel.accessibilityValue = [@"You are viewing " stringByAppendingString:self.listing.listingTitle];
    self.priceLabel.accessibilityValue = [[[[@"The price of " stringByAppendingString:self.listing.listingTitle] stringByAppendingString:@" is "] stringByAppendingString:self.listing.listingPrice] stringByAppendingString:@" United States dollars"];
    self.categoryLabel.accessibilityValue = [[[self.listing.listingTitle stringByAppendingString:@" falls under the "] stringByAppendingString: self.listing.listingCategory] stringByAppendingString:@" category"];
    self.descriptionLabel.accessibilityValue = [@"Description reads as " stringByAppendingString:self.listing.listingDescription];
    self.menuButton.accessibilityValue = @"Tap to view more options such as reporting this listing, emailing the author, or deleting the listing if you are the author of this listing";
    self.composeMailButton.accessibilityValue = [@"Tap to send an e-mail to " stringByAppendingString:self.listing.author.username];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ListingDetailToProfile"]){
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = sender;
    }
    else{
        ReportListingViewController *reportViewController = [segue destinationViewController];
        reportViewController.listing = sender;
    }
}

@end

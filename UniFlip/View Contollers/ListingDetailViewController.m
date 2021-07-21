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
#import "MaterialActionSheet.h"
#import "MaterialTextControls+OutlinedTextAreas.h"
#import "MaterialTextControls+OutlinedTextFields.h"
#import "ReportListingViewController.h"


@interface ListingDetailViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *listingImage;
@property (weak, nonatomic) IBOutlet UIButton *imageOfAuthorButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *listingImageTapGesture;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;



@end

@implementation ListingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listingImageTapGesture.numberOfTapsRequired = 2;
    self.listingImage.userInteractionEnabled = YES;

    self.currentUser = [User currentUser];
    [self loadListingScreenDetais];
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
    PFFileObject *listingImageObject = self.listing.listingImage;
    [Listing PFFileToUIImage:listingImageObject completion:^(UIImage * image, NSError * error) {
        if (image){
            [self.listingImage setImage: [ListingDetailViewController imageWithImage:image scaledToWidth:414] ];
        }
    }];
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
    }
    else{
        [saveButton setImage:[UIImage imageNamed:@"unsaved_icon"] forState:UIControlStateNormal];
    }
}

-(void) openComposeMailViewController{
    // get a new new MailComposeViewController object
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];

    // his class should be the delegate of the mc
    mc.mailComposeDelegate = self;

    // set some recipients ... but you do not need to do this :)
    [mc setToRecipients:[NSArray arrayWithObjects: self.listing.authorEmail , nil]];

    // displaying our modal view controller on the screen with standard transition
    [self presentViewController:mc animated:true completion:nil];
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
    [self performSegueWithIdentifier:@"ListingDetailToProfile" sender:self.listing.author];
}
- (IBAction)didTapImageTwice:(id)sender {
    NSLog(@"tapped twice");
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
    MDCActionSheetAction *homeAction = [MDCActionSheetAction actionWithTitle:@"Report"
                                        image:[UIImage imageNamed:@"flag_outline"]
                                        handler:^(MDCActionSheetAction *action){
        [self dismissViewControllerAnimated:TRUE completion:^{
            //ReportListingViewController * reportViewController = [[ReportListingViewController alloc] init];
            //[self presentViewController:reportViewController animated:TRUE completion:nil];
            [self performSegueWithIdentifier:@"ListingDetailToReport" sender:self.listing];
        }];
        
    }];
    MDCActionSheetAction *favoriteAction =
        [MDCActionSheetAction actionWithTitle:@"Email"
                                        image:[UIImage imageNamed:@"envelope_icon"]
                                      handler:^(MDCActionSheetAction *action){
                    [self openComposeMailViewController];
        }];
    [actionSheet addAction:homeAction];
    [actionSheet addAction:favoriteAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}









#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
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

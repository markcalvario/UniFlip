//
//  ListingDetailViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/18/21.
//

#import "ListingDetailViewController.h"
#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h>

@interface ListingDetailViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *listingImage;
@property (weak, nonatomic) IBOutlet UIButton *imageOfAuthorButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation ListingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadListingScreenDetais];
}

-(void) loadListingScreenDetais{
    self.titleLabel.text = self.listing.listingTitle;
    self.categoryLabel.text = self.listing.listingCategory;
    self.descriptionLabel.text = self.listing.listingDescription;
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

#pragma mark - Action Handlers
- (IBAction)didTapComposeMail:(id)sender {
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
- (IBAction)didTapSaveIcon:(id)sender {
    if (self.listing.isSaved){
        NSLog(@"was saved but is now not saved");
        [Listing postUnsaveListing:self.listing withUser:self.listing.author completion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.listing.isSaved = FALSE;
                [self updateSaveButtonUI:self.listing.isSaved withButton: sender];

            }
        }];
    }
    else{
        NSLog(@"was not saved but now is saved");
        [Listing postSaveListing:self.listing withUser:self.listing.author completion:^(BOOL succeeded, NSError * _Nullable error) {
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










#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ListingDetailToProfile"]){
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = sender;
    }
}


@end

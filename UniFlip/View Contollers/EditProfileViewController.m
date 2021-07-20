//
//  EditProfileViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/19/21.
//

#import "EditProfileViewController.h"
#import "MaterialTextControls+OutlinedTextAreas.h"
#import "MaterialTextControls+OutlinedTextFields.h"
#import "User.h"
#import "Listing.h"
#import <QuartzCore/QuartzCore.h>

@import UITextView_Placeholder;

@interface EditProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong,nonatomic) User *user;
@property (strong, nonatomic) IBOutlet UIButton *profilePicButton;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) UIAlertController *photoSelectorAlert;
@property (strong, nonatomic) IBOutlet UIImageView *addPhotoIcon;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [User currentUser];
    PFFileObject *userProfilePicture = self.user.profilePicture;
    if (userProfilePicture){
        [Listing PFFileToUIImage:userProfilePicture completion:^(UIImage * image, NSError * error) {
            if (image){
                [self.profilePicButton setImage: image forState:UIControlStateNormal];
            }
            else{
                [self.profilePicButton setImage: [UIImage imageNamed:@"default_profile_pic"] forState:UIControlStateNormal];
            }
        }];
    }
    NSString *userBio = self.user.biography;
    if (userBio.length == 0){
        self.bioTextView.placeholder = @"Write a bio here";
    }
    else{
        self.bioTextView.text = userBio;
    }
    
    CALayer *imageLayer = self.profilePicButton.imageView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:2];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    [self.profilePicButton.imageView.layer setCornerRadius:self.profilePicButton.imageView.frame.size.width/2];
    [self.profilePicButton.imageView.layer setMasksToBounds:YES];
    
    imageLayer = self.addPhotoIcon.maskView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:2];
    [imageLayer setMasksToBounds:YES];
    [self.addPhotoIcon.maskView.layer setCornerRadius:self.addPhotoIcon.maskView.frame.size.width/2];
    [self.addPhotoIcon.maskView.layer setMasksToBounds:YES];
}
- (IBAction)didTapSaveSetttings:(id)sender {
    [User postSaveSettings:self.user withProfileImage:self.profilePicButton.currentImage withBiography:self.bioTextView.text];
    [self.navigationController popViewControllerAnimated:TRUE];
}
- (IBAction)didTapProfilePicButton:(id)sender {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

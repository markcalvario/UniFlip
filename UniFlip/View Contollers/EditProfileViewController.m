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
#import "MaterialActionSheet.h"


@import UITextView_Placeholder;

@interface EditProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *profilePicButton;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) IBOutlet UIImageView *addPhotoIcon;
@property (strong, nonatomic) IBOutlet UIButton *saveChangesButton;
@property (strong,nonatomic) User *user;
@property (strong, nonatomic) UIAlertController *photoSelectorAlert;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayEditProfile];
    [self addAccessiblity];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self displayEditProfile];
}
-(void) displayEditProfile{
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
     UIImagePickerController *imagePickerVC = [UIImagePickerController new];
     imagePickerVC.delegate = self;
     imagePickerVC.allowsEditing = YES;
    MDCActionSheetController *actionSheet =
        [MDCActionSheetController actionSheetControllerWithTitle:@""];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        MDCActionSheetAction *selectCameraAction = [MDCActionSheetAction actionWithTitle:@"Camera"
                                            image:[UIImage systemImageNamed:@"camera"]
                                            handler:^(MDCActionSheetAction *action){
            [self dismissViewControllerAnimated:TRUE completion:^{
                imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerVC animated:YES completion:nil];
            }];
        }];
        [actionSheet addAction:selectCameraAction];
    }
    MDCActionSheetAction *selectPhotoGalleryAction =
        [MDCActionSheetAction actionWithTitle:@"Phone Gallery"
                                        image:[UIImage systemImageNamed:@"square.grid.3x3"]
                                      handler:^(MDCActionSheetAction *action){
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
        }];

    [actionSheet addAction:selectPhotoGalleryAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [self.profilePicButton setImage:originalImage forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) addAccessiblity{
    self.profilePicButton.isAccessibilityElement = YES;
    self.addPhotoIcon.isAccessibilityElement = YES;
    self.bioTextView.isAccessibilityElement = YES;
    self.saveChangesButton.isAccessibilityElement = YES;
    
    self.profilePicButton.accessibilityValue = @"Tap to change your profile picture";
    self.bioTextView.accessibilityValue = @"Enter your editied profile bio";
    self.saveChangesButton.accessibilityValue = @"Tap to save any changes to your profile";
    self.addPhotoIcon.accessibilityValue = @"Icon indicating to add a photo";
}

@end

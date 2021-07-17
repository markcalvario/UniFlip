//
//  SellViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import "SellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectOptionViewController.h"
#import "PlaceAutocompleteViewController.h"
#import "Listing.h"
@import UITextView_Placeholder;

@interface SellViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, SelectOptionViewControllerDelege, PlaceAutocompleteDelege>
@property (strong, nonatomic) UIAlertController *alert;
@property (strong, nonatomic) UIImage *imagePlaceHolder;
@property (weak, nonatomic) IBOutlet UIButton *imageOfProductButton;
@property (weak, nonatomic) IBOutlet UITextField *listingTitleField;
@property (weak, nonatomic) IBOutlet UITextView *listingDescriptionView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITextField *conditionField;
@property (weak, nonatomic) IBOutlet UITextField *brandField;
@property (weak, nonatomic) IBOutlet UIButton *postListingButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UITextField *listingTypeField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;


@end

@implementation SellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSellViewControllerStyling];
    self.imagePlaceHolder = [self.imageOfProductButton currentImage];
    self.listingDescriptionView.placeholder = @"Description of your listing";


    
}
- (void) setSellViewControllerStyling{
    [[self.listingDescriptionView layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.listingDescriptionView layer] setBorderWidth:1];
    [[self.listingDescriptionView layer] setCornerRadius:10];
    
    //Location Button styling
    [[self.locationButton layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.locationButton layer] setBorderWidth:1];
    [[self.locationButton layer] setCornerRadius:5];
    
    [[self.categoryButton layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.categoryButton layer] setBorderWidth:1];
    [[self.categoryButton layer] setCornerRadius:5];
    
    CGFloat widthOfButton = self.postListingButton.layer.frame.size.height/ 2;
    [[self.postListingButton layer] setCornerRadius: widthOfButton];
    [self.postListingButton setClipsToBounds:TRUE];
}


/// Photo Selection Alert
- (void)showPhotoAlert {
    // Add code to be run periodically
     UIImagePickerController *imagePickerVC = [UIImagePickerController new];
     imagePickerVC.delegate = self;
     imagePickerVC.allowsEditing = YES;

     self.alert = [UIAlertController alertControllerWithTitle:@"Select a photo" message:@""
                                preferredStyle:UIAlertControllerStyleActionSheet];

     
     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
         UIAlertAction *didSelectCamera = [UIAlertAction actionWithTitle:@"Camera"
                                                       style:UIAlertActionStyleDefault
                                           
                                     handler:^(UIAlertAction * _Nonnull action) {
                                            // handle cancel response here. Doing nothing will dismiss the view.
                                         imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
             [self presentViewController:imagePickerVC animated:YES completion:nil];
                                         
                             }];
         [self.alert addAction:didSelectCamera];
     }
     
     
     UIAlertAction *didSelectCameraRoll = [UIAlertAction actionWithTitle:@"Camera Roll"
                                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                        // handle cancel response here. Doing nothing will dismiss the view.
                                     imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                     [self presentViewController:imagePickerVC animated:YES completion:nil];
         
                                 }];
     [self.alert addAction:didSelectCameraRoll];
  
     [self presentViewController:self.alert animated:YES completion:^{
         // optional code for what happens after the alert controller has finished presenting
     }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    //UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // Do something with the images (based on your use case)
    [self.imageOfProductButton setImage:originalImage forState:UIControlStateNormal];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}



///Getting the option selected
- (void)addOptionSelectedToViewController:(NSString*)option{
    //do whatever you want with the data
    [self.categoryButton setTitle:option forState:UIControlStateNormal];
    [self.categoryButton setTitleColor:[UIColor colorWithRed:0 green:0.58984375 blue:0.8984375 alpha:1] forState:UIControlStateNormal];
}
- (void)addPlaceSelectedToViewController:(NSString*)location{
    //do whatever you want with the data
    NSLog(@"%@", location);
    [self.locationButton setTitle: location forState:UIControlStateNormal];
    [self.locationButton setTitleColor:[UIColor colorWithRed:0 green:0.58984375 blue:0.8984375 alpha:1] forState:UIControlStateNormal];
}

#pragma mark - Actions performed on touch
- (IBAction)didTapSelectPhotos:(id)sender {
    [self showPhotoAlert];
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}
- (IBAction)didTapPostListing:(id)sender {
    UIImage *image = self.imageOfProductButton.currentImage;
    NSString *title = self.listingTitleField.text;
    NSString *type = self.listingTypeField.text;
    NSString *description = self.listingDescriptionView.text;
    NSString *location = self.locationButton.currentTitle;
    NSString *category = self.categoryButton.currentTitle;
    NSString *brand = self.brandField.text;
    NSString *condition = self.conditionField.text;
    NSString *price = self.priceField.text;
    
    [Listing postUserListing:image withTitle:title withType:type withDescription:description withLocation:location withCategory:category withBrand:brand withCondition:condition withPrice:price withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error == nil){
            NSLog(@"Listing is posted");
            [self resetInputFields];
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        }
        else{
            NSLog(@"Error with posting");
        }
    }];
    
}


-(void) resetInputFields{
    [self.imageOfProductButton setImage:self.imagePlaceHolder forState:UIControlStateNormal];
    self.listingTitleField.text = @"";
    self.listingTypeField.text = @"";
    self.listingDescriptionView.text = @"Description of listing";
    [self.locationButton setTitle:@"Location" forState:UIControlStateNormal];
    [self.categoryButton setTitle:@"Category" forState:UIControlStateNormal];
    self.brandField.text = @"";
    self.conditionField.text = @"";
    self.priceField.text = @"";
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ( [[segue identifier] isEqualToString: @"CategoryToSelectOption"]){
        NSArray *arrayOfCategories = @[@"Appliances", @"Apps & Games", @"Arts, Crafts, & Sewing",
            @"Automotive Parts & Accessories", @"Baby", @"Beauty & Personal Care", @"Books", @"CDs & Vinyl",
            @"Cell Phones & Accessories", @"Clothing, Shoes and Jewelry", @"Collectibles & Fine Art", @"Computers", @"Electronics",
            @"Garden & Outdoor", @"Grocery & Gourmet Food", @"Handmade", @"Health, Household & Baby Care", @"Home & Kitchen", @"Industrial & Scientific",
           @"Luggage & Travel Gear", @"Movies & TV", @"Musical Instruments", @"Office Products", @"Pet Supplies", @"Sports & Outdoors",
            @"Tools & Home Improvement", @"Toys & Games", @"Video Games"];
        SelectOptionViewController *selectOptionViewController = [segue destinationViewController];
        selectOptionViewController.data = arrayOfCategories;
        selectOptionViewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString: @"LocationToSelectOption"]){
        PlaceAutocompleteViewController *placeAutocompleteViewController = [segue destinationViewController];
        placeAutocompleteViewController.delegate = self;
    }
}
@end

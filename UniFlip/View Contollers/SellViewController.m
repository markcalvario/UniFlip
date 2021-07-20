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
#import "MaterialSnackbar.h"

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

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *listingTitle;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *listingDescription;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSString *price;



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
    self.image = self.imageOfProductButton.currentImage;
    self.listingTitle = [self.listingTitleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.type = [self.listingTypeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.listingDescription = [self.listingDescriptionView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.location = [self.locationButton.currentTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.category = [self.categoryButton.currentTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.brand = [self.brandField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.condition = [self.conditionField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.price = [self.priceField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [self areFieldsValid:^(BOOL isValid, NSString *errorMessage){
        if (isValid){
            [Listing postUserListing:self.image withTitle:self.listingTitle withType:self.type withDescription:self.listingDescription withLocation:self.location withCategory:self.category withBrand:self.brand withCondition:self.condition withPrice:self.price withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
        else{
            NSLog(@"%@", errorMessage);
            MDCSnackbarMessage *message = [[MDCSnackbarMessage alloc] init];
            //MDCSnackbarMessageView *messageView = [[MDCSnackbarMessageView alloc] init];
            [message setText:errorMessage];
            message.duration = 1;
            [MDCSnackbarManager.defaultManager showMessage:message];
       
           

            
        }
    }];
    
}

-(void) areFieldsValid:(void(^)(BOOL, NSString *)) completion{
    if ([self.imagePlaceHolder isEqual: self.image]){
        completion(FALSE, @"Missing at least 1 image");
    }
    else if (self.listingTitle.length == 0 || self.listingTitle == nil){
        completion(FALSE, @"Missing a title for your listing");
    }
    else if (self.type.length==0 || self.listingTitle == nil){
        completion(FALSE, @"Missing a type of listing");
    }
    else if (self.listingDescription.length == 0 || self.listingTitle == nil){
        completion(FALSE, @"Missing a description for your listing");
    }
    else if(self.location.length == 0 || self.listingTitle == nil){
        completion(FALSE, @"Missing a location of your listing");
    }
    else if(self.category.length == 0 || self.listingTitle == nil){
        completion(FALSE, @"Missing a category for your listing");
    }
    else if(self.price.length == 0 || self.listingTitle == nil || [self.price isEqualToString:@"0"]){
        completion(FALSE, @"Missing a price for your listing");
    }
    else{
        completion(TRUE, nil);

    }
    
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

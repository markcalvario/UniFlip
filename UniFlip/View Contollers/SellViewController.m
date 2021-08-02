//
//  SellViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import "SellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectOptionViewController.h"
#import "Listing.h"
#import "MaterialSnackbar.h"
#import "PhotoCell.h"
#import "MaterialActionSheet.h"

@import UITextView_Placeholder;

@interface SellViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, SelectOptionViewControllerDelege, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *listingTitleField;
@property (weak, nonatomic) IBOutlet UITextView *listingDescriptionView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITextField *conditionField;
@property (weak, nonatomic) IBOutlet UITextField *brandField;
@property (weak, nonatomic) IBOutlet UIButton *postListingButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UITextField *listingTypeField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *exitKeyboardGesture;
@property (strong, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (strong, nonatomic) NSArray *photosToUpload;
@property (strong, nonatomic) NSString *listingTitle;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *listingDescription;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) PFGeoPoint *locationCoordinates;

@property (strong, nonatomic) NSMutableArray<UIImage *> *photos;
@property (nonatomic) NSInteger indexOfPhoto;
@property (strong, nonatomic) UIAlertController *alert;
@property (strong, nonatomic) UIImage *imagePlaceHolder;

@end

@implementation SellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photosCollectionView.delegate = self;
    self.photosCollectionView.dataSource = self;
    [self setSellViewControllerStyling];
    self.photos = [NSMutableArray array];
    self.listingDescriptionView.placeholder = @"Description of your listing";
    [self.exitKeyboardGesture setCancelsTouchesInView:NO];
    [self addAccessibility];

}
- (void) setSellViewControllerStyling{
    [[self.listingDescriptionView layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.listingDescriptionView layer] setBorderWidth:1];
    [[self.listingDescriptionView layer] setCornerRadius:10];
    
    [[self.locationButton layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.locationButton layer] setBorderWidth:1];
    [[self.locationButton layer] setCornerRadius:5];
    
    [[self.categoryButton layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.categoryButton layer] setBorderWidth:1];
    [[self.categoryButton layer] setCornerRadius:5];
    
}



- (void)showPhotoAlert {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    MDCActionSheetController *actionSheet =
        [MDCActionSheetController actionSheetControllerWithTitle:@""];
    MDCActionSheetAction *deleteAction = [MDCActionSheetAction actionWithTitle:@"Delete"
                                        image:[UIImage systemImageNamed:@"trash"]
                                      handler:^(MDCActionSheetAction *action){
        [self.photos removeObjectAtIndex:self.indexOfPhoto];
        [self.photosCollectionView reloadData];
        self.indexOfPhoto -= 1;
        
    }];
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
    if (self.indexOfPhoto < self.photos.count){
        [actionSheet addAction:deleteAction];
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [self.photos insertObject:originalImage atIndex:self.indexOfPhoto];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.photosCollectionView reloadData];
}

- (void)addOptionSelectedToViewController:(NSString*)location withInputType:(NSString *)inputType withCoordinates:(PFGeoPoint * _Nullable)coordinates{
    if ([inputType isEqualToString:@"Location"]){
        self.locationCoordinates = coordinates;
        [self.locationButton setTitle: location forState:UIControlStateNormal];
        [self.locationButton setTitleColor:[UIColor colorWithRed:0 green:0.58984375 blue:0.8984375 alpha:1] forState:UIControlStateNormal];
    }
    else{
        [self.categoryButton setTitle:location forState:UIControlStateNormal];
        [self.categoryButton setTitleColor:[UIColor colorWithRed:0 green:0.58984375 blue:0.8984375 alpha:1] forState:UIControlStateNormal];
    }
    
}

#pragma mark - Actions performed on touch
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}
- (IBAction)didTapPostListing:(id)sender {
    self.photosToUpload = [NSArray arrayWithArray:self.photos];
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
            [Listing postUserListing:self.photosToUpload withTitle:self.listingTitle withType:self.type withDescription:self.listingDescription withLocation:self.location withCategory:self.category withBrand:self.brand withCondition:self.condition withPrice:self.price withCoordinates:self.locationCoordinates withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
            [message setText:errorMessage];
            message.duration = 1;
            [MDCSnackbarManager.defaultManager showMessage:message];
        }
    }];
}

-(void) areFieldsValid:(void(^)(BOOL, NSString *)) completion{
    if (self.photosToUpload.count < 1){
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
#pragma mark - Collection View
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    NSInteger lengthOfPhotosArray = self.photos.count;
    cell.listingPhoto.isAccessibilityElement = YES;
    if (lengthOfPhotosArray == 0 || (!cell.listingPhoto.image) || (indexPath.row >= lengthOfPhotosArray)){
        [cell.listingPhoto setImage:[UIImage imageNamed:@"photo_add_icon"]];
        cell.listingPhoto.accessibilityValue = @"Upload a new photo button";
    }
    else{
        UIImage *photoSelected = [self.photos objectAtIndex:indexPath.row];
        [cell.listingPhoto setImage:photoSelected];
        cell.listingPhoto.accessibilityValue = @"Delete or replace your uploaded photo";

    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count+1;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.indexOfPhoto = indexPath.row;
    [self showPhotoAlert];
}

-(void) resetInputFields{
    self.imagePlaceHolder = [UIImage imageNamed:@"photo_add_icon"];
    self.listingTitleField.text = @"";
    self.listingTypeField.text = @"";
    self.listingDescriptionView.placeholder = @"Description of listing";
    [self.locationButton setTitle:@"Location" forState:UIControlStateNormal];
    [self.categoryButton setTitle:@"Category" forState:UIControlStateNormal];
    self.brandField.text = @"";
    self.conditionField.text = @"";
    self.priceField.text = @"";
}


-(void) addAccessibility{
    self.listingTitleField.isAccessibilityElement = YES;
    self.listingTypeField.isAccessibilityElement = YES;
    self.listingDescriptionView.isAccessibilityElement = YES;
    self.locationButton.isAccessibilityElement = YES;
    self.categoryButton.isAccessibilityElement = YES;
    self.brandField.isAccessibilityElement = YES;
    self.conditionField.isAccessibilityElement = YES;
    self.priceField.isAccessibilityElement = YES;
    self.postListingButton.isAccessibilityElement = YES;
    self.photosCollectionView.isAccessibilityElement = YES;
    
    self.listingTitleField.accessibilityValue = @"Enter the name of your listing you want to post";
    self.listingTypeField.accessibilityValue = @"Enter whether your listing is a product or service";
    self.listingDescriptionView.accessibilityValue = @"Enter a description of your listing";
    self.locationButton.accessibilityValue = @"Tap to enter a location of where your listing is at";
    self.categoryButton.accessibilityValue = @"Tap to enter the category your listing falls under";
    self.brandField.accessibilityValue = @"Enter a brand of your listing, if applicable";
    self.conditionField.accessibilityValue = @"Enter the condition of your listing, if applicable";
    self.priceField.accessibilityValue = @"Enter the price amount of your listing in United States dollar currency";
    self.postListingButton.accessibilityValue = @"Tap to submit your listing";
    self.photosCollectionView.accessibilityValue = @"Select photos of your listing, minimum of 1 photo";
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [[segue identifier] isEqualToString: @"CategoryToSelectOption"]){
        NSArray *arrayOfCategories = @[@"Appliances", @"Apps & Games", @"Arts, Crafts, & Sewing",
            @"Automotive Parts & Accessories", @"Baby", @"Beauty & Personal Care", @"Books", @"CDs & Vinyl",
            @"Cell Phones & Accessories", @"Clothing, Shoes and Jewelry", @"Collectibles & Fine Art", @"Computers", @"Electronics",
            @"Garden & Outdoor", @"Grocery & Gourmet Food", @"Handmade", @"Health, Household & Baby Care", @"Home & Kitchen", @"Industrial & Scientific",
           @"Luggage & Travel Gear", @"Movies & TV", @"Musical Instruments", @"Office Products", @"Pet Supplies", @"Sports & Outdoors",
            @"Tools & Home Improvement", @"Toys & Games", @"Video Games"];
        SelectOptionViewController *selectOptionViewController = [segue destinationViewController];
        selectOptionViewController.delegate = self;
        selectOptionViewController.data = arrayOfCategories;
    }
    else if ([[segue identifier] isEqualToString: @"LocationToSelectOption"]){
        SelectOptionViewController *selectOptionViewController = [segue destinationViewController];
        selectOptionViewController.delegate = self;
        selectOptionViewController.data = [NSArray array];
    }
}


@end

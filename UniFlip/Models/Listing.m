//
//  Listing.m
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import "Listing.h"

@implementation Listing

@dynamic postID;
@dynamic author;
@dynamic listingImage;
@dynamic listingTitle;
@dynamic typeOfListing;
@dynamic listingDescription;
@dynamic listingLocation;
@dynamic listingCategory;
@dynamic listingBrand;
@dynamic listingCondition;
@dynamic listingPrice;
@dynamic isReported;
@dynamic saveCount;
@dynamic isSaved;


+ (nonnull NSString *)parseClassName {
    return @"Listing";
}

+ (void) postUserListing:(UIImage * _Nullable)image withTitle:(NSString * _Nullable)title withType:(NSString * _Nullable)type withDescription:(NSString * _Nullable)description withLocation:(NSString * _Nullable)location withCategory:(NSString * _Nullable)category withBrand:(NSString * _Nullable)brand withCondition:(NSString * _Nullable)condition withPrice:(NSString * _Nullable)price withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Listing *newListing = [Listing new];
    newListing.author = [PFUser currentUser];
    newListing.listingImage = [self getPFFileFromImage: [newListing resizeImage: image withSize: CGSizeMake(300, 300)]];
    newListing.listingTitle = title;
    newListing.typeOfListing = type;
    newListing.listingDescription = description;
    newListing.listingLocation = location;
    newListing.listingCategory = category;
    newListing.listingBrand = brand;
    newListing.listingCondition = condition;
    newListing.listingPrice = price;
    newListing.isReported = FALSE;
    newListing.saveCount = @(0);
    newListing.isSaved = FALSE;
    [newListing saveInBackgroundWithBlock:completion];
    
    
}
+ (void) postSaveListing: (Listing *)listing withUser: (PFUser *)user completion:(void(^)(BOOL , NSError *))completion{
    PFRelation *relation = [listing relationForKey:@"savedBy"];
    [relation addObject:user];
    [listing incrementKey:@"saveCount" byAmount:@(1)];
    [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            completion(TRUE, nil);
        }
        else{
            completion(FALSE, error);
        }
    }];
}
+ (void) postUnsaveListing: (Listing *)listing withUser: (PFUser *)user completion:(void(^)(BOOL , NSError *))completion{
    PFRelation *relation = [listing relationForKey:@"savedBy"];
    [relation removeObject:user];
    [listing incrementKey:@"saveCount" byAmount:@(-1)];
    [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            completion(TRUE, nil);
        }
        else{
            completion(FALSE, error);
        }
    }];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.jpeg" data:imageData];
}

+ (void) PFFileToUIImage: (PFFileObject *)imageFile completion:(void(^)(UIImage *, NSError *))completion{
    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            completion(image, nil);
        }
        else{
            completion(nil, error);
        }
    }];
    
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

@end

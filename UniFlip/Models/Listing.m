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
@dynamic listingImages;
@dynamic photos;
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
@dynamic authorEmail;
@dynamic locationCoordinates;


+ (nonnull NSString *)parseClassName {
    return @"Listing";
}

+ (void) postUserListing:(NSArray<UIImage *>*)images withTitle:(NSString * _Nullable)title withType:(NSString * _Nullable)type withDescription:(NSString * _Nullable)description withLocation:(NSString * _Nullable)location withCategory:(NSString * _Nullable)category withBrand:(NSString * _Nullable)brand withCondition:(NSString * _Nullable)condition withPrice:(NSString * _Nullable)price withCoordinates:(PFGeoPoint *)coordinates withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Listing *newListing = [Listing new];
    newListing.author = [User currentUser];
    NSMutableArray *mutableImages = [NSMutableArray array];
    for (UIImage *image in images){
        [mutableImages addObject:[self getPFFileFromImage: [newListing resizeImage: image withSize: CGSizeMake(450, 450)]]];
    }
    newListing.photos = [NSArray arrayWithArray:mutableImages];
    newListing.listingTitle = title;
    newListing.typeOfListing = type;
    newListing.listingDescription = description;
    newListing.listingLocation = location;
    newListing.locationCoordinates = coordinates;
    newListing.listingCategory = category;
    newListing.listingBrand = brand;
    newListing.listingCondition = condition;
    newListing.listingPrice = price;
    newListing.isReported = FALSE;
    newListing.saveCount = @(0);
    newListing.isSaved = FALSE;
    newListing.authorEmail = newListing.author.email;
    [newListing saveInBackgroundWithBlock:completion];
}
+ (void) postSaveListing: (Listing *)listing withUser: (PFUser *)user completion:(void(^)(BOOL , NSError *))completion{
    PFRelation *relation = [listing relationForKey:@"savedBy"];
    [relation addObject:user];
    [listing incrementKey:@"saveCount" byAmount:@(1)];
    listing.isSaved = TRUE;
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
    listing.isSaved = FALSE;
    [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            completion(TRUE, nil);
        }
        else{
            completion(FALSE, error);
        }
    }];
}

+ (void) deleteListing:(Listing *)listing completion:(void(^)(BOOL , NSError *))completion{
    [listing deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                completion(TRUE, nil);
            }
            else{
                completion(FALSE, nil);
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

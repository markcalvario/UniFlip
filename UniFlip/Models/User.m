//
//  User.m
//  UniFlip
//
//  Created by mac2492 on 7/15/21.
//

#import "User.h"
#import "Listing.h"

@implementation User
@dynamic username;
@dynamic email;
@dynamic schoolEmail;
@dynamic university;
@dynamic biography;
@dynamic isReported;
@dynamic profilePicture;

+ (void) postSaveSettings:(User *)user withProfileImage:(UIImage *)image withBiography:(NSString *)biography{
    user.biography = biography;
    user.profilePicture = [Listing getPFFileFromImage: [user resizeImage:image withSize: CGSizeMake(300, 300)]];
    
    [user saveInBackground];
}

+ (void) postVisitedProfileToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion{
    NSMutableDictionary *visitedProfileToCounter = user[@"visitedProfileToCounter"];
    if (!visitedProfileToCounter){
        visitedProfileToCounter = [NSMutableDictionary dictionary];
    }
    if ([visitedProfileToCounter objectForKey: listing.author.objectId]){
        NSNumber *clicks = [visitedProfileToCounter valueForKey: listing.author.objectId];
        int value = [clicks intValue];
        clicks = [NSNumber numberWithInt:value + 1];
        [visitedProfileToCounter setValue:clicks forKey: listing.author.objectId];
    }
    else{
        [visitedProfileToCounter setValue:@(1) forKey: listing.author.objectId];
    }
    
    user[@"visitedProfileToCounter"] = visitedProfileToCounter;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        succeeded ? completion(TRUE) : completion(FALSE);
    }];
}
+ (void) postVisitedListingToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion{
    NSMutableDictionary *listingsToClicks = user[@"visitedListingsToCounter"];
    if (!listingsToClicks){
        listingsToClicks = [NSMutableDictionary dictionary];
    }
    if ([listingsToClicks objectForKey:listing.objectId]){
        NSNumber *clicks = [listingsToClicks valueForKey:listing.objectId];
        int value = [clicks intValue];
        clicks = [NSNumber numberWithInt:value + 1];
        [listingsToClicks setValue:clicks forKey:listing.objectId];
    }
    else{
        
        [listingsToClicks setValue:@(1) forKey:listing.objectId];
    }
    user[@"visitedListingsToCounter"] = listingsToClicks;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        succeeded ? completion(TRUE) : completion(FALSE);
    }];
}
+ (void) postVisitedCategoryToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion{
    NSMutableDictionary *categoriesVisitedToClick = user[@"visitedCategoryToCounter"];
    if (!categoriesVisitedToClick){
        categoriesVisitedToClick = [NSMutableDictionary dictionary];
    }
    if ([categoriesVisitedToClick objectForKey:listing.listingCategory]){
        //increment
        NSNumber *clicks = [categoriesVisitedToClick valueForKey:listing.listingCategory];
        int value = [clicks intValue];
        clicks = [NSNumber numberWithInt:value + 1];
        [categoriesVisitedToClick setValue:clicks forKey:listing.listingCategory];
    }
    else{
        [categoriesVisitedToClick setValue:@(1) forKey:listing.listingCategory];
    }
    user[@"visitedCategoryToCounter"] = categoriesVisitedToClick;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        succeeded ? completion(TRUE) : completion(FALSE);
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

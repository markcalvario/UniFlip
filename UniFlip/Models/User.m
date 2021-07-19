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
@dynamic university;
@dynamic biography;
@dynamic isReported;
@dynamic profilePicture;

+ (void) postSaveSettings:(User *)user withProfileImage:(UIImage *)image withBiography:(NSString *)biography{
    user.biography = biography;
    user.profilePicture = [Listing getPFFileFromImage: [user resizeImage:image withSize: CGSizeMake(300, 300)]];
    
    [user saveInBackground];
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

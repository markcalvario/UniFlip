//
//  User.h
//  UniFlip
//
//  Created by mac2492 on 7/15/21.
//

#import <Parse/Parse.h>
#import "Listing.h"

NS_ASSUME_NONNULL_BEGIN
@class Listing;
@interface User : PFUser

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *schoolEmail;
@property (nonatomic, strong) NSString *university;
@property (nonatomic, strong) NSString *biography;
@property (nonatomic) BOOL isReported;
@property (nonatomic, strong) PFFileObject *profilePicture;

+ (void) postSaveSettings:(User *)user withProfileImage:(UIImage *)image withBiography:(NSString *)biography;
+ (void) postVisitedProfileToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion;
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END

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
@property (nonatomic, strong) NSArray *followers;
@property (nonatomic, strong) NSArray *following;
@property (nonatomic, strong) NSNumber *followerCount;
@property (nonatomic, strong) NSNumber *followingCount;


+ (void) postUser:(NSString *)username withEmail:(NSString *)schoolEmail withPassword:(NSString *)password withSchoolName:(NSString *)schoolName withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) postSaveSettings:(User *)user withProfileImage:(UIImage *)image withBiography:(NSString *)biography;
+ (void) postVisitedProfileToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion;
+ (void) postVisitedListingToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion;
+ (void) postVisitedCategoryToCounter:(User *)user withListing:(Listing *)listing withCompletion:(void(^)(BOOL finished))completion;
+ (void) getAllUsersOfUniversity:(NSString *)university withCompletion:(void(^)(NSArray *))completion;
+ (void) postFollowingUser: (User *) userToFollow withFollowedBy: (User *) followedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion;
+ (void) postUnfollowingUser: (User *)userToUnfollow withUnfollowedBy: (User *) unFollowedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion;
+ (void) postFollowedUser: (User *) userToFollow withFollowedBy: (User *) followedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion;
+ (void) postUnfollowedUser: (User *)userToUnfollow withUnfollowedBy: (User *) unfollowedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion;
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END

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
@dynamic followers;
@dynamic following;
@dynamic followerCount;
@dynamic followingCount;


+ (void) postUser:(NSString *)username withEmail:(NSString *)schoolEmail withPassword:(NSString *)password withSchoolName:(NSString *)schoolName withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    User *newUser = [User user];
    newUser.email = schoolEmail;
    newUser.username = username;
    newUser.password = password;
    newUser.biography = @"";
    newUser.university = schoolName;
    newUser.schoolEmail = schoolEmail;
    newUser.followers = [NSArray array];
    newUser.following = [NSArray array];
    [newUser.ACL setPublicWriteAccess:TRUE];
    [newUser signUpInBackgroundWithBlock: completion];
}

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
+ (void) getAllUsersOfUniversity:(NSString *)university withCompletion:(void(^)(NSArray *))completion{
    PFQuery *query = [User query];
    [query whereKey:@"university" equalTo:university];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (users){
            completion(users);
        }
        else{
            completion(nil);
        }
    }];
}
+ (void) postFollowingUser: (User *)userToFollow withFollowedBy: (User *) followedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    PFRelation *relation = [followedByUser relationForKey:@"following"];
    [relation addObject:userToFollow];
    [followedByUser incrementKey:@"followingCount" byAmount:@(1)];
    [followedByUser saveInBackgroundWithBlock:completion];
}
+ (void) postFollowedUser: (User *)userToFollow withFollowedBy: (User *) followedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query whereKey:@"userFollowed" equalTo:userToFollow.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable followers, NSError * _Nullable error) {
        if (!followers){
            PFObject *newFollower = [PFObject objectWithClassName:@"Followers"];
            newFollower[@"userFollowed"] = userToFollow.objectId;
            PFRelation *relation = [newFollower relationForKey:@"followedByUser"];
            [relation addObject:followedByUser];
            [followers incrementKey:@"followersCount" byAmount:@(1)];
            [newFollower saveInBackgroundWithBlock:completion];
        }
        else if (followers){
            PFRelation *relation = [followers relationForKey:@"followedByUser"];
            [relation addObject:followedByUser];
            [followers incrementKey:@"followersCount" byAmount:@(1)];
            [followers saveInBackgroundWithBlock:completion];
        }
    }];
}
+ (void) postUnfollowingUser: (User *)userToUnfollow withUnfollowedBy: (User *) unFollowedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    [userToUnfollow.ACL setPublicWriteAccess:YES];
    PFRelation *relation = [unFollowedByUser relationForKey:@"following"];
    [relation removeObject:userToUnfollow];
    [unFollowedByUser incrementKey:@"followingCount" byAmount:@(-1)];
    [unFollowedByUser saveInBackgroundWithBlock:completion];
}
+ (void) postUnfollowedUser: (User *)userToUnfollow withUnfollowedBy: (User *) unfollowedByUser withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query whereKey:@"userFollowed" equalTo:userToUnfollow.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable followers, NSError * _Nullable error) {
        if (followers){
            PFRelation *relation = [followers relationForKey:@"followedByUser"];
            [relation removeObject:unfollowedByUser];
            [followers incrementKey:@"followersCount" byAmount:@(-1)];
            [followers saveInBackgroundWithBlock:completion];
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

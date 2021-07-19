//
//  Listing.h
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import <Parse/Parse.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Listing : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) User *author;
@property (nonatomic, strong) PFFileObject *listingImage;
@property (nonatomic, strong) NSString *listingTitle;
@property (nonatomic, strong) NSString *typeOfListing;
@property (nonatomic, strong) NSString *listingDescription;
@property (nonatomic, strong) NSString *listingLocation;
@property (nonatomic, strong) NSString *listingCategory;
@property (nonatomic, strong) NSString *listingBrand;
@property (nonatomic, strong) NSString *listingCondition;
@property (nonatomic, strong) NSString *listingPrice;
@property (nonatomic) BOOL isReported;
@property (nonatomic, strong) NSNumber *saveCount;
@property (nonatomic) BOOL isSaved;
@property (nonatomic, strong) NSString *authorEmail;


///Methods
+ (void) postUserListing:(UIImage * _Nullable)image withTitle:(NSString * _Nullable)title withType:(NSString * _Nullable)type withDescription:(NSString * _Nullable)description withLocation:(NSString * _Nullable)location withCategory:(NSString * _Nullable)category withBrand:(NSString * _Nullable)brand withCondition:(NSString * _Nullable)condition withPrice:(NSString * _Nullable)price withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) postSaveListing: (Listing *)listing withUser: (PFUser *)user completion:(void(^)(BOOL , NSError *))completion;
+ (void) postUnsaveListing: (Listing *)listing withUser: (PFUser *)user completion:(void(^)(BOOL , NSError *))completion;
+ (void) PFFileToUIImage: (PFFileObject *)imageFile completion:(void(^)(UIImage *, NSError *))completion;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END

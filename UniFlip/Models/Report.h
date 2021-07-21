//
//  Report.h
//  UniFlip
//
//  Created by mac2492 on 7/21/21.
//

#import <Parse/Parse.h>


NS_ASSUME_NONNULL_BEGIN
@class Listing;
@class User;

@interface Report : PFObject<PFSubclassing>

@property (nonatomic, strong) User *reportedBy;
@property (strong, nonatomic) Listing *listing;
@property (nonatomic, strong) NSString *reason;

+ (void) postReport:(User *)user withListing:(Listing *)listing withReason:(NSString *)reason withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

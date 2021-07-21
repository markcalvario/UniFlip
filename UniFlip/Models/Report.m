//
//  Report.m
//  UniFlip
//
//  Created by mac2492 on 7/21/21.
//

#import "Report.h"
#import "User.h"
#import "Listing.h"

@implementation Report

@dynamic reportedBy;
@dynamic listing;
@dynamic reason;

+ (nonnull NSString *)parseClassName {
    return @"Report";
}

+ (void) postReport:(User *)user withListing:(Listing *)listing withReason:(NSString *)reason withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Report *newReport = [Report new];
    newReport.reportedBy = user;
    newReport.listing = listing;
    newReport.reason = reason;
    
    PFRelation *relation = [listing relationForKey:@"reportedBy"];
    [relation addObject: user];
    [listing incrementKey:@"reportCount" byAmount:@(1)];
    listing.isReported = TRUE;
    [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            [newReport saveInBackground];
            completion(TRUE, nil);
        }
        else{
            completion(FALSE, error);
        }
    }];
    

}

@end

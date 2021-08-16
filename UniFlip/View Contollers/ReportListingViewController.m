//
//  ReportListingViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/21/21.
//

#import "ReportListingViewController.h"
#import "Report.h"
@import UITextView_Placeholder;


@interface ReportListingViewController ()
@property (strong, nonatomic) IBOutlet UITextView *reportTextView;
@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (strong, nonatomic) User *currentUser;
@end

@implementation ReportListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [User currentUser];
    self.reportTextView.placeholder = @"Reason for reporting";
    [self addAccessibility];
    
}
- (IBAction)didTapReport:(id)sender {
    NSString *reason = self.reportTextView.text;
    [Report postReport:self.currentUser withListing:self.listing withReason:reason withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            succeeded ? [self dismissViewControllerAnimated:TRUE completion:nil] :NSLog(@"Could not report");
            
    }];
}
-(void) addAccessibility{
    self.reportTextView.isAccessibilityElement = YES;
    self.reportButton.isAccessibilityElement = YES;
    
    self.reportTextView.accessibilityValue = [@"Type in a reason for reporting" stringByAppendingString:self.listing.listingTitle];
    self.reportButton.accessibilityValue = @"Tap this button to submit your report for this listing";
}

@end

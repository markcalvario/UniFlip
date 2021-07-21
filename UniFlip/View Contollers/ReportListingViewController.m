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
    // Do any additional setup after loading the view.
    self.currentUser = [User currentUser];
    self.reportTextView.placeholder = @"Reason for reporting";
    
}
- (IBAction)didTapReport:(id)sender {
    NSString *reason = self.reportTextView.text;
    
    [Report postReport:self.currentUser withListing:self.listing withReason:reason withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                [self dismissViewControllerAnimated:TRUE completion:nil];
            }
            else{
                NSLog(@"Could not report");
            }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

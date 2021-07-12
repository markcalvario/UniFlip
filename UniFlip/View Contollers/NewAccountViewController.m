//
//  NewAccountViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/12/21.
//

#import "NewAccountViewController.h"

@interface NewAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *schoolEmailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation NewAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.passwordField.secureTextEntry = YES;
    
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
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

//
//  LoginViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/12/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameOrEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;


@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayLoginScreen];
}
- (void)viewWillAppear:(BOOL)animated{
    [self displayLoginScreen];
}
-(void) displayLoginScreen{
    self.passwordLabel.secureTextEntry = YES;
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}
- (IBAction)didTapLogin:(id)sender {
    NSString *username = self.usernameOrEmailLabel.text;
    NSString *password = self.passwordLabel.text;
    [PFUser logInWithUsernameInBackground:username password:password
      block:^(PFUser *user, NSError *error) {
        if (user) {
            [self performSegueWithIdentifier:@"LoginToHomeSegue" sender:nil];
            
        } else {
            [self displayLoginError];
        }
    }];
}
-(void) displayLoginError{
    UIAlertController *loginErrorAlert = [UIAlertController alertControllerWithTitle:@"Login Unsuccessful"
                                                                               message:@"Your username and/or password do not match with our records."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Verify"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [loginErrorAlert addAction:tryAgainAction];
    [self presentViewController:loginErrorAlert animated:YES completion:nil];
}

@end

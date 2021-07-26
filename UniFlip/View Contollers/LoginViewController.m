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
    // Do any additional setup after loading the view.
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
            [self showLoginError];
        }
    }];
    
}

-(void) showLoginError{
    UIAlertController *loginErrorAlert = [UIAlertController alertControllerWithTitle:@"Login Unsuccessful"
                                                                               message:@"Your username and/or password do not match with our records."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Verify"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    // add the OK action to the alert controller
    [loginErrorAlert addAction:tryAgainAction];
    [self presentViewController:loginErrorAlert animated:YES completion:nil];
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

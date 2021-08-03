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
@property (strong, nonatomic) IBOutlet UIButton *createNewAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;


@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayLoginScreen];
    [self addAccessibility];
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
    
    PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:username];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (objects.count > 0) {
                PFObject *object = [objects objectAtIndex:0];
                NSString *username = [object objectForKey:@"username"];
                [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser* user, NSError* error){
                    user ? [self performSegueWithIdentifier:@"LoginToHomeSegue" sender:nil] : [self displayLoginError];
                }];
            }else{
                [PFUser logInWithUsernameInBackground: username password:password block:^(PFUser* user, NSError* error){
                    user ? [self performSegueWithIdentifier:@"LoginToHomeSegue" sender:nil] : [self displayLoginError];
                }];
            }
    }];
}
- (BOOL)validateEmailWithString:(NSString*)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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

-(void) addAccessibility{
    self.usernameOrEmailLabel.isAccessibilityElement = YES;
    self.passwordLabel.isAccessibilityElement = YES;
    self.createNewAccountButton.isAccessibilityElement = YES;
    self.loginButton.isAccessibilityElement = YES;
    
    self.usernameOrEmailLabel.accessibilityValue = @"Type in your username to your account";
    self.passwordLabel.accessibilityValue = @"Type in your password to your account";
    self.createNewAccountButton.accessibilityValue = @"Tap button to go to the create new account screen";
    self.loginButton.accessibilityValue = @"Tap login button once to login into your account";
    
}

@end

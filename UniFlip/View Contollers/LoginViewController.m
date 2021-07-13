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
          // Do stuff after successful login.
            [self performSegueWithIdentifier:@"LoginToHomeSegue" sender:nil];
            
        } else {
          // The login failed. Check error to see why.
        }
    }];
    
}
-(void) addUserToMarketPlace: (PFUser *) user{
    
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

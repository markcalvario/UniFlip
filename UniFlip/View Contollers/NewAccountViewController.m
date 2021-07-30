//
//  NewAccountViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/12/21.
//

#import "NewAccountViewController.h"
#import "LoginViewController.h"
#import "CollegeCell.h"
#import "Parse/Parse.h"
#import "User.h"

@interface NewAccountViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *schoolEmailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *collegeTextField;
@property (weak, nonatomic) IBOutlet UITableView *collegesTableView;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *toLoginScreenButton;

@property (strong, nonatomic) NSArray *arrayOfColleges;
@property (strong, nonatomic) NSMutableArray *arrayOfCollegesForTableView;
@property (strong, nonatomic) NSDictionary *collegeSelected;

@property (strong, nonatomic) NSString *schoolEmail;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *collegeName;

@property (strong, nonatomic) NSMutableSet *set;

@end

@implementation NewAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collegesTableView.delegate = self;
    self.collegesTableView.dataSource = self;
    
    self.passwordField.secureTextEntry = YES;
    self.collegesTableView.hidden = YES;
    [self updateListOfAllUSColleges];
    [self addAccessibility];
}

-(void) showSuccessAlert{
    UIAlertController *successfullyRegisteredAlert = [UIAlertController alertControllerWithTitle:[[@"Hi " stringByAppendingString:self.username] stringByAppendingString: @","]
                                                                               message:@"Congrats, on successfully registering your account! Please verify your email to start logging in!"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Verify"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                        NSDictionary *options = [NSDictionary dictionary];
                                                        NSURL* mailURL = [NSURL URLWithString:@"message://"];
                                                        if ([[UIApplication sharedApplication] canOpenURL:mailURL]) {
                                                            [[UIApplication sharedApplication] openURL:mailURL options:options completionHandler:^(BOOL success){
                                                                
                                                            }];
                                                        }
                                                        self.schoolEmailField.text = @"";
                                                        self.usernameField.text = @"";
                                                        self.passwordField.text = @"";
                                                        self.collegeTextField.text = @"";
                                                        [self performSegueWithIdentifier:@"SuccessfulRegisterToLogin" sender:nil];
    
                                                     }];
    [successfullyRegisteredAlert addAction:okAction];
    [self presentViewController:successfullyRegisteredAlert animated:YES completion:nil];
}

/// API Requests
-(void) updateListOfAllUSColleges{
    NSURL *url = [NSURL URLWithString:@"http://universities.hipolabs.com/search?country=United+States"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", error);
           }
           else {
               NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSMutableArray *colleges = [NSMutableArray array];
               for (NSDictionary *college in dataArray){
                   if (![colleges containsObject:college]){
                       [colleges addObject:college];
                   }
                }
               self.arrayOfColleges = [NSArray arrayWithArray:colleges];
           }
       }];
    [task resume];
}
-(void) updateCollegesFromSubstring: (NSString *) universitySubstring{
    self.arrayOfCollegesForTableView = [NSMutableArray array];
    for (NSDictionary *college in self.arrayOfColleges){
         NSString *collegeName = college[@"name"];
         collegeName = [collegeName lowercaseString];
         if ([collegeName containsString:universitySubstring] && (![self.arrayOfCollegesForTableView containsObject:collegeName])){
             [self.arrayOfCollegesForTableView addObject: college];
         }

     }
    
    [self.collegesTableView reloadData];
}

#pragma mark - Account Info Validation
-(BOOL) doesEmailDomainMatchUniversity: (NSString *)schoolEmail schoolName:(NSString *)collegeName{
    NSArray *usernameAndDomain = [schoolEmail componentsSeparatedByString:@"@"];
    NSString *schoolEmailDomain = [usernameAndDomain objectAtIndex:1];
    schoolEmailDomain = [schoolEmailDomain lowercaseString];
    if ([self.collegeSelected isEqual:nil]){
        return FALSE;
    }
    
    for (NSString *emailDomain in self.collegeSelected[@"domains"]){
        if ([schoolEmailDomain isEqualToString:[emailDomain lowercaseString]]){
            return TRUE;
        }
    }
    return FALSE;
}
- (BOOL)validateEmailWithString:(NSString*)checkString{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Actions
- (IBAction)didTapRegister:(id)sender {
    self.schoolEmail = [self.schoolEmailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.collegeName = [self.collegeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( ([self.schoolEmail length] == 0) || ( [self.username length] == 0) || ([self.password length]== 0) || ([self.collegeName length]==0) || (![self validateEmailWithString:self.schoolEmail])){
        NSLog(@"%@", @"incomplete fields");
        return;
    }

    if ([self doesEmailDomainMatchUniversity:self.schoolEmail schoolName:self.collegeName]){
        [User postUser:self.username withEmail:self.schoolEmail withPassword:self.password withSchoolName:self.collegeName withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                [self showSuccessAlert];
                [self performSegueWithIdentifier:@"SuccessfulRegisterToLogin" sender:@"successfully registered"];
            }
        }];
    }
    else{
        NSLog(@"%@", @"No match");
    }
    
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
    self.collegesTableView.hidden = YES;
}

- (IBAction)didEditUniversityField:(id)sender {
    NSString *universitySubstring = [self.collegeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    universitySubstring = [universitySubstring lowercaseString];
    self.collegesTableView.hidden = NO;
    [self updateCollegesFromSubstring:universitySubstring];
}



#pragma mark - Tableview for College Options
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollegeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collegeCell" forIndexPath:indexPath];
    NSDictionary *college = self.arrayOfCollegesForTableView[indexPath.row];
    NSString *collegeName = college[@"name"];
    collegeName = [collegeName capitalizedString];
    [cell.collegeNameButton setTitle:collegeName forState: UIControlStateNormal];
    [cell.collegeNameButton setTag: indexPath.row];
    [cell.collegeNameButton addTarget:self action:@selector(didTapCollegeOption:) forControlEvents:UIControlEventTouchUpInside];
    cell.isAccessibilityElement = YES;
    cell.accessibilityValue = [@"School: " stringByAppendingString:collegeName];
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfCollegesForTableView.count;
}
-(void) didTapCollegeOption: (UIButton *)sender{
    NSDictionary *college = self.arrayOfCollegesForTableView[sender.tag];
    NSString *collegeName = college[@"name"];
    collegeName = [collegeName capitalizedString];
    self.collegeTextField.text = collegeName;
    self.collegesTableView.hidden = YES;
    self.collegeSelected = college;
}
-(void) addAccessibility{
    self.collegeTextField.isAccessibilityElement = YES;
    self.schoolEmailField.isAccessibilityElement = YES;
    self.usernameField.isAccessibilityElement = YES;
    self.passwordField.isAccessibilityElement = YES;
    self.registerButton.isAccessibilityElement = YES;
    self.toLoginScreenButton.isAccessibilityElement = YES;
    
    self.collegeTextField.accessibilityValue = @"Type in the name of the school you currently attend";
    self.schoolEmailField.accessibilityValue = @"Type in the your school email";
    self.usernameField.accessibilityValue = @"Type in a username you want to associate your account with";
    self.passwordField.accessibilityValue = @"Type in a password you want to associate your account with";
    self.registerButton.accessibilityValue = @"Tap button once to register your account";
    self.toLoginScreenButton.accessibilityValue = @"Tap this button once to go back to the login screen if you already have an account";
}



@end

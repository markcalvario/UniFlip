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
//#import "../Assets.xcassets/defaultProfilePic.imageset/Image.png"

@interface NewAccountViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *schoolEmailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *collegeTextField;
@property (weak, nonatomic) IBOutlet UITableView *collegesTableView;

@property (strong, nonatomic) NSArray *arrayOfColleges;
@property (strong, nonatomic) NSMutableArray *arrayOfCollegesForTableView;
@property (strong, nonatomic) NSDictionary *collegeSelected;

@property (strong, nonatomic) NSString *schoolEmail;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *collegeName;

@end

@implementation NewAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collegesTableView.delegate = self;
    self.collegesTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
    self.passwordField.secureTextEntry = YES;
    self.collegesTableView.hidden = YES;
    [self updateListOfAllUSColleges];
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
    // add the OK action to the alert controller
    [successfullyRegisteredAlert addAction:okAction];
    [self presentViewController:successfullyRegisteredAlert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

/// API Requests
-(void) updateListOfAllUSColleges{
    NSURL *url = [NSURL URLWithString:@"http://universities.hipolabs.com/search?country=United+States"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //If the API call returned an error, print out the error message
           if (error != nil) {
               NSLog(@"%@", error);
           }
            //If API call successful, add the college dictionaries result into the array
           else {
               NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.arrayOfColleges = dataArray;
           }
       }];
    [task resume];
}
-(void) updateCollegesFromSubstring: (NSString *) universitySubstring{
    self.arrayOfCollegesForTableView = [[NSMutableArray alloc] init];
    for (NSDictionary *college in self.arrayOfColleges){
         NSString *collegeName = college[@"name"];
         collegeName = [collegeName lowercaseString];
         if ([collegeName containsString:universitySubstring]){
             [self.arrayOfCollegesForTableView addObject: college];
         }

     }
    [self.collegesTableView reloadData];
}
//*******************


/// Email Verification/Validation
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
    return TRUE; //change back to FALSE
}
- (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
//*****************

///Create User
-(void) createUserAccount: (NSString *) collegeName{
    PFUser *newUser = [PFUser user];
    newUser.email = self.schoolEmail;
    newUser.username = self.username;
    newUser.password = self.password;
    newUser[@"biography"] = @"";
    newUser[@"university"] = collegeName;
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            
            NSLog(@"%@", newUser);
            [self addUserToMarketplace:newUser.username school:collegeName];
            [self showSuccessAlert];
            //[self performSegueWithIdentifier:@"SuccessfulRegisterToLogin" sender:@"successfully registered"];
        }
    }];
}

-(void) addUserToMarketplace:(NSString *) username school: (NSString *)school{
    PFUser *user = nil;
    PFQuery *queryUser = [PFUser query];
    [queryUser whereKey:@"username" equalTo:username]; // find the unique username
    NSArray *users = [queryUser findObjects];
    user = users[0];
    PFQuery *query = [PFQuery queryWithClassName:@"Marketplace"];
    [query whereKey:@"school" equalTo:school];
    [query findObjectsInBackgroundWithBlock:^(NSArray *markets, NSError *error) {
        if (error) {
          NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        /// No marketplace exists
        if ([markets count] == 0){
            PFObject *marketplace = [PFObject objectWithClassName:@"Marketplace"];
            marketplace[@"school"] = school;
            [marketplace addUniqueObject:user forKey:@"users"];
            [marketplace saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
              if (succeeded) {
                  NSLog(@"added user to marketplace");
              } else {
                  NSLog(@"error creating a marketplace");
              }
            }];
        }
        else{
            PFObject *marketplace = markets[0];
            [marketplace addUniqueObject:user forKey:@"users"];
            [marketplace saveInBackground];
        }
        

    }];
}



/// ACTIONS
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
        [self createUserAccount:self.collegeName];
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



/// AutoComplete TableView
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollegeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collegeCell" forIndexPath:indexPath];
    NSDictionary *college = self.arrayOfCollegesForTableView[indexPath.row];
    NSString *collegeName = college[@"name"];
    collegeName = [collegeName capitalizedString];
    [cell.collegeNameButton setTitle:collegeName forState: UIControlStateNormal];
    [cell.collegeNameButton setTag: indexPath.row];
    [cell.collegeNameButton addTarget:self action:@selector(didTapCollegeOption:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfCollegesForTableView.count;
}


/// Method that replaces College Text Field Text with the college name selected by the user in the tableview
-(void) didTapCollegeOption: (UIButton *)sender{
    NSDictionary *college = self.arrayOfCollegesForTableView[sender.tag];
    NSString *collegeName = college[@"name"];
    collegeName = [collegeName capitalizedString];
    self.collegeTextField.text = collegeName;
    self.collegesTableView.hidden = YES;
    self.collegeSelected = college;
}








@end

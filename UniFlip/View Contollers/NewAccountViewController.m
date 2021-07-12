//
//  NewAccountViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/12/21.
//

#import "NewAccountViewController.h"
#import "CollegeCell.h"

@interface NewAccountViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *schoolEmailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *collegeTextField;
@property (weak, nonatomic) IBOutlet UITableView *collegesTableView;

@property (strong, nonatomic) NSArray *arrayOfColleges;
@property (strong, nonatomic) NSMutableArray *arrayOfCollegesForTableView;
@property (strong, nonatomic) NSDictionary *collegeSelected;

@end

@implementation NewAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collegesTableView.delegate = self;
    self.collegesTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
    self.passwordField.secureTextEntry = YES;
    self.collegesTableView.hidden = YES;
    [self getListOfAllUSColleges];
}

-(void) getListOfAllUSColleges{
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

- (IBAction)didTapRegister:(id)sender {
    NSString *schoolEmail = self.schoolEmailField.text;
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    NSString *collegeName = self.collegeTextField.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    if (([schoolEmail isEqual:nil]) || ([username isEqual:nil]) || ([password isEqual:nil]) || ([collegeName isEqual:nil])){
        
    }

    if ([self doesEmailDomainMatchUniversity:schoolEmail schoolName:collegeName]){
        NSLog(@"%@", @"Yes");
    }
    else{
        NSLog(@"%@", @"No");
    }
    
}

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

- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
    self.collegesTableView.hidden = YES;
}

- (IBAction)didEditUniversityField:(id)sender {
    NSString *universitySubstring = self.collegeTextField.text;
    universitySubstring = [universitySubstring lowercaseString];
    self.collegesTableView.hidden = NO;
    [self getCollegesFromSubstring:universitySubstring];
}

-(void) getCollegesFromSubstring: (NSString *) universitySubstring{
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end

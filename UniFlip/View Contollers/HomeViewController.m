//
//  HomeViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/12/21.
//

#import "HomeViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "Listing.h"
#import "CategoryCell.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listingCategoryTableView;
@property (strong, nonatomic) NSMutableDictionary *categoryToArrayOfPosts;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listingCategoryTableView.delegate = self;
    self.listingCategoryTableView.dataSource = self;
    self.categoryToArrayOfPosts = [NSMutableDictionary dictionary];
    self.arrayOfCategories = [NSMutableArray array];
    [self getListingsByCategory];
}



- (IBAction)didTapLogOut:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
}
- (IBAction)didTapExitKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}

-(void) getListingsByCategory{
    PFQuery *queryListings = [PFQuery queryWithClassName:@"Listing"];
    [queryListings orderByDescending:@"createdAt"];
    [queryListings includeKey:@"listingCategory"];
    
    
    // fetch data asynchronously
    [queryListings findObjectsInBackgroundWithBlock:^(NSArray<Listing *> * _Nullable listings, NSError * _Nullable error) {
        if (listings) {
            // do something with the data fetched
            for (Listing *listing in listings){
                NSString *category = listing.listingCategory;
                if ( [self.categoryToArrayOfPosts objectForKey:listing.listingCategory]){
                    NSMutableArray *arrayOfListingsValue = [self.categoryToArrayOfPosts objectForKey:category];
                    [arrayOfListingsValue addObject:listing];
                    [self.categoryToArrayOfPosts setObject:arrayOfListingsValue forKey:category];
                    
                }
                else{
                    NSMutableArray *arrayOfListingsValue = [[NSMutableArray alloc] init];
                    [arrayOfListingsValue addObject:listing];
                    
                    [self.arrayOfCategories addObject: category];
                    [self.categoryToArrayOfPosts setObject:arrayOfListingsValue forKey:category];
                }
            }
            [self.listingCategoryTableView reloadData];
        }
        else {
            // handle error
        }
    }];
}


#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString *category = self.arrayOfCategories[indexPath.row];
    
    cell.categoryLabel.text = category;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%ld", [self.categoryToArrayOfPosts count]);
    return [self.categoryToArrayOfPosts count];
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

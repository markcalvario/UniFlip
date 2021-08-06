//
//  FollowingFollowersViewController.m
//  UniFlip
//
//  Created by mac2492 on 8/4/21.
//

#import "FollowingFollowersViewController.h"
#import <MaterialComponents/MaterialTabs+TabBarView.h>
#import "UserCell.h"
#import "Listing.h"

@interface FollowingFollowersViewController ()<MDCTabBarViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) MDCTabBarView *tabBarView;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@property (strong, nonatomic) NSArray *arrayOfUsers;

@end

@implementation FollowingFollowersViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.usersTableView.delegate = self;
    self.usersTableView.dataSource = self;
    [self displayFollowingFollowers];

}
-(void) displayFollowingFollowers{
    self.arrayOfUsers = [NSArray array];
    PFRelation *relation = [self.userOfProfileToView relationForKey:@"following"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (users){
            self.arrayOfUsers = users;
            [self.usersTableView reloadData];
        }
    }];
    [self displayTabBar];
}
#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    User *user = [self.arrayOfUsers objectAtIndex:indexPath.row];
    
    cell.usernameLabel.text = user.username;
    cell.bioLabel.text = user.biography;
    PFFileObject *profilePicFile = user.profilePicture;
    if (profilePicFile){
        [Listing PFFileToUIImage:profilePicFile completion:^(UIImage * image, NSError * error) {
            image ? [cell.profilePicture setImage:image] : [cell.profilePicture setImage: [UIImage imageNamed:@"envelope_icon"]];
        }];
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfUsers.count;
}

-(void) displayTabBar{
    CGFloat topbarHeight = (self.view.window.windowScene.statusBarManager.statusBarFrame.size.height +
           self.navigationController.navigationBar.frame.size.height);
    self.tabBarView = [[MDCTabBarView alloc] init];
    self.tabBarView.tabBarDelegate = self;

    self.tabBarView.items = @[
        [[UITabBarItem alloc] initWithTitle:@"Following" image:nil tag:0],
        [[UITabBarItem alloc] initWithTitle:@"Followers" image:nil tag:0],
    ];
    
    self.tabBarView.preferredLayoutStyle = MDCTabBarViewLayoutStyleFixed;
    self.tabBarView.frame = CGRectMake(0, topbarHeight, self.view.frame.size.width, 50);
    self.tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.isInitialiallyViewingFollowers ? [self.tabBarView setSelectedItem:[self.tabBarView.items objectAtIndex:1]] : [self.tabBarView setSelectedItem:[self.tabBarView.items objectAtIndex:0]];
    [self.view addSubview:self.tabBarView];
    [self addConstraintsToTabBar];
}
-(void) addConstraintsToTabBar{
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                    constraintWithItem: self.tabBarView
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem: self.view
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                    constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.tabBarView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem: self.view
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0
                                       constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:
                                                 NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.tabBarView attribute:NSLayoutAttributeBottom
                                                 relatedBy:NSLayoutRelationEqual toItem:self.usersTableView attribute:
                                                 NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *height = [NSLayoutConstraint
                                   constraintWithItem:self.tabBarView
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:0
                                   constant:50];
    
    [self.view addConstraint:leading];
    [self.view addConstraint:trailing];
    [self.view addConstraint:top];
    [self.view addConstraint:bottom];
    
    [self.tabBarView addConstraint:height];
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

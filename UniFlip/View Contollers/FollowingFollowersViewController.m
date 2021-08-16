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
@property (strong, nonatomic) NSArray *arrayOfUsersFollowing;
@property (strong, nonatomic) NSArray *arrayOfFollowers;
@property (strong, nonatomic) User *currentlyLoggedInUser;


@end

@implementation FollowingFollowersViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.usersTableView.delegate = self;
    self.usersTableView.dataSource = self;
    self.currentlyLoggedInUser = [User currentUser];
    [self updateArrayOfUsersFollowing];
    [self updateArrayOfFollowers];
    [self displayFollowingFollowers];
}
-(void) displayFollowingFollowers{
    [self displayTabBar];
}
-(void) updateArrayOfUsersFollowing{
    self.arrayOfUsersFollowing = [NSArray array];
    PFRelation *relation = [self.userOfProfileToView relationForKey:@"following"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (users){
            self.arrayOfUsersFollowing = users;
            self.isInitialiallyViewingFollowers ? : [self.usersTableView reloadData];
        }
    }];
}
-(void) updateArrayOfFollowers{
    self.arrayOfFollowers = [NSArray array];
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query whereKey:@"userFollowed" equalTo:self.userOfProfileToView.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object){
            PFRelation *relation = [object relationForKey:@"followedByUser"];
            PFQuery *relationQuery = [relation query];
            [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
                if (users){
                    self.arrayOfFollowers = users;
                    !self.isInitialiallyViewingFollowers ? : [self.usersTableView reloadData];
                }
            }];
        }
    }];
}
- (void) didTapFollowButton:(UIButton *)sender {
    
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    User *user;
    if (self.isInitialiallyViewingFollowers){
        user = [self.arrayOfFollowers objectAtIndex:indexPath.row];
    }
    else{
        user = [self.arrayOfUsersFollowing objectAtIndex:indexPath.row];
    }
    
    cell.usernameLabel.text = user.username;
    cell.bioLabel.text = user.biography;
    PFFileObject *profilePicFile = user.profilePicture;
    if (profilePicFile){
        [Listing PFFileToUIImage:profilePicFile completion:^(UIImage * image, NSError * error) {
            image ? [cell.profilePicture setImage:image] : [cell.profilePicture setImage: [UIImage imageNamed:@"envelope_icon"]];
        }];
    }
    if ([user.objectId isEqualToString:self.currentlyLoggedInUser.objectId]){
        cell.followButton.hidden = YES;
    }
    else{
        cell.followButton.hidden = NO;
        PFRelation *relation = [self.currentlyLoggedInUser relationForKey:@"following"];
        PFQuery *query = [relation query];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable arrayOfUsers, NSError * _Nullable error) {
            if (arrayOfUsers){
                BOOL isFollowing = FALSE;
                for (User *userFollowing in arrayOfUsers){
                    if ([userFollowing.objectId isEqualToString:user.objectId]){
                        [cell.followButton setBackgroundColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1]];
                        [cell.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
                        isFollowing = TRUE;
                    }
                }
                if(!isFollowing){
                    [cell.followButton setBackgroundColor:[UIColor whiteColor]];
                    [cell.followButton  setTitleColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1] forState:UIControlStateNormal];
                    [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                    [cell.followButton.layer  setBorderWidth:2];
                    [cell.followButton.layer setBorderColor:[[UIColor alloc]initWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1].CGColor];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            
        }];
    }
    
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(didTapFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isInitialiallyViewingFollowers){
        return self.arrayOfFollowers.count;
    }
    return self.arrayOfUsersFollowing.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *user;
    if (self.isInitialiallyViewingFollowers){
        user = [self.arrayOfFollowers objectAtIndex:indexPath.row];
    }else{
        user = [self.arrayOfUsersFollowing objectAtIndex:indexPath.row];
    }
    NSLog(@"%@", user.username);
    //[self performSegueWithIdentifier:@"FollowingFollowersToProfile" sender:user];
}
#pragma mark - TabBar
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
- (void)tabBarView:(MDCTabBarView *)tabBarView didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString:@"Following"]){
        self.isInitialiallyViewingFollowers = FALSE;
    }
    else{
        self.isInitialiallyViewingFollowers = TRUE;
    }
    [self.usersTableView reloadData];
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

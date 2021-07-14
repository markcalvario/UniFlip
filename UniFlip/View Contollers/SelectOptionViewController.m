//
//  SelectOptionViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import "SelectOptionViewController.h"
#import "OptionCell.h"

@interface SelectOptionViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;

@end

@implementation SelectOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.optionsTableView.delegate = self;
    self.optionsTableView.dataSource = self;
    // Do any additional setup after loading the view.
    
    
}
- (void) dealloc{

    self.delegate = nil;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell" forIndexPath:indexPath];
    NSString *option = self.data[indexPath.row];
    
    
    //[self.delegate addOptionViewController:self didFinishEnteringItem:option];
    [cell.optionButton setTag:indexPath.row];
    [cell.optionButton addTarget:self action:@selector(didTapOption:) forControlEvents:UIControlEventTouchUpInside];
    [cell.optionButton setTitle:option forState:UIControlStateNormal];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


///actions
-(void) didTapOption: (UIButton *) sender{
    NSString *option = self.data[sender.tag];
    //[self performSegueWithIdentifier:@"OptionSelectedToSell" sender:option];
    if(_delegate && [_delegate respondsToSelector:@selector(addOptionSelectedToViewController:)]){
        [_delegate addOptionSelectedToViewController:option];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*if ( [[segue identifier] isEqualToString: @"OptionSelectedToSell"]){
        UINavigationController *otherUserProfileViewController = [segue destinationViewController];
        otherUserProfileViewController.categor
    }*/
}



@end

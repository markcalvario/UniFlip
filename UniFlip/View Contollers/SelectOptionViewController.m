//
//  SelectOptionViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import "SelectOptionViewController.h"
#import "OptionCell.h"
@import GooglePlaces;
@import UIKit;

@interface SelectOptionViewController ()<GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchOptionsBar;

@end

@implementation SelectOptionViewController{
    GMSAutocompleteTableDataSource *tableDataSource;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchOptionsBar.delegate = self;
    self.optionsTableView.isAccessibilityElement = YES;
    if (self.data.count == 0){
        tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
        tableDataSource.delegate = self;
        self.optionsTableView.delegate = tableDataSource;
        self.optionsTableView.dataSource = tableDataSource;
        self.optionsTableView.accessibilityValue = @"Places to choose from";
    }
    else{
        self.optionsTableView.delegate = self;
        self.optionsTableView.dataSource = self;
        self.optionsTableView.accessibilityValue = @"Categories to choose from";
    }
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate
- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    [self.optionsTableView reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    [self.optionsTableView reloadData];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
    CLLocationDegrees longitude = place.coordinate.longitude;
    CLLocationDegrees latitude = place.coordinate.latitude;
    self.searchOptionsBar.text = place.formattedAddress;
    if(_delegate && [_delegate respondsToSelector:@selector(addOptionSelectedToViewController: withInputType:)]){
        [_delegate addOptionSelectedToViewController:place.formattedAddress withInputType:@"Location"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"Error %@", error.description);
}

- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didSelectPrediction:(GMSAutocompletePrediction *)prediction {
    return YES;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [tableDataSource sourceTextHasChanged:searchText];
}

#pragma mark - Table View
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell" forIndexPath:indexPath];
    NSString *option = self.data[indexPath.row];
    cell.isAccessibilityElement = YES;
    cell.accessibilityValue = [option stringByAppendingString:@" category"];
    cell.optionButton.isAccessibilityElement = YES;
    cell.optionButton.accessibilityValue = [option stringByAppendingString:@" category button"];
    [cell.optionButton setTag:indexPath.row];
    [cell.optionButton setTitle:option forState:UIControlStateNormal];
    cell.userInteractionEnabled = YES;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *option = self.data[indexPath.row];
    //[self performSegueWithIdentifier:@"OptionSelectedToSell" sender:option];
    if(_delegate && [_delegate respondsToSelector:@selector(addOptionSelectedToViewController: withInputType:)]){
        [_delegate addOptionSelectedToViewController:option withInputType:@"Category"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}




@end

//
//  PlaceAutocompleteViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import "PlaceAutocompleteViewController.h"
#import "OptionCell.h"
@import GooglePlaces;
@import UIKit;

@interface PlaceAutocompleteViewController () <GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *resultsSearchTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchOptionsBar;

@end

@implementation PlaceAutocompleteViewController {
  GMSAutocompleteTableDataSource *tableDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchOptionsBar.delegate = self;
    self.resultsSearchTableView.isAccessibilityElement = YES;
    if (self.data.count == 0){
        tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
        tableDataSource.delegate = self;
        self.resultsSearchTableView.delegate = tableDataSource;
        self.resultsSearchTableView.dataSource = tableDataSource;
        self.resultsSearchTableView.accessibilityValue = @"Places to choose from";
    }
    else{
        self.resultsSearchTableView.delegate = self;
        self.resultsSearchTableView.dataSource = self;
        self.resultsSearchTableView.accessibilityValue = @"Categories to choose from";
    }
    
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate
- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator off.
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    // Reload table data.
    [self.resultsSearchTableView reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator on.
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    // Reload table data.
    [self.resultsSearchTableView reloadData];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
    // Do something with the selected place.
    self.searchOptionsBar.text = place.formattedAddress;
    if(_delegate && [_delegate respondsToSelector:@selector(addPlaceSelectedToViewController: withInputType:)]){
        [_delegate addPlaceSelectedToViewController: place.formattedAddress withInputType:@"Location"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
    // Handle the error
    NSLog(@"Error %@", error.description);
}

- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didSelectPrediction:(GMSAutocompletePrediction *)prediction {
    return YES;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Update the GMSAutocompleteTableDataSource with the search text.
    [tableDataSource sourceTextHasChanged:searchText];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell" forIndexPath:indexPath];
    NSString *option = self.data[indexPath.row];
    cell.isAccessibilityElement = YES;
    cell.accessibilityValue = [option stringByAppendingString:@" category"];
    //[self.delegate addOptionViewController:self didFinishEnteringItem:option];
    cell.option2Button.isAccessibilityElement = YES;
    cell.option2Button.accessibilityValue = [option stringByAppendingString:@" category button"];
    [cell.option2Button setTag:indexPath.row];
    [cell.option2Button addTarget:self action:@selector(didTapOption:) forControlEvents:UIControlEventTouchUpInside];
    [cell.option2Button setTitle:option forState:UIControlStateNormal];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}
-(void) didTapOption: (UIButton *) sender{
    NSString *option = self.data[sender.tag];
    //[self performSegueWithIdentifier:@"OptionSelectedToSell" sender:option];
    if(_delegate && [_delegate respondsToSelector:@selector(addPlaceSelectedToViewController: withInputType:)]){
        [_delegate addPlaceSelectedToViewController: option withInputType:@"Category"];
    }
    [self.navigationController popViewControllerAnimated:YES];

}


@end

//
//  PlaceAutocompleteViewController.m
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import "PlaceAutocompleteViewController.h"
@import GooglePlaces;
@import UIKit;

@interface PlaceAutocompleteViewController () <GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *resultsSearchTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchOptionsBar;

@end

@implementation PlaceAutocompleteViewController {
  GMSAutocompleteTableDataSource *tableDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchOptionsBar.delegate = self;

    tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    tableDataSource.delegate = self;

    self.resultsSearchTableView.delegate = tableDataSource;
    self.resultsSearchTableView.dataSource = tableDataSource;

    
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
    NSLog(@"Place name: %@", place.name);
    NSLog(@"Place address: %@", place.formattedAddress);
    NSLog(@"Place attributions: %@", place.attributions);
    self.searchOptionsBar.text = place.formattedAddress;
    
    if(_delegate && [_delegate respondsToSelector:@selector(addPlaceSelectedToViewController:)]){
        [_delegate addPlaceSelectedToViewController: place.formattedAddress];
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

@end

//
//  PlaceAutocompleteViewController.h
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PlaceAutocompleteViewController;

@protocol PlaceAutocompleteDelege <NSObject>
@optional
- (void)addPlaceSelectedToViewController:(NSString *)data withInputType:(NSString *)inputType;
@end


@interface PlaceAutocompleteViewController : UIViewController
@property (nonatomic, weak) id <PlaceAutocompleteDelege> delegate;
@property (nonatomic, strong) NSArray *data;
@end

NS_ASSUME_NONNULL_END

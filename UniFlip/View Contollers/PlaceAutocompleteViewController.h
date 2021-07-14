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
- (void)addPlaceSelectedToViewController:(NSString *)data;
@end


@interface PlaceAutocompleteViewController : UIViewController
@property (nonatomic, weak) id <PlaceAutocompleteDelege> delegate;

@end

NS_ASSUME_NONNULL_END

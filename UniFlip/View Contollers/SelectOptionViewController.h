//
//  SelectOptionViewController.h
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <PFGeoPoint.h>

NS_ASSUME_NONNULL_BEGIN
@class SelectOptionViewController;

@protocol SelectOptionViewControllerDelege <NSObject>
@optional
- (void)addOptionSelectedToViewController:(NSString *)data withInputType:(NSString *)inputType withCoordinates:(PFGeoPoint * _Nullable )coordinates;

@end


@interface SelectOptionViewController : UIViewController
@property (strong, nonatomic) NSArray *data;
@property (nonatomic, weak) id <SelectOptionViewControllerDelege> delegate;
@end

NS_ASSUME_NONNULL_END

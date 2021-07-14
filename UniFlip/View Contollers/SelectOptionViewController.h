//
//  SelectOptionViewController.h
//  UniFlip
//
//  Created by mac2492 on 7/13/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SelectOptionViewController;

@protocol SelectOptionViewControllerDelege <NSObject>
//- (void)addOptionViewController:(SelectOptionViewController *)controller didFinishEnteringItem:(NSString *)option;
@optional
- (void)addOptionSelectedToViewController:(NSObject*)data;
@end


@interface SelectOptionViewController : UIViewController
@property (strong, nonatomic) NSArray *data;
@property (nonatomic, weak) id <SelectOptionViewControllerDelege> delegate;
@property (strong, nonatomic) NSString *optionFor;


@end

NS_ASSUME_NONNULL_END

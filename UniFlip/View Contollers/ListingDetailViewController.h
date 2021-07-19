//
//  ListingDetailViewController.h
//  UniFlip
//
//  Created by mac2492 on 7/18/21.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListingDetailViewController : UIViewController
@property (strong, nonatomic) Listing *listing;


+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
@end

NS_ASSUME_NONNULL_END

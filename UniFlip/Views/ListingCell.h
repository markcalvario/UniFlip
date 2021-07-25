//
//  ListingCell.h
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListingCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *listingImage;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;



// For the ProfileViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileListingImage;
@property (weak, nonatomic) IBOutlet UILabel *profileListingPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileListingTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileListingSaveButton;

//ListingsByCategoryController
@property (strong, nonatomic) IBOutlet UIImageView *listingByCategoryImage;
@property (strong, nonatomic) IBOutlet UILabel *listingByCategoryPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *listingByCategoryTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *listingByCategorySaveButton;


@end

NS_ASSUME_NONNULL_END

//
//  ListingCell.m
//  UniFlip
//
//  Created by mac2492 on 7/14/21.
//

#import "ListingCell.h"

@implementation ListingCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.titleLabel.isAccessibilityElement = YES;
    self.priceLabel.isAccessibilityElement = YES;
    self.listingImage.isAccessibilityElement = YES;
    self.saveButton.isAccessibilityElement = YES;
}
- (void) withTitleLabel:(UILabel *) titleLabel withSaveButton:(UIButton *) saveButton withPriceLabel: (UILabel *)priceLabel withListingImage: (UIImageView *)listingImage withListing:(Listing *)listing withCategory: (NSString *)category withIndexPath: (NSIndexPath *)indexPath withIsFiltered:(BOOL)isFiltered withSearchText:(NSString *)searchText{
    titleLabel.text = listing.listingTitle;
    if (isFiltered && searchText.length > 0){
        NSRange listingTitleRange = [listing.listingTitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSMutableAttributedString *substring = [[NSMutableAttributedString alloc] initWithString:listing.listingTitle];
        [substring addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:listingTitleRange];
        titleLabel.attributedText = substring;
    }
    else{
       titleLabel.text = listing.listingTitle;
    }
    NSString *price = listing.listingPrice;
    priceLabel.text = [@"$" stringByAppendingString: price];
    
    PFFileObject *listingImageFile = [listing.photos objectAtIndex:0];
    [listingImage setImage:nil];
    [listingImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            [listingImage setImage:image];
        }
    }];
    [saveButton setTitle: category forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:0];
    saveButton.tag = indexPath.row;
    titleLabel.accessibilityValue = [@"Listing name: " stringByAppendingString:listing.listingTitle];
    priceLabel.accessibilityValue = [[[[@"The price of " stringByAppendingString:listing.listingTitle] stringByAppendingString:@" is "] stringByAppendingString:listing.listingPrice] stringByAppendingString:@" dollars"];
    listingImage.accessibilityValue = [@"The image of listing, " stringByAppendingString:listing.listingTitle];
    
    if (listing.isSaved){
        saveButton.accessibilityValue = [[@"You have " stringByAppendingString:listing.listingTitle] stringByAppendingString:@" as saved"];
    }
    else{
        saveButton.accessibilityValue = [[@"You do not have " stringByAppendingString:listing.listingTitle] stringByAppendingString:@" as saved"];
    }
    
}


@end

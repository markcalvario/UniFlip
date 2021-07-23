//
//  PhotoCell.h
//  UniFlip
//
//  Created by mac2492 on 7/22/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *listingPhoto;


@property (strong, nonatomic) IBOutlet UIImageView *detailPhoto;

@end

NS_ASSUME_NONNULL_END

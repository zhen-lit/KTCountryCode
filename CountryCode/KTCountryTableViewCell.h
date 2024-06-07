//
//  KTCountryTableViewCell.h
//  KTCountryCode
//
//  Created by Lit on 2024/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTCountryTableViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;
- (void)setupContentWith:(NSString *)title code:(NSString *)code;

@end

NS_ASSUME_NONNULL_END

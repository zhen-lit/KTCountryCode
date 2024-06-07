//
//  KTCountryCodeViewController.h
//  KTCountryCode
//
//  Created by Lit on 2024/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^selectedCountryCodeBlock) (NSString *countryCode, NSString *countryName);

@protocol KTCountryCodeDelegate <NSObject>

@optional
- (void)selectedCountryCode:(NSString *)countryCode countryName:(NSString *)countryName;

@end

@interface KTCountryCodeViewController : UIViewController

@property (nonatomic, weak) id<KTCountryCodeDelegate> delegate;
@property (nonatomic, copy) selectedCountryCodeBlock countryBlock;

@end

NS_ASSUME_NONNULL_END

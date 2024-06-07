//
//  ViewController.m
//  KTCountryCode
//
//  Created by Lit on 2024/6/7.
//

#import "ViewController.h"
#import "KTCountryCodeViewController.h"

@interface ViewController () <KTCountryCodeDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KTCountryCodeViewController *viewController = [[KTCountryCodeViewController alloc] init];
    viewController.delegate = self;
    viewController.countryBlock = ^(NSString * _Nonnull countryCode, NSString * _Nonnull countryName) {
        NSLog(@"你选择的国家地区: %@ - %@", countryName, countryCode);
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - KTCountryCodeDelegate

- (void)selectedCountryCode:(NSString *)countryCode countryName:(NSString *)countryName {
    NSLog(@"你选择的国家地区: %@ - %@", countryName, countryCode);
}

@end

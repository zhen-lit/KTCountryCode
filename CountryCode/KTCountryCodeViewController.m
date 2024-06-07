//
//  KTCountryCodeViewController.m
//  KTCountryCode
//
//  Created by Lit on 2024/6/7.
//

#import "KTCountryCodeViewController.h"
#import "KTCountryTableViewCell .h"
#import "UIImage+Color.h"
#import "UIScrollView+EmptyDataSet.h"

@interface KTCountryCodeViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSArray *sectionTitles;
@property (nonatomic, copy) NSDictionary *groupedCountriesDic;
@property (nonatomic, copy) NSMutableArray *filteredDataArray;

@end

@implementation KTCountryCodeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationItem.title = @"选择国家和地区";
    [self setupSubviews];
    [self handleCountryData];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault; // 设置状态栏样式
}

#pragma mark - Setup

- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self customizeSearchBar:self.searchController.searchBar];
    self.navigationItem.titleView = self.searchController.searchBar;
    //    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)customizeSearchBar:(UISearchBar *)searchBar {
    // 修改搜索文本框的对齐方式
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.backgroundColor = FEColorFromHex(0xFAFAFA);
    }
    
    // 设置搜索栏背景色为灰色
    searchBar.barTintColor = UIColor.whiteColor;
    searchBar.backgroundImage = [UIImage imageWithColor:UIColor.whiteColor];
}

- (void)setCancelButtonTitle:(NSString *)title inSearchBar:(UISearchBar *)searchBar {
    // 这种方式可能不直接修改取消按钮标题，但它是安全的做法
    for (UIView *subview in searchBar.subviews) {
        for (UIView *innerSubview in subview.subviews) {
            if ([innerSubview isKindOfClass:[UIButton class]]) {
                UIButton *cancelButton = (UIButton *)innerSubview;
                [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - Data Handling

- (void)handleCountryData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CountryCode" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error;
    NSArray *countries = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"Failed to parse JSON: %@", error.localizedDescription);
        return;
    }
    
    NSMutableDictionary *groupedCountries = [NSMutableDictionary dictionaryWithDictionary:[self fetchHotCountries]];
    for (NSDictionary *country in countries) {
        NSString *firstLetter = [[country[@"english_name"] substringToIndex:1] uppercaseString];
        if (!groupedCountries[firstLetter]) {
            groupedCountries[firstLetter] = [NSMutableArray array];
        }
        [groupedCountries[firstLetter] addObject:country];
    }
    
    self.groupedCountriesDic = groupedCountries;
    self.sectionTitles = [[groupedCountries allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isEqualToString:@"热门"]) {
            return NSOrderedAscending;
        } else if ([obj2 isEqualToString:@"热门"]) {
            return NSOrderedDescending;
        } else {
            return [obj1 compare:obj2];
        }
    }];
}

- (NSDictionary *)fetchHotCountries {
    return @{@"热门" : @[
        @{
            @"english_name": @"China",
            @"chinese_name": @"中国",
            @"country_code": @"CN",
            @"phone_code": @"86"
        },
        @{
            @"english_name": @"Hong Kong",
            @"chinese_name": @"中国香港",
            @"country_code": @"HK",
            @"phone_code": @"852"
        },
        @{
            @"english_name": @"Macau",
            @"chinese_name": @"中国澳门",
            @"country_code": @"MO",
            @"phone_code": @"853"
        },
        @{
            @"english_name": @"Taiwan",
            @"chinese_name": @"中国台湾",
            @"country_code": @"TW",
            @"phone_code": @"886"
        }
    ]};
}

- (NSDictionary *)countryDataForIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.isActive) {
        return self.filteredDataArray[indexPath.row];
    } else {
        NSString *sectionKey = self.sectionTitles[indexPath.section];
        return self.groupedCountriesDic[sectionKey][indexPath.row];
    }
}

#pragma mark - UISearchResultsUpdating && UISearchBarDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMin;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    NSString *searchText = searchController.searchBar.text;
//    [self.filteredDataArray removeAllObjects];
//    if (searchText.length) {
//        // 创建谓词进行搜索
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chinese_name CONTAINS[cd] %@", searchText];
//        // 直接在分组字典的值上应用谓词，而不是先合并数组
//        NSMutableArray *filteredCountries = [NSMutableArray array];
//        for (NSArray *countries in self.groupedCountriesDic.allValues) {
//            [filteredCountries addObjectsFromArray:[countries filteredArrayUsingPredicate:predicate]];
//        }
//        self.filteredDataArray = filteredCountries;
//    }
//    [self.tableView reloadData];
    
    NSString *searchText = searchController.searchBar.text;
    [self.filteredDataArray removeAllObjects];
    
    if (searchText.length > 0) {
        // 创建谓词进行搜索
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chinese_name CONTAINS[cd] %@", searchText];
        for (NSArray *countries in self.groupedCountriesDic.allValues) {
            [self.filteredDataArray addObjectsFromArray:[countries filteredArrayUsingPredicate:predicate]];
        }
    }
    [self.tableView reloadData];
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self.filteredDataArray removeAllObjects];
//    self.searchController.active = NO;
//    [self.searchController.searchBar resignFirstResponder];
//    self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMin;
//    [self.tableView reloadData];
//}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchController.isActive ? 1 : self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return self.filteredDataArray.count;
    } else {
        NSString *sectionKey = self.sectionTitles[section];
        return [self.groupedCountriesDic[sectionKey] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FECountryCell *cell = [tableView dequeueReusableCellWithIdentifier:[FECountryCell reuseIdentifier] forIndexPath:indexPath];
    NSDictionary *cellData = [self countryDataForIndexPath:indexPath];
    [cell setupContentWith:cellData[@"chinese_name"] code:cellData[@"phone_code"]];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.searchController.isActive ? nil : self.sectionTitles[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.searchController.active ? 0.01 : 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedCountry = [self countryDataForIndexPath:indexPath];
    NSString *countryName = [selectedCountry[@"chinese_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *countryCode = [selectedCountry[@"phone_code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedCountryCode:countryName:)]) {
        [self.delegate selectedCountryCode:countryCode countryName:countryName];
    }
    
    if (self.countryBlock) {
        self.countryBlock(countryCode, countryName);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DZNEmptyDataSetSource && DZNEmptyDataSetDelegate

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 1.0;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -FESafeTopHeight + 20;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return self.filteredDataArray ? [UIImage imageNamed:@"common_empty_icon"] : nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无国家区号~";
    NSDictionary *attributes = @{NSFontAttributeName: FEMediumFontOfSize(12),
                                 NSForegroundColorAttributeName: FEColorFromHexAndAlpha(0xffffff, 0.5)};
    return self.filteredDataArray ? [[NSAttributedString alloc] initWithString:text attributes:attributes] : nil;
}

#pragma mark - Lazy Initializers

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[FECountryCell class] forCellReuseIdentifier:[FECountryCell reuseIdentifier]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.rowHeight = 44;
        
        // 设置右边字母索引栏隐藏
        _tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMin;
        // 设置右边字母索引的颜色
        _tableView.sectionIndexColor = FEColorFromHex(0x76442e); // 你可以设置你想要的颜色
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor]; // 索引栏的背景颜色
    }
    return _tableView;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.obscuresBackgroundDuringPresentation = NO;
        _searchController.searchBar.placeholder = @"搜索";
        _searchController.hidesNavigationBarDuringPresentation = NO;
        self.definesPresentationContext = YES;
    }
    return _searchController;
}

- (NSMutableArray *)filteredDataArray {
    if (!_filteredDataArray) {
        _filteredDataArray = [NSMutableArray array];
    }
    return _filteredDataArray;
}

@end


@end

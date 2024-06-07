//
//  KTCountryTableViewCell.m
//  KTCountryCode
//
//  Created by Lit on 2024/6/7.
//

#import "KTCountryTableViewCell.h"

@interface KTCountryTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UIView *seperatorLine;

@end

@implementation KTCountryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Custom Events

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)setupSubviews {
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(20);
        make.width.equalTo(@126);
        make.height.equalTo(@20);
    }];
    [self.contentView addSubview:self.codeLabel];
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-10);
        make.width.equalTo(@100);
        make.height.equalTo(@20);
    }];
    [self.contentView addSubview:self.seperatorLine];
    [self.seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel.mas_leading);
        make.trailing.equalTo(self.codeLabel.mas_trailing);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setupContentWith:(NSString *)title code:(NSString *)code {
    self.titleLabel.text = title;
    self.codeLabel.text = [@"+" stringByAppendingString:code];
}

#pragma mark - Property Setter/Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FEHeavyFontOfSize(14);
        _titleLabel.textColor = FEColorFromHexAndAlpha(0x21130d, 0.7);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] init];
        _codeLabel.font = FEHeavyFontOfSize(12);
        _codeLabel.textColor = FEColorFromHexAndAlpha(0x21130d, 0.7);
        _codeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _codeLabel;
}

- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = FEColorFromHex(0xFAFAFA);
    }
    return _seperatorLine;
}

@end


#import "Three20/TTStyleSheet.h"

@class TTShape;

@interface TTDefaultStyleSheet : TTStyleSheet

@property(nonatomic,readonly) UIColor* textColor;
@property(nonatomic,readonly) UIColor* highlightedTextColor;
@property(nonatomic,readonly) UIColor* placeholderTextColor;
@property(nonatomic,readonly) UIColor* linkTextColor;
@property(nonatomic,readonly) UIColor* moreLinkTextColor;
@property(nonatomic,readonly) UIColor* photoCaptionTextColor;

@property(nonatomic,readonly) UIColor* navigationBarTintColor;
@property(nonatomic,readonly) UIColor* toolbarTintColor;
@property(nonatomic,readonly) UIColor* searchBarTintColor;
@property(nonatomic,readonly) UIColor* screenBackgroundColor;
@property(nonatomic,readonly) UIColor* backgroundColor;

@property(nonatomic,readonly) UIColor* tableActivityTextColor;
@property(nonatomic,readonly) UIColor* tableErrorTextColor;
@property(nonatomic,readonly) UIColor* tableSubTextColor;
@property(nonatomic,readonly) UIColor* tableTitleTextColor;
@property(nonatomic,readonly) UIColor* tableHeaderTextColor;
@property(nonatomic,readonly) UIColor* tableHeaderShadowColor;
@property(nonatomic,readonly) UIColor* tableHeaderTintColor;
@property(nonatomic,readonly) UIColor* tableSeparatorColor;
@property(nonatomic,readonly) UIColor* tableBackgroundColor;
@property(nonatomic,readonly) UIColor* searchTableBackgroundColor;
@property(nonatomic,readonly) UIColor* searchTableSeparatorColor;

@property(nonatomic,readonly) UIColor* tabTintColor;
@property(nonatomic,readonly) UIColor* tabBarTintColor;

@property(nonatomic,readonly) UIColor* messageFieldTextColor;
@property(nonatomic,readonly) UIColor* messageFieldSeparatorColor;

@property(nonatomic,readonly) UIColor* thumbnailBackgroundColor;

@property(nonatomic,readonly) UIFont* font;
@property(nonatomic,readonly) UIFont* buttonFont;
@property(nonatomic,readonly) UIFont* tableFont;
@property(nonatomic,readonly) UIFont* tableSmallFont;
@property(nonatomic,readonly) UIFont* tableTitleFont;
@property(nonatomic,readonly) UIFont* tableButtonFont;
@property(nonatomic,readonly) UIFont* tableSummaryFont;
@property(nonatomic,readonly) UIFont* photoCaptionFont;
@property(nonatomic,readonly) UIFont* messageFont;
@property(nonatomic,readonly) UIFont* errorTitleFont;
@property(nonatomic,readonly) UIFont* errorSubtitleFont;
@property(nonatomic,readonly) UIFont* activityLabelFont;

- (TTStyle*)toolbarButtonForState:(UIControlState)state shape:(TTShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font;

- (TTStyle*)selectionFillStyle:(TTStyle*)next;

@end

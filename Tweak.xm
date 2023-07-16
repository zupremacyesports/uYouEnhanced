#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

NSBundle *uYouLocalizationBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"uYouLocalization" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS("/Library/Application Support/uYouLocalization.bundle")];
    });
    return bundle;
}

static inline NSString *LOC(NSString *key) {
    NSBundle *tweakBundle = uYouLocalizationBundle();
    return [tweakBundle localizedStringForKey:key value:nil table:nil];
}

@interface PKYStepper : UIControl
@end

// Fit speed controllers localized 'Normal' text into frame
%hook PKYStepper
- (void)layoutSubviews {
    %orig;

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.5;
        }
    }
}
%end

// Replace (translate) old text to the new one
%hook UILabel
- (void)setText:(NSString *)text {
    NSBundle *tweakBundle = uYouLocalizationBundle();
    NSString *localizedText = [tweakBundle localizedStringForKey:text value:nil table:nil];

    if (localizedText && ![localizedText isEqualToString:text]) {
        %orig(localizedText);
        self.adjustsFontSizeToFitWidth = YES;
    } else {
        %orig;
    }
}
%end

// Replace (translate) old text to the new one and extend its frame
%hook UIButton
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    NSBundle *tweakBundle = uYouLocalizationBundle();
    NSString *localizedText = [tweakBundle localizedStringForKey:title value:nil table:nil];
    NSString *newTitle = localizedText ?: title;

    if (![newTitle isEqualToString:title]) {
        CGSize size = [newTitle sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
        CGRect frame = self.frame;
        frame.size.width = size.width + 16.0;
        self.frame = frame;
    } %orig(newTitle, state);
}
%end

// Replace (translate) only a certain part of the text 
%group gAdditionalHook
%hook UILabel
- (void)setText:(NSString *)text {
    %orig;
    if ([text containsString:@"TOTAL ("]) {
        %orig([NSString stringWithFormat:@"%@ %@", LOC(@"TOTAL"), [text substringFromIndex:[text rangeOfString:@"("].location]]);
    }
    if ([text containsString:@"DOWNLOADING ("]) {
        %orig([NSString stringWithFormat:@"%@ %@", LOC(@"DOWNLOADING"), [text substringFromIndex:[text rangeOfString:@"("].location]]);
    }
    if ([text containsString:@"Selected files: ("]) {
        %orig([NSString stringWithFormat:@"%@: %@", LOC(@"SelectedFilesCount"), [text substringFromIndex:[text rangeOfString:@"("].location]]);
    }
    if ([text containsString:@"Are you sure you want to delete \""]) {
        %orig([NSString stringWithFormat:@"%@ %@", LOC(@"DeleteVideo"), [text substringFromIndex:[text rangeOfString:@"\""].location]]);
    }
    if ([text containsString:@"Video •"]) {
        %orig([NSString stringWithFormat:@"%@ %@", LOC(@"Video"), [text substringFromIndex:[text rangeOfString:@"•"].location]]);
    }
    if ([text containsString:@"Completed :"]) {
        %orig([NSString stringWithFormat:@"%@ %@", LOC(@"Completed"), [text substringFromIndex:[text rangeOfString:@":"].location]]);
    }
    if ([text containsString:@"Are you sure you want to delete ("]) {
        NSRange parenthesesRange = [text rangeOfString:@"("];
        NSRange suffixRange = [text rangeOfString:@")" options:NSBackwardsSearch range:NSMakeRange(parenthesesRange.location, text.length - parenthesesRange.location)];
        if (suffixRange.location != NSNotFound) {
            NSString *textInsideParentheses = [text substringWithRange:NSMakeRange(parenthesesRange.location + 1, text.length - parenthesesRange.location - 2)];
            NSString *newPrefix = LOC(@"DeleteFilesCount");
            NSString *newString = [NSString stringWithFormat:@"%@\n%@: %@", newPrefix, LOC(@"SelectedFilesCount"), textInsideParentheses];
            newString = [newString stringByReplacingOccurrencesOfString:@") files" withString:@""];
            newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            %orig(newString);
            return;
        }
    }
}
%end
%end

%ctor {
    %init;
    %init(gAdditionalHook);
}
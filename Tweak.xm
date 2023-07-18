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

// Fit speed controllers localized 'Normal' text into frame
%hook PKYStepper
- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        UILabel *countLabel = [self valueForKey:@"countLabel"];
        countLabel.adjustsFontSizeToFitWidth = YES;
    } return self;
}
%end

// Replace (translate) old text to the new one
%hook UILabel
- (void)setText:(NSString *)text {
    NSBundle *tweakBundle = uYouLocalizationBundle();
    NSString *localizedText = [tweakBundle localizedStringForKey:text value:nil table:nil];
    NSArray *centered = @[@"SKIP", @"DISMISS", @"UPDATE NOW", @"DON'T SHOW"];

    %orig;
    if (localizedText && ![localizedText isEqualToString:text]) {
        %orig(localizedText);
        self.adjustsFontSizeToFitWidth = YES;
    }
    
    // Make non-attributed buttons text centered
    if ([centered containsObject:text]) {
        self.textAlignment = NSTextAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
    }

    // Replace (translate) only a certain part of the text 
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

// Replace (translate) old text to the new one in Navbars
%hook FRPreferences
- (void)setTitle:(NSString *)title {
    NSBundle *tweakBundle = uYouLocalizationBundle();
    NSString *localizedText = [tweakBundle localizedStringForKey:title value:nil table:nil];

    if (localizedText && ![localizedText isEqualToString:title]) {
        %orig(localizedText);
    } else {
        %orig(title);
    }
}
%end

// Continue button (mostly for notched devices)
%hook uYouWelcome
- (void)setButtonTitle:(id)arg1 {
    %orig(arg1 = LOC(@"Continue"));
}
%end

// Follow me on twitter
%hook OBPrivacyLinkButton
- (id)initWithCaption:(id)arg1 buttonText:(id)arg2 image:(id)arg3 imageSize:(CGSize)arg4 useLargeIcon:(BOOL)arg5 {
    return %orig(LOC(@"FollowMe"), arg2, arg3, arg4, arg5);
}
%end

// Reorder Tabs title
%hook settingsReorderTable
- (id)initWithTitle:(id)arg1 items:(id)arg2 defaultValues:(id)arg3 key:(id)arg4 header:(id)arg5 footer:(id)arg6 {
    return %orig(LOC(@"ReorderTabs"), arg2, arg3, arg4, arg5, arg6);
}
%end

// Translate Donation cell
%hook UserButtonCell
- (id)initWithLabel:(id)arg1 account:(id)arg2 imageName:(id)arg3 logo:(id)arg4 roll:(id)arg5 color:(id)arg6 bundlePath:(id)arg7 avatarBackground:(BOOL)arg8 {
    if ([arg2 containsString:@"developments by"]) {
        arg2 = [arg2 stringByReplacingOccurrencesOfString:@"developments by" withString:LOC(@"Developments")];
    } return %orig(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
}
%end

// Translate update messages
%hook uYouCheckUpdate
- (id)initWithTweakName:(id)arg1 tweakID:(id)arg2 version:(id)arg3 message:(id)arg4 tintColor:(id)arg5 showAllButtons:(BOOL)arg6 {
    if ([arg4 containsString:@"which it\'s the latest version."]) {
        NSString *version = arg3;
        arg4 = [NSString stringWithFormat:LOC(@"UpToDate"), version];
    }
    
    else if ([arg4 containsString:@"is now available."]) {
        NSRange oldVerion = [arg4 rangeOfString:@" is now available."];
        NSString *version = [arg4 substringToIndex:oldVerion.location];
        arg4 = [NSString stringWithFormat:LOC(@"NewVersion"), version];
    } return %orig(arg1, arg2, arg3, arg4, arg5, arg6);
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

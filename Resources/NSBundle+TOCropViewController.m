//
//  NSBundle+TOCropViewController.m
//  TOCropViewControllerExample
//
//  Created by MrChenMj on 2017/12/14.
//  Copyright © 2017年 Tim Oliver. All rights reserved.
//

#import "NSBundle+TOCropViewController.h"
#import "TOCropToolbar.h"
@implementation NSBundle (TOCropViewController)
+ (instancetype)mj_cropBundle
{
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        refreshBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[TOCropToolbar class]] pathForResource:@"TOCropViewController" ofType:@"bundle"]];
    }
    return refreshBundle;
}
+ (NSString *)mj_localizedStringForKey:(NSString *)key
{
    return [self mj_localizedStringForKey:key value:nil];
}

+ (NSString *)mj_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else {
            language = @"en";
        }
        // 从TOCropViewController.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle mj_cropBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:@"TOCropViewControllerLocalizable"];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
@end

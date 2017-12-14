//
//  NSBundle+TOCropViewController.h
//  TOCropViewControllerExample
//
//  Created by MrChenMj on 2017/12/14.
//  Copyright © 2017年 Tim Oliver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (TOCropViewController)
+ (instancetype)mj_cropBundle;
+ (NSString *)mj_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)mj_localizedStringForKey:(NSString *)key;
@end

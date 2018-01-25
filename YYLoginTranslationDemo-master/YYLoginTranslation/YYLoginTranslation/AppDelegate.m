//
//  AppDelegate.m
//  YYLoginTranslation
//
//  Created by yy on 2017/7/31.
//  Copyright © 2017年 yy. All rights reserved.
//

#import "AppDelegate.h"
#import "YYLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    YYLoginViewController *login = [[YYLoginViewController alloc] init];
    
    self.window.rootViewController = login;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end

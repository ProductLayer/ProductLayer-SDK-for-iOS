//
//  AppDelegate.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "AppDelegate.h"
#import "DTLog.h"
#import "ProductLayer.h"
#import "ProductLayerConfig.h"
#import "PLYSidePanelProtocol.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	DTLogSetLogLevel(DTLogLevelDebug);
	
	// sets the API key to be used by this app for authenticating with PL
#ifdef PLY_API_KEY
	[[PLYServer sharedServer] setAPIKey:PLY_API_KEY];
#endif
    
    if([_window.rootViewController isKindOfClass:[DTSidePanelController class]]){
        ((DTSidePanelController *) _window.rootViewController).sidePanelDelegate = self;
    }
	
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)sidePanelController:(DTSidePanelController *)sidePanelController shouldAllowClosingOfSidePanel:(DTSidePanelControllerPanel)sidePanel{
    
    UINavigationController *navController;
    
    if (sidePanel == DTSidePanelControllerPanelRight) {
        navController = (UINavigationController *)sidePanelController.rightPanelController;
	} else if (sidePanel == DTSidePanelControllerPanelCenter) {
        navController = (UINavigationController *)sidePanelController.centerPanelController;
    } else if (sidePanel == DTSidePanelControllerPanelLeft) {
        navController = (UINavigationController *)sidePanelController.leftPanelController;
    }
    
    if(navController) {
        UIViewController *viewController = [[navController viewControllers] objectAtIndex:0];
        
        if ( [viewController respondsToSelector:@selector(allowClosing)] ) {
            return (BOOL)[viewController performSelector:@selector(allowClosing)];
        }
    }
    
	return YES;
}

@end

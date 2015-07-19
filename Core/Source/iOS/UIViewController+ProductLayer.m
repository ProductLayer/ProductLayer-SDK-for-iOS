//
//  UIViewController+ProductLayer.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "UIViewController+ProductLayer.h"
#import "ProductLayerSDK.h"
#import <objc/runtime.h>


static char PLYViewControllerServerKey;

@implementation UIViewController (ProductLayer)

#pragma mark - Properties

- (void)setProductLayerServer:(PLYServer *)server
{
	objc_setAssociatedObject(self, &PLYViewControllerServerKey, server, OBJC_ASSOCIATION_RETAIN);
}

- (PLYServer *)productLayerServer
{
	PLYServer *server = objc_getAssociatedObject(self, &PLYViewControllerServerKey);
	
	if (server)
	{
		return server;
	}
	
	return [PLYServer sharedServer];
}

@end

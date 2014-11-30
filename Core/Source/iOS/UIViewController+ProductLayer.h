//
//  UIViewController+ProductLayer.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

@class PLYServer;

/**
 Category adding common stuff to be used by UIViewControllers
 */
@interface UIViewController (ProductLayer)

/**
 Server to use for requests. If not set the shared server will be used.
 */
@property (nonatomic, strong) PLYServer *productLayerServer;

@end

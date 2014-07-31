//
//  PLYViewController.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

@class PLYServer;

/**
 Base view controller with common features for the Sign Up and Login view controllers
 */
@interface PLYViewController : UIViewController

/**
 Server to use for requests. If not set the shared server will be used.
 */
@property (nonatomic, strong) PLYServer *server;

@end

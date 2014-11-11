//
//  PLYTableViewController.h
//  PL
//
//  Created by Oliver Drobnik on 11/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYServer;

@interface PLYTableViewController : UITableViewController

/**
 Server to use for requests. If not set the shared server will be used.
 */
@property (nonatomic, strong) PLYServer *server;

@end

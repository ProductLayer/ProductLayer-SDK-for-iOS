//
//  PLYReportProblemViewController.h
//  ProdlyApp
//
//  Created by Oliver Drobnik on 23.01.15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

@class PLYEntity;

/**
 A view controller for reporting an issue with a PLYEntity
 */

@interface PLYReportProblemViewController : UIViewController

/**
 Action to send the current report if valid
 */
- (IBAction)sendReport:(id)sender;

/**
 Action to cancel the report composition
 */
- (IBAction)cancel:(id)sender;


/**
 The entity to report an issue with
 */
@property (nonatomic, copy) PLYEntity *problematicEntity;

@end

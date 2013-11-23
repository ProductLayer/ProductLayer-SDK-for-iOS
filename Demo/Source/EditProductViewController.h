//
//  EditProductViewController.h
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"

@interface EditProductViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *productNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *vendorTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *gtinTextField;

@property (nonatomic, strong) PLYServer *server;


- (IBAction)save:(id)sender;

@property (nonatomic, copy) NSString *gtin;

@end

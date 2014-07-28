//
//  KeyValueTableViewController.m
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "KeyValueTableViewController.h"
#import "KeyValueTableViewCell.h"
#import "ProductLayer.h"

@interface KeyValueTableViewController ()

@end

@implementation KeyValueTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setElements:(NSDictionary *)elements{
    _elements = elements;

    _groupedElements = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for(NSString *key in _elements.allKeys){
        NSArray *splittedKey = [key componentsSeparatedByString:@"-"];
        
        NSString *groupKey = @"default";
        
        if([splittedKey count] > 4) {
            groupKey = [NSString stringWithFormat:@"%@-%@-%@-%@",splittedKey[0],splittedKey[1],splittedKey[2],splittedKey[3]];
        }
        
        NSMutableArray *group = [_groupedElements objectForKey:groupKey];
        
        if(!group){
            group = [NSMutableArray arrayWithCapacity:1];
        }
        
        NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", [_elements objectForKey:key], @"value", nil];
        [group addObject:tmp];
        
        [_groupedElements setObject:group forKey:groupKey];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_groupedElements count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_groupedElements objectForKey:[[_groupedElements allKeys] objectAtIndex:section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KeyValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KeyValueTableCell" forIndexPath:indexPath];
    
    NSDictionary *dict = [((NSArray *)[_groupedElements objectForKey:[[_groupedElements allKeys] objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.row];
    
    [cell.value setText:[dict objectForKey:@"value"]];
    [cell.key setText:PLYLocalizedStringFromTable([dict objectForKey:@"key"], @"API", @"")];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_groupedElements allKeys][section];
}

@end

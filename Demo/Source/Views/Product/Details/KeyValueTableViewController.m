//
//  KeyValueTableViewController.m
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "KeyValueTableViewController.h"
#import "KeyValueTableViewCell.h"

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [cell.key setText:NSLocalizedString([dict objectForKey:@"key"],@"")];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_groupedElements allKeys][section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

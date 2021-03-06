//
//  BookmarksViewController.m
//  Bookmarkme
//
//  Created by Michael Blum on 7/2/13.
//  Copyright (c) 2013 Tyler Maher. All rights reserved.
//

#import "BookmarksViewController.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bookmarks = [NSMutableArray arrayWithArray:[[self populate] allValues]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendBookmark) name:@"SendBookmark" object:nil];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(setEditMode:)];
}

//- (void)setEditMode:(UIBarButtonItem *)sender {
//    if (self.editing) {
//        sender.title = @"Edit";
//        [super setEditing:NO animated:YES];
//    } else {
//        sender.title = @"Done";
//        [super setEditing:YES animated:YES];
//    }
//    NSLog(@"Editing: %@", self.editing ? @"YES" : @"NO");
//}

-(NSDictionary*)populate
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:@"data"]];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    
    NSError *error;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(data != nil){
        NSDictionary *jsonDir = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        [fileHandler closeFile];
        
        return jsonDir;
    }else
        return nil;
}

/*
 This method takes a dictionary of values and writes them to a file as parsable JSON text
 */
-(BOOL)persist:(NSDictionary*)info
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:@"data"]];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //build an info object and convert to json
    [fileHandler readDataToEndOfFile];
    //convert object to data
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:path options:NSDataWritingAtomic error:&error];
    [fileHandler closeFile];
    return true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}
//sets up table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bookmarks count];
}

//make cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    [cell.textLabel setText:[self.bookmarks objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* markedForRemoval = [self.bookmarks objectAtIndex:indexPath.row];
    [self.bookmarks removeObjectAtIndex:indexPath.row];
    
    //remove from datastore
    NSMutableDictionary* fromStore = [[NSMutableDictionary alloc] initWithDictionary:[self populate]];
    [fromStore removeObjectForKey:markedForRemoval];
    [self persist:fromStore];
    [tableView reloadData];
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
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate
//this method fires when you tap a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* selectedBookmark = [self.bookmarks objectAtIndex:indexPath.row];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadBookmark" object:self userInfo:[NSDictionary dictionaryWithObject:selectedBookmark forKey:@"bookmark"]];
//    BMViewController* root = [self.navigationController.viewControllers objectAtIndex:0];
//    [root goAddress:selectedBookmark];
//    NSArray* viewControllers = self.navigationController.viewControllers;
//    
//    [root.addressBar setText:selectedBookmark];
//    [root goAddress];
    

        
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)sendBookmark
{
    
}

@end

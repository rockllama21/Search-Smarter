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
    self.bookmarks = [[self populate] allValues];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendBookmark) name:@"SendBookmark" object:nil];
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%d", [self.bookmarks count]);
    return [self.bookmarks count];
}


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

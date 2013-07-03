//
//  ViewController.m
//  Bookmarkme
//
//  Created by iD Student on 7/1/13.
//  Copyright (c) 2013 Tyler Maher. All rights reserved.
//

#import "BMViewController.h"
#import "AFJSONRequestOperation.h"

@interface BMViewController ()

@end

@implementation BMViewController

@synthesize webView, addressBar, optionsViewController;

- (void)viewDidLoade
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *address =@"http://www.google.com";
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    [addressBar setText:address];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //here's a directory of JSON we got from the URL above
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                              [JSON valueForKeyPath:@"origin"],
                              @"where", nil];
        [self persist:info];
        NSLog(@"%@", [self populate]);
    } failure:nil];
    
    [operation start];

    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Search Smarter"]; 
    [self.navigationController.navigationBar setBarStyle: UIBarStyleBlack];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    UIBarButtonItem *bookmarksButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(switchToBookmarksListView:)];
    self.navigationItem.rightBarButtonItem = bookmarksButton;
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:.094 green:.176 blue:.874 alpha:1]];
}
-(void)switchToBookmarksListView:(id)sender
{
    self.optionsViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.optionsViewController.title=@"Bookmarks";
    [self.navigationController pushViewController:self.optionsViewController animated:YES];
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSLog(@"touch: %f %f", touchPoint.x, touchPoint.y);
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSLog(@"touch moved: %f %f", touchPoint.x, touchPoint.y);
}

-(IBAction)goAddress:(id)sender{
    NSURL *url =[NSURL URLWithString:[addressBar text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [addressBar resignFirstResponder];
}

- (IBAction)addBookmark:(id)sender {
//    UIAlertView *alert =[[UIAlertView alloc]initWithTitle: @"Great!" message:@"Are you sure you want to save this web page to your Bookmarks?"delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    [alert show];
    NSArray* bookmarkStore = [self populate];
    //step 1: lets get the URL
    NSString* address = [addressBar text];
    NSDictionary* newEntry = @{address: address};
    NSMutableDictionary* newDic = [[NSMutableDictionary alloc] init];
    int indexKey = 0;
    if(bookmarkStore != nil){
        for(NSDictionary* dicEntry in bookmarkStore){
            NSString* key = [NSString stringWithFormat:@"%@", [NSNumber numberWithUnsignedInt:indexKey++]];
            [newDic setObject:dicEntry forKey:key];
        }
    }
    NSString* key = [NSString stringWithFormat:@"%@", [NSNumber numberWithUnsignedInt:indexKey++]];
    [newDic setObject:newEntry forKey:key];
    [self persist:newDic];
    NSLog(@"%@", newDic);
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSDictionary* dictionaryEntry = [NSDictionary dictionaryWithObject:[addressBar text] forKey:[addressBar text]];
        [self persist:dictionaryEntry];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        NSURL *url =[request URL];
        if([[url scheme] isEqualToString:@"http"]){
            [addressBar setText:[url absoluteString]];
            [self goAddress:nil];
        }
        return NO;
    }
    return YES;
}
-(NSArray*)populate
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:@"data"]];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    
    NSError *error;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(data != nil){
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        [fileHandler closeFile];
        
        return jsonArray;
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

@end

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

@synthesize webView, addressBar, bookmarksViewController;

- (void)viewDidLoad
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
    self.bookmarksViewController = [[BookmarksViewController alloc] initWithNibName:@"BookmarksViewController" bundle:nil];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.bookmarksViewController.title=@"Bookmarks";
    [self.navigationController pushViewController:self.bookmarksViewController animated:YES];
//    [self.bookmarksViewController view];
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
    NSString* http = [NSString stringWithFormat:@"%@", [addressBar text]];
    NSURL *url;
    if([http rangeOfString:@"http://"].location == NSNotFound ||
       [http rangeOfString:@"https://"].location == NSNotFound){
        //prepend http
        NSString* httpURL = [NSString stringWithFormat:@"http://%@", http];
        http = httpURL;
        NSLog(@"%@", http);
    }
    url =[NSURL URLWithString:http];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [addressBar resignFirstResponder];
}

- (IBAction)addBookmark:(id)sender {
//    UIAlertView *alert =[[UIAlertView alloc]initWithTitle: @"Great!" message:@"Are you sure you want to save this web page to your Bookmarks?"delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    [alert show];
    NSString* address = [addressBar text];
    //check for http://
    
    NSDictionary* persistedData = [self populate];
    if(persistedData == nil){
        persistedData = @{address: address};
        [self persist:persistedData];
    }else{
        NSMutableDictionary* appenedData = [[NSMutableDictionary alloc] initWithDictionary:persistedData];
        [appenedData setObject:address forKey:address];
        [self persist:appenedData];
    }
    NSLog(@"%@", [self populate]);
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
        [addressBar setText:[url absoluteString]];
        [self goAddress:nil];
        return NO;
    }
    return YES;
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

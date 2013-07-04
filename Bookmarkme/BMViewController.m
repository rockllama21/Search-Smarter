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
    NSString* url = @"www.google.com";
    [addressBar setText:url];
    [self goAddress];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBookmark:) name:@"loadBookmark" object:nil];
}

//nav bar and buttons
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Search Smarter"]; 
    [self.navigationController.navigationBar setBarStyle: UIBarStyleBlack];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(switchToBookmarksListView:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBookmark:)];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:.094 green:.176 blue:.874 alpha:1]];
}
//switches to bookmarks
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self goAddress];
    [textField resignFirstResponder];
    return NO;
}
//method to go to the website
-(void)goAddress:(NSString*) newURL{
    NSString* http = [NSString stringWithFormat:@"%@", newURL];
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
//make it the text field go to the web
-(IBAction)goAddress{
    [self.addressBar resignFirstResponder];
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
//adds bookmark
- (void)addBookmark:(id)sender {

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

    UIAlertView *alert =[[UIAlertView alloc]initWithTitle: @"Added to bookmarks" message:@"This page has been added to your bookmarks." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
//displays the UIWebView
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        NSURL *url =[request URL];
        [addressBar setText:[url absoluteString]];
        [self goAddress];
        return NO;
    }
    return YES;
}
//loads bookmarks when clicked
-(void)loadBookmark:(NSNotification *)notification {
    NSString *bookmark = [[notification userInfo] objectForKey:@"bookmark"];
    self.addressBar.text = bookmark;
    [self goAddress];
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

//
//  ViewController.m
//  Bookmarkme
//
//  Created by iD Student on 7/1/13.
//  Copyright (c) 2013 Tyler Maher. All rights reserved.
//

#import "BMViewController.h"

@interface BMViewController ()

@end

@implementation BMViewController

@synthesize webView, addressBar, optionsViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *address =@"http://www.google.com";
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    [addressBar setText:address];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Search Smarter"];
    [self.navigationController.navigationBar setBarStyle: UIBarStyleBlack];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    UIBarButtonItem *optionsButton =
    [[UIBarButtonItem alloc]
     initWithTitle:@"Bookmarks"
     style: UIBarButtonItemStylePlain
     target:self action:@selector(switchToBookmarksListView:)];
    self.navigationItem.rightBarButtonItem = optionsButton;
}
-(IBAction)switchToBookmarksListView:(id)sender
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

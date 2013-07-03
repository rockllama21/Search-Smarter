//
//  ViewController.h
//  Bookmarkme
//
//  Created by iD Student on 7/1/13.
//  Copyright (c) 2013 Tyler Maher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksViewController.h"
#import "AppDelegate.h"

@interface BMViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UIWebView *webView;
@property(nonatomic,strong) IBOutlet UITextField *addressBar;

@property (nonatomic, strong) BookmarksViewController* bookmarksViewController;

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
-(IBAction)goAddress;
-(void)goAddress:(NSString*) newURL;
- (IBAction)addBookmark:(id)sender;
-(NSDictionary*)populate;
-(BOOL)persist:(NSDictionary*)info;

@end

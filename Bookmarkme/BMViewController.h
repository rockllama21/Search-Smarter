//
//  ViewController.h
//  Bookmarkme
//
//  Created by iD Student on 7/1/13.
//  Copyright (c) 2013 Tyler Maher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic, strong) IBOutlet UIWebView *webView;
@property(nonatomic,strong) IBOutlet UITextField *addressBar;
@property (strong, nonatomic) UIViewController* optionsViewController;

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
-(IBAction)goAddress:(id)sender;
- (IBAction)addBookmark:(id)sender;

@end

//
//  BookmarksViewController.h
//  Bookmarkme
//
//  Created by Michael Blum on 7/2/13.
//  Copyright (c) 2013 Tyler Maher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSArray* bookmarks;

@end

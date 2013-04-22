//
//  FirstViewController.m
//  wp-ios
//
//  Created by andika on 4/22/13.
//  Copyright (c) 2013 SAI. All rights reserved.
//

#import "FirstViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "ApiUrl.h"
#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>



@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Latest", @"Latest");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.latest = [[NSArray alloc] init];
         
        [self.indicator startAnimating];
        
        NSURL *url = [NSURL URLWithString:LatestURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
              NSLog(@"App.net Global Stream: %@", JSON);
            self.latest= [JSON objectForKey:@"posts"];
            [self.tableView reloadData];
            
           [self.indicator stopAnimating];
             [self.tableView setHidden:NO];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        }];
        [operation start];
            }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setHidden:YES];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.latest && self.latest.count) {
        NSLog(@"%d",self.latest.count);
        return self.latest.count;
    } else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
   
    NSDictionary *data = [self.latest objectAtIndex:indexPath.row];
    cell.textLabel.text =[self flattenHTML:[data objectForKey:@"title_plain"]];
  
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   NSDictionary *data = [self.latest objectAtIndex:indexPath.row];
    DetailViewController *detail = [[DetailViewController alloc] initWitData:data];
       //[detail.detail loadHTMLString:[data objectForKey:@"content"] baseURL:nil];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
   // self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController pushViewController:detail animated:NO];
    
   // [self.navigationController popViewControllerAnimated:NO];
      
      
   // self.navigationController.navigationBar.backItem.title = @"Back";

}
- (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}



@end
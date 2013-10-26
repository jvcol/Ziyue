//
//  ZYViewController.m
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "ZYViewController.h"
#import "ZYCourseListViewController.h"

@interface ZYViewController () <NSURLConnectionDelegate>

@end

@implementation ZYViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"go" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:button];
    
    
}

- (void)go {
    ZYCourseListViewController * vc = [[ZYCourseListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

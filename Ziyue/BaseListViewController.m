//
//  BaseListViewController.m
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "BaseListViewController.h"
#import "NetModel.h"

@interface BaseListViewController ()  {
    UIActivityIndicatorView * _indicatorView;
}
@end

@implementation BaseListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_dataArray removeAllObjects];
    _myTableView = nil;
    _netModel.delegate = nil;
    _netModel = nil;
    _indicatorView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _netModel = [[NetModel alloc] init];
    _netModel.delegate = self;
    
    _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_myTableView];
    _myTableView.hidden = YES;
    
    _dataArray = [[NSMutableArray alloc] init];

    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_indicatorView];
    _indicatorView.hidesWhenStopped = YES;
    _indicatorView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [_indicatorView startAnimating];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    PrintSelfInfo;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _netModel.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _netModel.delegate = nil;
}

- (void)endLoadData {
    [_indicatorView stopAnimating];
    _myTableView.hidden = NO;
    [_myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

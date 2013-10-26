//
//  ZYCourseListViewController.m
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "ZYCourseListViewController.h"
#import "NetModel.h"
#import "ZYCourseDetailViewController.h"

@interface ZYCourseListViewController () <UITableViewDataSource,UITableViewDelegate> {
    UITableView * _mytableView;
    NSMutableArray * _dataArray;
    NetModel * _netModel;
}

@end

@implementation ZYCourseListViewController

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
    
    _netModel = [[NetModel alloc] init];
    _netModel.delegate = self;

    _mytableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _mytableView.backgroundColor = [UIColor clearColor];
    _mytableView.delegate = self;
    _mytableView.dataSource = self;
    [self.view addSubview:_mytableView];
    
    _dataArray = [[NSMutableArray alloc] init];
        
    [self loadData];
}

- (void)loadData {
    ASIHTTPRequest * request = [_netModel beginGetRequest:Request_Url_GetCoursesList];
    [_netModel endRequest:request];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    PrintSelfInfo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
    }
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
//    NSLog(@"%@",dic);
    cell.textLabel.text = [dic objectForKey:@"author"];
    cell.detailTextLabel.text = [dic objectForKey:@"desc"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _dataArray.count) {
        NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
        ZYCourseDetailViewController * vc = [[ZYCourseDetailViewController alloc] init];
        vc.courseId = [[dic objectForKey:@"_id"] integerValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark net delegate
- (void)apiSuccessedWithDictionary:(NSDictionary *)dic ForApi:(NSString *)api {
    NSArray * array = [[dic objectForKey:@"data"] objectForKey:@"items"];

    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:array];
    [_mytableView reloadData];
}

- (void)apiFailed:(NSDictionary *)dic WithMsg:(NSString *)msg {
    NSLog(@"erro : %@",msg);
}


#pragma mark ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
}

@end

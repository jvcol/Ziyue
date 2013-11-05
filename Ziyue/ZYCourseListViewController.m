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
#import "UIImageView+WebCache.h"
#import "ZYDownloadListViewController.h"

@interface ZYCourseListViewController ()

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
    self.title = @"课程列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"我的下载" style:UIBarButtonItemStylePlain target:self action:@selector(downloadcenter)];

    [self loadData];
}

- (void)downloadcenter {
    ZYDownloadListViewController * vc = [[ZYDownloadListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
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
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 60, 80)];
        imageView.tag = 100;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, self.view.frame.size.width-100, 35)];
        titleLabel.numberOfLines = 2;
        [cell.contentView addSubview:titleLabel];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.tag = 101;
        
        UILabel * authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, self.view.frame.size.width-100, 15)];
        authorLabel.font = [UIFont systemFontOfSize:13];
        authorLabel.tag = 102;
        [cell.contentView addSubview:authorLabel];
        
        UILabel * categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 55, self.view.frame.size.width-100, 15)];
        categoryLabel.font = FONT(13);
        [cell.contentView addSubview:categoryLabel];
        categoryLabel.tag = 103;
        
        UILabel * durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 70, self.view.frame.size.width-100, 15)];
        durationLabel.font = FONT(13);
        [cell.contentView addSubview:durationLabel];
        durationLabel.tag = 104;
        
    }
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
    
    UIImageView * imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    if (imageView) {
        [imageView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"cover"]]];
    }
    
    UILabel * label = (UILabel *)[cell.contentView viewWithTag:101];
    if (label) {
        label.text = [dic objectForKey:@"title_ch"];
    }
    
    label = (UILabel *)[cell.contentView viewWithTag:102];
    if (label) {
        label.text = [NSString stringWithFormat:@"作者：%@",[dic objectForKey:@"author"]];
    }
    
    label = (UILabel *)[cell.contentView viewWithTag:103];
    if (label) {
        label.text = [NSString stringWithFormat:@"分类：%@",[dic objectForKey:@"subject"]];
    }

    label = (UILabel *)[cell.contentView viewWithTag:104];
    if (label) {
        label.text = [NSString stringWithFormat:@"点击：%d",[[dic objectForKey:@"hits"] intValue]]; //getTimeStr([[dic objectForKey:@"duration"] intValue])
    }


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
    [self endLoadData];
}

- (void)apiFailed:(NSDictionary *)dic WithMsg:(NSString *)msg {
    NSLog(@"erro : %@",msg);
}


@end

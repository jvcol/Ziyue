//
//  ZYDownloadingListViewController.m
//  Ziyue
//
//  Created by yangw on 13-10-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "ZYDownloadingListViewController.h"
#import "Utility.h"
#import "ZYDataCenter.h"

@interface ZYDownloadingListViewController ()

@end

@implementation ZYDownloadingListViewController

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
    self.title = @"正在下载...";
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData:(NSNotification *)notification {
    
    [_dataArray removeAllObjects];
    
    
    for (int ii=0; ii<[[ZYDataCenter instance] downloadCourses].count; ii++) {
        NSDictionary * coursedic = [[[ZYDataCenter instance] downloadCourses] objectAtIndex:ii];
        NSInteger courseid = [[coursedic objectForKey:@"_id"] integerValue];
        
        NSMutableArray * chapters = [NSMutableArray array];
        for (NSDictionary * cpdic in [[ZYDataCenter instance] downloadChapters]) {
            DownloadState state = (DownloadState)[[cpdic objectForKey:@"downloadState"] intValue];
            if ([[cpdic objectForKey:@"course_id"] integerValue] == courseid && state != DownloadState_Complete) {
                [chapters addObject:cpdic];
            }
        }
        if (chapters.count > 0) {
            NSMutableDictionary * mdic = [NSMutableDictionary dictionaryWithDictionary:coursedic];
            [mdic setObject:chapters forKey:@"chapters"];
            [_dataArray addObject:mdic];
        }
    }
    
    [self endLoadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(tableView.frame)/2-10, 15)];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.tag = 101;
        [cell.contentView addSubview:titleLabel];
        titleLabel = nil;
        
        UILabel * sizelabel = [[UILabel alloc] initWithFrame:CGRectMake(10+CGRectGetWidth(tableView.frame)/2, 25, CGRectGetWidth(tableView.frame)/2-10, 15)];
        sizelabel.font = [UIFont systemFontOfSize:13];
        sizelabel.tag = 102;
        sizelabel.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:sizelabel];
        sizelabel = nil;
        
        UIProgressView * progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 20, 280, 10)];
        progress.progressViewStyle = UIProgressViewStyleBar;
        progress.tag = 103;
        [cell.contentView addSubview:progress];
        progress = nil;
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 104;
        button.frame = CGRectMake(0, 0, 40, 40);
        button.center = CGPointMake(270, 25);
        [button addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor redColor];
        [button setTitle:@"播放" forState:UIControlStateNormal];
        button.titleLabel.font = FONT(14);
        [cell.contentView addSubview:button];
        button = nil;
        
    }
    NSDictionary * dic = [[[_dataArray objectAtIndex:indexPath.section-1] objectForKey:@"chapters"] objectAtIndex:indexPath.row];
    
    UILabel * label = (UILabel *)[cell.contentView viewWithTag:101];
    if (label) {
        label.text = [dic objectForKey:@"title"];
    }
    
    long long dsize = [[dic objectForKey:@"downloadSize"] longLongValue];
    long long tsize = [[dic objectForKey:@"totalSize"] longLongValue];
    
    label = (UILabel *)[cell.contentView viewWithTag:102];
    if (label) {
        NSString * dsizes = bytesToString(dsize);
        NSString * tsizes = bytesToString(tsize);
        label.text = [NSString stringWithFormat:@"%@/%@",dsizes,tsizes];
    }
    
    UIProgressView * progress = (UIProgressView *)[cell.contentView viewWithTag:103];
    if (progress) {
        [progress setProgress:dsize/tsize animated:YES];
    }
    
    return cell;
}

- (void)playButtonPressed:(UIButton *)button {
    UITableViewCell * cell = (UITableViewCell *)[[button superview] superview];
    if (iOS7) {
        cell = (UITableViewCell *)cell.superview;
    }
    NSIndexPath * indexPath = [_myTableView indexPathForCell:cell];
    NSDictionary * dic = [[[_dataArray objectAtIndex:indexPath.section-1] objectForKey:@"chapters"] objectAtIndex:indexPath.row];

}

@end

//
//  ZYDownloadListViewController.m
//  Ziyue
//
//  Created by yangw on 13-10-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "ZYDownloadListViewController.h"
#import "ZYDataCenter.h"
#import "UIImageView+WebCache.h"
#import "VedioViewController.h"
#import "ZYDownloadingListViewController.h"

@interface ZYDownloadListViewController () {
    
}

@end

@implementation ZYDownloadListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initial {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:K_Download_Notification_UpdateData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:K_Download_Notification_Finished object:nil];
    [self updateData:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"已下载";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下载中" style:UIBarButtonItemStylePlain target:self action:@selector(downloadingVC)];
    
    [self initial];
}

- (void)downloadingVC {
    ZYDownloadingListViewController * vc = [[ZYDownloadingListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
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
            if ([[cpdic objectForKey:@"course_id"] integerValue] == courseid && state == DownloadState_Complete) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count+1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == _dataArray.count) {
        return nil;
    }
    NSDictionary * dic = [_dataArray objectAtIndex:section];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100-1)];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 60, 80)];
    imageView.tag = 100;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"cover"]]];
    [view addSubview:imageView];
    imageView = nil;
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, self.view.frame.size.width-100, 35)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.tag = 101;
    titleLabel.text = [dic objectForKey:@"title_ch"];
    [view addSubview:titleLabel];
    titleLabel = nil;
    
    
    UILabel * authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, self.view.frame.size.width-100, 15)];
    authorLabel.font = [UIFont systemFontOfSize:13];
    authorLabel.tag = 102;
    authorLabel.text = [NSString stringWithFormat:@"作者：%@",[dic objectForKey:@"author"]];
    [view addSubview:authorLabel];
    authorLabel = nil;
    
    UILabel * categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 55, self.view.frame.size.width-100, 15)];
    categoryLabel.tag = 103;
    categoryLabel.font = FONT(13);
    categoryLabel.text = [NSString stringWithFormat:@"分类：%@",[dic objectForKey:@"subject"]];
    [view addSubview:categoryLabel];
    categoryLabel = nil;
    
    UILabel * durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 70, self.view.frame.size.width-100, 15)];
    durationLabel.font = FONT(13);
    durationLabel.text = [NSString stringWithFormat:@"点击：%d",[[dic objectForKey:@"hits"] intValue]];
    durationLabel.tag = 104;
    [view addSubview:durationLabel];
    durationLabel = nil;
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == _dataArray.count)
        return 0;
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    NSDictionary * dic = [_dataArray objectAtIndex:section-1];
    NSArray * array = [dic objectForKey:@"chapters"];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 0;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 170, 20)];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.tag = 101;
        [cell.contentView addSubview:titleLabel];
        titleLabel = nil;
        
        UILabel * sizelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, 170, 15)];
        sizelabel.font = [UIFont systemFontOfSize:13];
        sizelabel.tag = 102;
        [cell.contentView addSubview:sizelabel];
        sizelabel = nil;
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 104;
        button.frame = CGRectMake(0, 0, 40, 40);
        button.center = CGPointMake(280, 25);
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
    
    label = (UILabel *)[cell.contentView viewWithTag:102];
    if (label) {
        NSString * tsize = bytesToString([[dic objectForKey:@"totalSize"] longLongValue]);
        label.text = tsize;
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
    
    NSString * url = [dic objectForKey:@"file_url"];
    
    NSString * str = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    str = [str stringByAppendingPathComponent:DownloadFilePath];
    NSString * path = [str stringByAppendingPathComponent:[url md5]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        path = [path stringByAppendingPathExtension:@"mp4"];
        VedioViewController * playerViewController = [[VedioViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
        playerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        MPMoviePlayerController *player = [playerViewController moviePlayer];
        player.repeatMode = MPMovieRepeatModeOne;
        [player setContentURL:[NSURL fileURLWithPath:path]];
        player.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
        [player play];
    }

}

@end

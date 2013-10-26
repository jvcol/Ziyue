//
//  ZYCourseDetailViewController.m
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "ZYCourseDetailViewController.h"
#import "NetModel.h"
#import "VedioViewController.h"

@interface ZYCourseDetailViewController () <NetModelDelegate> {
    
    UILabel * _despLabel;
    
    NSMutableArray * _courseArray;
    
    VedioViewController * playerViewController;
}

@end

@implementation ZYCourseDetailViewController

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
    
    _courseArray = [[NSMutableArray alloc] init];
    
    _despLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    _despLabel.textColor = [UIColor blackColor];
    _despLabel.numberOfLines = 0;
    _despLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_despLabel];
    
    _myTableView.tableHeaderView = _despLabel;
    
    NSString * str = [NSString stringWithFormat:@"%@_id=%ld",Request_Url_GetCourseInfo,self.courseId];
    ASIHTTPRequest * request = [_netModel beginGetRequest:str];
    [_netModel endRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIndentifier];
    }
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"title"];
    cell.detailTextLabel.text = [dic objectForKey:@"filename"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _dataArray.count) {
        NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
        NSString * url = [dic objectForKey:@"file_url"];
        
        playerViewController = [[VedioViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[playerViewController moviePlayer]];
        playerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:playerViewController animated:YES];
        MPMoviePlayerController *player = [playerViewController moviePlayer];
        [player play];

    }
}

- (void) playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    MPMoviePlayerController *player = [theNotification object];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
        [player stop];
    [playerViewController dismissModalViewControllerAnimated:YES];
}

- (void)apiSuccessedWithDictionary:(NSDictionary *)dictionary ForApi:(NSString *)api {
    NSDictionary * dic = [[dictionary objectForKey:@"data"] objectForKey:@"course"];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[dic objectForKey:@"author"] message:[dic objectForKey:@"title_ch"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    
    NSLog(@"course : %@",dic);
    
    _despLabel.text = [dic objectForKey:@"desc"];
    [_despLabel sizeToFit];
    _myTableView.tableHeaderView = _despLabel;
    
    NSMutableArray * chapters = [[dictionary objectForKey:@"data"] objectForKey:@"chapters"];
    NSLog(@"%@",chapters);
    if (![chapters isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    for (int ii=0; ii<chapters.count; ii++) {
        NSDictionary * item = [chapters objectAtIndex:ii];
        if ([[item objectForKey:@"level"] intValue] == 2) {
            [_dataArray addObject:item];
        }
    }
    [_myTableView reloadData];
}

- (void)apiFailed:(NSDictionary *)dictionary WithMsg:(NSString *)msg {
    
}

@end

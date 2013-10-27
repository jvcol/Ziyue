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
    
    NSInteger _currentSelectedIndex;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
    }
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"title"];
    cell.detailTextLabel.text = [dic objectForKey:@"filename"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentSelectedIndex = indexPath.row;
    [self play:YES];

}

- (NSString *)nextUrl {
    _currentSelectedIndex ++;
    if (_currentSelectedIndex < _dataArray.count) {
        NSDictionary * dic = [_dataArray objectAtIndex:_currentSelectedIndex];
        NSString * url = [dic objectForKey:@"file_url"];
        return url;
    }
    return nil;
}

- (void)play:(BOOL)animated {
    if (_currentSelectedIndex < _dataArray.count) {
        NSDictionary * dic = [_dataArray objectAtIndex:_currentSelectedIndex];
        NSString * url = [dic objectForKey:@"file_url"];
        if (url && url.length > 0) {
            VedioViewController * playerViewController = [[VedioViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
            playerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            MPMoviePlayerController *player = [playerViewController moviePlayer];
            player.repeatMode = MPMovieRepeatModeOne;
            [player setContentURL:[NSURL URLWithString:url]];
            [self presentModalViewController:playerViewController animated:animated];
            [player play];
        }
    }
}

- (void) playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    NSNumber * reason = [[theNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackFinished. Reason: Playback Ended");
//            [self play:NO];
            break;
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"playbackFinished. Reason: Playback Error");
            break;
        case MPMovieFinishReasonUserExited:
        {
            NSLog(@"playbackFinished. Reason: User Exited");
        }
            break;
        default:
            break;
    }
    
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
    [self endLoadData];
}

- (void)apiFailed:(NSDictionary *)dictionary WithMsg:(NSString *)msg {
    
}

@end

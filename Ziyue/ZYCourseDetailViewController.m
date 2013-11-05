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
#import "UIImageView+WebCache.h"
#import "ZYDataCenter.h"

@interface ZYCourseDetailViewController () <NetModelDelegate> {
    
    NSInteger _currentSelectedIndex;
    
    int type;
    
    BOOL _isEditingModel;
    NSMutableArray * _selected2Download;
    
}
@property (nonatomic, retain) NSMutableDictionary * courseInfoDic;

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

- (void)setUpTopView {
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    topView.backgroundColor = [UIColor clearColor];
    _myTableView.tableHeaderView = topView;
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 60, 80)];
    imageView.tag = 100;
    [topView addSubview:imageView];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 15, self.view.frame.size.width-100-55, 40)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.tag = 101;
    [topView addSubview:titleLabel];

    UILabel * historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 65, self.view.frame.size.width-155, 15)];
    historyLabel.font = FONT(13);
    [topView addSubview:historyLabel];
    historyLabel.tag = 102;
    
    UIButton * despButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [despButton setTitle:@"简介" forState:UIControlStateNormal];
    despButton.titleLabel.font = FONT(15);
    [topView addSubview:despButton];
    despButton.tag = 1;
    [despButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    despButton.frame = CGRectMake(30, 100, 100, 30);
    [despButton addTarget:self action:@selector(topButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listButton setTitle:@"课程" forState:UIControlStateNormal];
    listButton.titleLabel.font = FONT(15);
    [topView addSubview:listButton];
    listButton.tag = 0;
    [listButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    listButton.frame = CGRectMake(190, 100, 100, 30);
    [listButton addTarget:self action:@selector(topButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)refreshTopViewWithData {
    UIImageView * imageView = (UIImageView *)[_myTableView.tableHeaderView viewWithTag:100];
    if (imageView) {
        [imageView setImageWithURL:[NSURL URLWithString:[self.courseInfoDic objectForKey:@"cover"]]];
    }
    UILabel * label = (UILabel *)[_myTableView.tableHeaderView viewWithTag:101];
    if (label) {
        label.text = [self.courseInfoDic objectForKey:@"title_ch"];
    }
    label = (UILabel *)[_myTableView.tableHeaderView viewWithTag:102];
    if (label) {
        label.text = [NSString stringWithFormat:@"看到："];
    }
}

- (void)topButtonPressed:(UIButton *)button {
    int tag = button.tag;
    type = tag;
    [_myTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"课程详情";
    
    _myTableView.backgroundColor = RGB3(240);
    [self setUpTopView];
    
    NSString * str = [NSString stringWithFormat:@"%@_id=%d",Request_Url_GetCourseInfo,self.courseId];
    ASIHTTPRequest * request = [_netModel beginGetRequest:str];
    [_netModel endRequest:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)downLoad {
    if (type == 1) {
        return;
    }
    _isEditingModel = !_isEditingModel;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_isEditingModel ? @"完成": @"下载" style:UIBarButtonItemStylePlain target:self action:@selector(downLoad)];
    [_myTableView reloadData];
    
    if (!_isEditingModel && _selected2Download.count > 0) {
        // down load
        NSMutableArray * array = [NSMutableArray array];
        for (int ii=0; ii<_selected2Download.count; ii++) {
            [array addObject:[_dataArray objectAtIndex:[[_selected2Download objectAtIndex:ii] intValue]]];
        }
        [[ZYDataCenter instance] downLoadCourse:self.courseInfoDic chapters:array];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (type == 1) {
        NSString * str = [self.courseInfoDic objectForKey:@"desc"];
        CGSize size = [str sizeWithFont:FONT(15) constrainedToSize:CGSizeMake(260, 9999)];
        if (size.height < 15) {
            size.height = 15;
        }
        return 70+size.height;
    }
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (type == 1) {
        return 1;
    }
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForDespRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"despcell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel * lable1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 40, 20)];
        lable1.font = FONT(13);
        lable1.tag = 100;
        lable1.text = @"类型：";
        lable1.textColor = [UIColor redColor];
        [cell.contentView addSubview:lable1];
        
        UILabel * lable2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 20)];
        lable2.font = FONT(13);
        lable2.tag = 200;
        lable2.text = @"讲师：";
        lable2.textColor = [UIColor redColor];
        [cell.contentView addSubview:lable2];

        UILabel * lable3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, 40, 20)];
        lable3.font = FONT(13);
        lable3.tag = 300;
        lable3.text = @"简介：";
        lable3.textColor = [UIColor redColor];
        [cell.contentView addSubview:lable3];

        UILabel * lable4 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lable1.frame), CGRectGetMinY(lable1.frame), 260, 15)];
        lable4.font = FONT(15);
        lable4.tag = 101;
        [cell.contentView addSubview:lable4];
        
        UILabel * lable5 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lable2.frame), CGRectGetMinY(lable2.frame), 260, 15)];
        lable5.font = FONT(15);
        lable5.tag = 201;
        [cell.contentView addSubview:lable5];

        UILabel * lable6 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lable3.frame), CGRectGetMinY(lable3.frame), 260, 15)];
        lable6.font = FONT(15);
        lable6.tag = 301;
        lable6.numberOfLines = 0;
        [cell.contentView addSubview:lable6];

    }
    
    UILabel * label = (UILabel *)[cell.contentView viewWithTag:101];
    if (label) {
        label.text = [self.courseInfoDic objectForKey:@"subject"];
    }

    label = (UILabel *)[cell.contentView viewWithTag:201];
    if (label) {
        label.text = [self.courseInfoDic objectForKey:@"author"];
    }
    
    label = (UILabel *)[cell.contentView viewWithTag:301];
    if (label) {
        label.text = [self.courseInfoDic objectForKey:@"desc"];
        CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(260, 9999)];
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 260, size.height);
    }
    
    return cell;
    
}

- (void)downLoadButtonPressed:(UIButton *)button {
    UITableViewCell * cell = (UITableViewCell *)[[button superview] superview];
    if (iOS7) {
        cell = (UITableViewCell *)cell.superview;
    }
    int index = [_myTableView indexPathForCell:cell].row;
    if (index < _dataArray.count) {
        if (_selected2Download == nil) {
            _selected2Download = [[NSMutableArray alloc] init];
        }
        NSNumber * num = [NSNumber numberWithInt:index];
        if ([_selected2Download containsObject:num]) {
            [_selected2Download removeObject:num];
        }else {
            [_selected2Download addObject:num];
        }
        [_myTableView reloadRowsAtIndexPaths:[_myTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (type == 1) {
        return [self tableView:tableView cellForDespRowAtIndexPath:indexPath];
    }
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 33)];
        button.backgroundColor = [UIColor redColor];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        button.center = CGPointMake(self.view.frame.size.width-50, 35);
        [cell.contentView addSubview:button];
        button.tag = 100;
        [button addTarget:self action:@selector(downLoadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)-90, 60, 90, 15)];
        label.tag = 101;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"已下载";
        [cell.contentView addSubview:label];
        label.hidden = YES;
        label = nil;
        
    }
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[第%d课]   时长:%@",indexPath.row+1,[dic objectForKey:@"dur"]];
    
    BOOL hasDownload = [[ZYDataCenter instance] hasDownloadedWithChapterId:[dic intValue:@"_id"]];
    
    UIButton * button = (UIButton *)[cell.contentView viewWithTag:100];
    if (button && [button isKindOfClass:[UIButton class]]) {
        [cell.contentView bringSubviewToFront:button];
        button.hidden = (!_isEditingModel || hasDownload);
        
        if (_selected2Download && [_selected2Download containsObject:[NSNumber numberWithInt:indexPath.row]]) {
            [button setTitle:@"已选" forState:UIControlStateNormal];
            [button setTitleColor:RGB3(240) forState:UIControlStateNormal];
        }else {
            [button setTitle:@"选择" forState:UIControlStateNormal];
            [button setTitleColor:RGB3(255) forState:UIControlStateNormal];
        }
    }
    
    UILabel * label = (UILabel *)[cell.contentView viewWithTag:101];
    if (label) {
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (type == 0) {
        _currentSelectedIndex = indexPath.row;
        [self play:YES];
    }

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
            MPMoviePlayerController *player = [playerViewController moviePlayer];
            player.repeatMode = MPMovieRepeatModeOne;
            [player setContentURL:[NSURL URLWithString:url]];
            [self presentMoviePlayerViewControllerAnimated:playerViewController];
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
    
    self.courseInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self refreshTopViewWithData];
    
    NSMutableArray * chapters = [[dictionary objectForKey:@"data"] objectForKey:@"chapters"];
    if (![chapters isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    for (int ii=0; ii<chapters.count; ii++) {
        NSMutableDictionary * item = [chapters objectAtIndex:ii];
        if ([[item objectForKey:@"level"] intValue] == 2) {
            [_dataArray addObject:item];
        }
    }
    [self.courseInfoDic setObject:[NSNumber numberWithInt:_dataArray.count] forKey:@"chaptnum"];
    [self endLoadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStylePlain target:self action:@selector(downLoad)];

}

- (void)apiFailed:(NSDictionary *)dictionary WithMsg:(NSString *)msg {
    
}

@end

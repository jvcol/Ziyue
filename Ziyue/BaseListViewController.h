//
//  BaseListViewController.h
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "BaseViewController.h"
#import "NetModel.h"

@interface BaseListViewController : BaseViewController <UITableViewDataSource,UITableViewDelegate> {
    NetModel * _netModel;
    UITableView * _myTableView;
    NSMutableArray * _dataArray;

}

- (void)endLoadData;


@end

//
//  ViewController.h
//  Search
//
//  Created by Tang Hana on 2017/1/22.
//  Copyright © 2017年 Tang Hana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    UITextField*  keyWord;
    NSDictionary* dic;
    UITextField*  Page;
    int page; //current page
    int total; //total page
    UIButton* pageUpBtn;
    UIButton* pageDownBtn;
    UITableView* tableView;
    
    UILabel* notice;
}


@end

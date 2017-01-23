//
//  ViewController.m
//  Search
//
//  Created by Tang Hana on 2017/1/22.
//  Copyright © 2017年 Tang Hana. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //enter keywords, show the result include owner and repo’s name
    
    //[dic objectForKey:@"portrait"]!=nil
    
    UILabel*title =[[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 20)];
    title.text=@"Github Repositories Search";
    title.textColor=[UIColor blackColor];
    title.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    
    /*keyword*/
    keyWord = [[UITextField alloc] initWithFrame:CGRectMake(20,80,self.view.frame.size.width-100,50)];
    keyWord.placeholder = @"please enter keyword...";
    keyWord .layer.borderWidth = 1.0;
    keyWord .layer.borderColor = [UIColor lightGrayColor].CGColor;
    keyWord.layer.cornerRadius = 5.0;
    UILabel * leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,80,10,50)];
    leftView.backgroundColor = [UIColor clearColor];
    keyWord.leftViewMode=UITextFieldViewModeAlways;
    keyWord.leftView = leftView;
    
    [self.view addSubview:keyWord];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:keyWord];
    
    
    /*search button*/
    UIButton* searchBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70,80,60,50)];
    [searchBtn setTitle:@"search" forState:UIControlStateNormal];
    searchBtn .layer.borderWidth = 1.0;
    searchBtn .layer.borderColor = [UIColor lightGrayColor].CGColor;
    searchBtn .layer.cornerRadius = 5.0;
    [searchBtn  setTitleColor:[UIColor grayColor]  forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    /*page up button*/
    pageUpBtn=[[UIButton alloc]initWithFrame:CGRectMake(20,150,100,30)];
    [pageUpBtn setTitle:@"< Previous" forState:UIControlStateNormal];
    pageUpBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [pageUpBtn  setTitleColor:[UIColor grayColor]  forState:UIControlStateNormal];
    [pageUpBtn addTarget:self action:@selector(pageUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageUpBtn];
    pageUpBtn.hidden=YES;
    
    /*page down button*/
    pageDownBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-120,150,100,30)];
    [pageDownBtn setTitle:@"Next >" forState:UIControlStateNormal];
    pageDownBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [pageDownBtn  setTitleColor:[UIColor grayColor]  forState:UIControlStateNormal];
    [pageDownBtn addTarget:self action:@selector(pageDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageDownBtn];
    pageDownBtn.hidden=YES;
    
    /*go to page()*/
    Page = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25,150,50,30)];
    Page .layer.borderWidth = 1.0;
    Page .layer.borderColor = [UIColor lightGrayColor].CGColor;
    Page.layer.cornerRadius = 5.0;
    Page.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:Page];
    Page.hidden=YES;
    page=1;
    
    /*notice label"NO More"*/
    notice=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-50,200,100,30)];
    notice.text=@"No more...";
    notice.textColor=[UIColor grayColor];
    notice.textAlignment=NSTextAlignmentCenter;
}

/*real time searching*/
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSLog(@"%@",keyWord.text);
    page=1;
    [self search];
    
}


-(void)search{
    NSString* httpUrl=[NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@&page=%d&client_id=404dd6cdb4704832f881&client_secret=02a5725f1e7166a6ba132ad711edc57c5dfad13f",keyWord.text,page];
    //设置URL
    NSURL *url=[NSURL URLWithString:httpUrl];
    //创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    /* NSString *param= [@"token="stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];//设置参数
     NSData *data = [param dataUsingEncoding:NSUTF8StringEncoding];*/
    [request setHTTPBody:nil];
    //连接服务器
    NSError *error=nil;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *result= [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    //将其构造成一个字典再解析
    NSData* resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    dic = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
    if (error) {
        NSLog(@"错误信息:%@",[error localizedDescription]);
    }else{
        NSLog(@"返回结果:%@",result);
        NSNumber* n=[dic objectForKey:@"total_count"];
        total=n.intValue;
        /*add tableview - list the result*/
        [self list];
        /*no more*/
        if([[dic objectForKey:@"items"] count]==0)  {
            if(![keyWord.text isEqual:@""]) [self.view addSubview:notice];
            Page.hidden=YES;
            pageDownBtn.hidden=YES;
            pageUpBtn.hidden=YES;
        }
        else {
            Page.hidden=NO;
        }
    }
    
}

-(void) list{
    /*result list*/
    tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,200,self.view.frame.size.width,self.view.frame.size.height-200)];
    [tableView setSeparatorInset:UIEdgeInsetsZero]; //设置tableview 分割线从最左边开始
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    tableView.tableFooterView = [[UIView alloc] init]; //去除多余横线
    [self.view addSubview:tableView];
    
    Page.text=[NSString stringWithFormat:@"%d",page];
    /*page up&page down*/
    if(page==1) pageUpBtn.hidden=YES;
    else pageUpBtn.hidden=NO;
    if(page==(total+29)/30) pageDownBtn.hidden=YES;
    else pageDownBtn.hidden=NO;
    
}

-(void) pageUp{
    page--;
    [self search];
    NSLog(@"%d",page);
    
}

-(void) pageDown{
    page++;
    [self search];
    NSLog(@"%d",page);
}



/*section Row 的高度*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
/*section Header 的高度*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/*每个section的行数*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[dic objectForKey:@"items"] count]; //搜索结果的条数
}


//每个section显示的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 1.创建cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    // 2.设置数据
    cell.textLabel.text=[NSString stringWithFormat:@"%@/%@",[[[[dic objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"owner"] objectForKey:@"login"],[[[dic objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"name"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*tableView 点击监听*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //选中时颜色变化后自动回复
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*点击打开url连接*/
    NSURL *url = [ [ NSURL alloc ] initWithString: [[[dic objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"html_url"] ];
    [[UIApplication sharedApplication] openURL:url];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

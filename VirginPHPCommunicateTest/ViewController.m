//
//  ViewController.m
//  VirginPHPCommunicateTest
//
//  Created by llch on 15/5/27.
//  Copyright (c) 2015年 llch. All rights reserved.
//

#import "ViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AFNetworking/AFNetworking.h"

@interface ViewController ()

@property (strong, nonatomic)NSMutableArray * ChatViewArray;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *LeadingSpaceForTextFieldAndContainerView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *ScrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *BottomSpaceForTXAndContaierView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *VerticalSpace;
@property (weak, nonatomic) IBOutlet UITextField *InputTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottonSpaceBtTXAndScroll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ChatViewArray = [NSMutableArray arrayWithCapacity:0];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillappear) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWiilHide) name:UIKeyboardWillHideNotification object:nil];
    _ScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
}

- (void)keyBoardWillappear{
    [self.view removeConstraint:_BottomSpaceForTXAndContaierView];
    [_ScrollView addConstraint:_VerticalSpace];
    [_ScrollView addConstraint:_bottonSpaceBtTXAndScroll];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

- (void)keyBoardWiilHide{
    [self.view addConstraint:_BottomSpaceForTXAndContaierView];
    [_ScrollView removeConstraint:_VerticalSpace];
    [_ScrollView removeConstraint:_bottonSpaceBtTXAndScroll];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)picBtnCicked:(id)sender {
    AFHTTPRequestOperationManager * picManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    picManager.responseSerializer = [AFImageResponseSerializer serializer];
    [picManager GET:@"PoweredByMacOSXLarge.gif" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImageView * imageView = [[UIImageView alloc] initWithImage:responseObject];
        UIView * tempview = [_ChatViewArray lastObject];
        if (tempview) {
            imageView.frame = CGRectMake(0, CGRectGetMaxY(tempview.frame) + 20.0f, imageView.frame.size.width, imageView.frame.size.height);
        }else{
            imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
        }
        [_ScrollView addSubview:imageView];
        [_ChatViewArray addObject:imageView];
        
        if (CGRectGetMaxY(imageView.frame) >= CGRectGetMinY(_InputTextField.frame)) {
            if ([_ScrollView.constraints containsObject:_bottonSpaceBtTXAndScroll]) {
                [_ScrollView removeConstraint:_bottonSpaceBtTXAndScroll];
            }
            _ScrollView.contentSize = CGSizeMake(_ScrollView.contentSize.width, CGRectGetMaxY(imageView.frame) + _InputTextField.frame.size.height + 10.f);
            UIWindow * appWindow = [[UIApplication sharedApplication].windows lastObject];
            _ScrollView.contentOffset = CGPointMake(_ScrollView.contentOffset.x, _ScrollView.contentSize.height - appWindow.frame.size.height);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString * pureTextFieldStr = textField.text;
    NSString * textFieldStr = [@"我：" stringByAppendingString:textField.text];
    textField.text = @"";
    UILabel * label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor whiteColor];
    label.text = textFieldStr;
    [label sizeToFit];
    UIView * tempview = [_ChatViewArray lastObject];
    if (tempview) {
        label.frame = CGRectMake(0, CGRectGetMaxY(tempview.frame) + 20.0f, label.frame.size.width, label.frame.size.height);
    }else{
        label.frame = CGRectMake(0, 0, label.frame.size.width, label.frame.size.height);
    }
    [_ScrollView addSubview:label];
    [_ChatViewArray addObject:label];
    
    if (CGRectGetMaxY(label.frame) >= CGRectGetMinY(_InputTextField.frame)) {
        if ([_ScrollView.constraints containsObject:_bottonSpaceBtTXAndScroll]) {
            [_ScrollView removeConstraint:_bottonSpaceBtTXAndScroll];
        }
        _ScrollView.contentSize = CGSizeMake(_ScrollView.contentSize.width, CGRectGetMaxY(label.frame) + _InputTextField.frame.size.height + 10.f);
        UIWindow * appWindow = [[UIApplication sharedApplication].windows lastObject];
        _ScrollView.contentOffset = CGPointMake(_ScrollView.contentOffset.x, _ScrollView.contentSize.height - appWindow.frame.size.height);
    }
    
    AFHTTPRequestOperationManager * textRequestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    textRequestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSArray * strArray = [pureTextFieldStr componentsSeparatedByString:@","];
    int i = 0;
    NSMutableDictionary * paraDict = [NSMutableDictionary dictionary];
    for (NSString * tempStr in strArray) {
        [paraDict setValue:tempStr forKey:[@"query" stringByAppendingFormat:@"%d",i]];
        i++;
    }
    
    [textRequestManager GET:@"echo.php" parameters:paraDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * dict = responseObject;
        NSString *resutlStr = @"服务器：";
        for (NSString * str in [dict allKeys]) {
            resutlStr = [resutlStr stringByAppendingFormat:@"%@,",[dict objectForKey:str]];
        }
        UILabel * label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor whiteColor];
        label.text = resutlStr;
        [label sizeToFit];
        UIView * tempview = [_ChatViewArray lastObject];
        if (tempview) {
            label.frame = CGRectMake(0, CGRectGetMaxY(tempview.frame) + 20.0f, label.frame.size.width, label.frame.size.height);
        }else{
            label.frame = CGRectMake(0, 0, label.frame.size.width, label.frame.size.height);
        }
        [_ScrollView addSubview:label];
        [_ChatViewArray addObject:label];
        
        if (CGRectGetMaxY(label.frame) >= CGRectGetMinY(_InputTextField.frame)) {
            if ([_ScrollView.constraints containsObject:_bottonSpaceBtTXAndScroll]) {
                [_ScrollView removeConstraint:_bottonSpaceBtTXAndScroll];
            }
            _ScrollView.contentSize = CGSizeMake(_ScrollView.contentSize.width, CGRectGetMaxY(label.frame) + _InputTextField.frame.size.height + 10.f);
            UIWindow * appWindow = [[UIApplication sharedApplication].windows lastObject];
            _ScrollView.contentOffset = CGPointMake(_ScrollView.contentOffset.x, _ScrollView.contentSize.height - appWindow.frame.size.height);
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    return YES;
}

- (IBAction)LockBtnClicked:(id)sender {
    UIButton * lockBtn = sender;
    AFHTTPRequestOperationManager * LockManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    LockManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [LockManager GET:@"lock.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
}

@end

//
//  BackUpViewController.m
//  graduate
//
//  Created by luck-mac on 15/2/20.
//  Copyright (c) 2015年 nju.excalibur. All rights reserved.
//

#import "BackUpViewController.h"
#import "QuestionBook.h"
@interface BackUpViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIView *waveView;
@property (weak, nonatomic) IBOutlet UIButton *backUpButton;
@property (weak, nonatomic) IBOutlet UILabel *backUpingLabel;
@property(nonatomic)int total;
@property(nonatomic)int need;
@property (nonatomic,strong)NSTimer* timer;
@property (nonatomic)NSInteger count;
@end

@implementation BackUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_backUpingLabel setHidden:YES];
    _progressView.layer.cornerRadius = 109;
    [_progressView setClipsToBounds:YES];
    // Do any additional setup after loading the view.
    QuestionBook* book = [QuestionBook getInstance];
    [book calculateNeedUpload];
    NSArray* allQuestions = book.allQuestions;
    _total = 0;
    for (NSArray* array in allQuestions) {
        _total = _total + array.count;
    }
    _need = book.needUpload;
    int hasBackUp = _total-_need;
    [_progressLabel setText:[NSString stringWithFormat:@"您已备份%d份笔记，还有%d份未备份",hasBackUp,_need<=0?0:_need]];
    [self setProgress:_total hasBackUp:hasBackUp];
    self.backUpButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backUpButton.layer.borderWidth = 1;
    if (_need==0) {
        [self.backUpButton setTitle:@"完成备份" forState:UIControlStateNormal];
    } else {
         [self.backUpButton setTitle:@"开始备份" forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProgress) name:@"backup" object:nil];
    [self setTitle:@"备份"];
    [self addRightButton:@"设置" action:@selector(goToSetting) img:nil];
}

- (void) goToSetting
{
    [self performSegueWithIdentifier:@"setting" sender:nil];
}
- (void)updateProgress
{
    QuestionBook* book = [QuestionBook getInstance];
    _need = book.needUpload;
    int hasBackUp = _total-_need;
    [_progressLabel setText:[NSString stringWithFormat:@"您已备份%d份笔记，还有%d份未备份",hasBackUp,_need<=0?0:_need]];
    [self setProgress:_total hasBackUp:hasBackUp];
    
}

- (void)initViews
{
    if ([[UIScreen mainScreen]bounds].size.height<500) {
        self.scale = 0.75;
    }
    [super initViews];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar  setBackgroundImage:[[UIImage imageNamed:@"blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]   forBarMetrics:UIBarMetricsDefault];
}


- (void)setProgress:(int)total hasBackUp:(int)hasBackUp
{
    
    int percent = hasBackUp/(total+0.0)*100;
    if (total==0) {
        percent = 100;
    }
    NSString* progress = [_percentLabel.text componentsSeparatedByString:@"%"][0];
    NSUInteger progressInt = progress.integerValue;
    if (progressInt>=percent) {
        return;
    }
    [_percentLabel setText:[NSString stringWithFormat:@"%d%@",percent>=100?100:percent,@"%"]];
    CGFloat offSet;
    offSet = (total-hasBackUp)/(total+0.0)* _progressView.frame.size.width;
    _waveView.transform = CGAffineTransformMakeTranslation(0, offSet);
    if (total==hasBackUp) {
        [ToolUtils setIgnoreNetwork:NO];
        [_backUpingLabel setHidden:YES];
        [_backUpButton setHidden:NO];
        [_progressLabel setHidden:NO];
        [self.backUpButton setTitle:@"完成备份" forState:UIControlStateNormal];
    }
}

- (void)updateProgressLabel
{
    NSString* progress = [_percentLabel.text componentsSeparatedByString:@"%"][0];
    NSUInteger progressInt = progress.integerValue;
    if (progressInt>=99) {
        return;
    } else {
        progressInt++;
        [_percentLabel setText:[NSString stringWithFormat:@"%ld%@",progressInt,@"%"]];
        CGFloat offSet;
        offSet = (1-progressInt/100.0) * _progressView.frame.size.width;
        _waveView.transform = CGAffineTransformMakeTranslation(0, offSet);
        [self performSelector:@selector(updateProgressLabel) withObject:nil afterDelay:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [ToolUtils setIgnoreNetwork:NO];
}


- (IBAction)backUp:(id)sender {
    if (_need==0) {
        [self closeSelf];
    } else {
        _count = 0;
        [self updateLabel];
        [_backUpButton setHidden:YES];
        [_progressLabel setHidden:YES];
        [_backUpingLabel setHidden:NO];
        [ToolUtils setIgnoreNetwork:YES];
        [self performSelector:@selector(updateProgressLabel) withObject:nil afterDelay:2];
        [[QuestionBook getInstance]updateQuestions];
    }
}

- (void)updateLabel
{
    NSString* tip = @"正在为您备份，超压缩上传。一张图片只有几十K";
    _count++;
    for (int i = 0 ; i < _count%5 ; i++) {
        tip = [tip stringByAppendingString:@"."];
    }
    [self.backUpingLabel setText:tip];
    [self performSelector:@selector(updateLabel) withObject:nil afterDelay:1];
}

- (IBAction)goBack:(id)sender {
    if (!self.backUpingLabel.hidden) {
        [[[UIAlertView alloc]initWithTitle:@"放弃备份" message:@"您将要放弃备份，这可能使您的笔记不全而无法使用足迹打印等功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil] show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

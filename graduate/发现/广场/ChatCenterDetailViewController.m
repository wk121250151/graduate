//
//  ChatCenterDetailViewController.m
//  graduate
//
//  Created by luck-mac on 15/2/5.
//  Copyright (c) 2015年 nju.excalibur. All rights reserved.
//

#import "ChatCenterDetailViewController.h"
#import "MComments.h"
#import "MCommentList.h"
#import "MCommentPublish.h"
#import "MPostReport.h"
#import "MPostDetail.h"
#import "ChatCenterPostCell.h"
#import "UIPlaceHolderTextView.h"
@interface ChatCenterDetailViewController ()<UIActionSheetDelegate>
@property (nonatomic,strong)NSMutableArray* commentList;
@property (nonatomic,strong)UIView* editView;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (nonatomic,strong)UIPlaceHolderTextView* editTextView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@end

@implementation ChatCenterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"帖子详情"];
    self.commentList = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (self.replyNickname) {
        self.replyLabel.text = [NSString stringWithFormat:@"回复%@:",self.replyNickname];
    }
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(processShareSuccess) name:@"shareSuccess" object:nil];
    // Do any additional setup after loading the view.
}

- (void)initViews
{
    
}

- (IBAction)share:(id)sender {
    [self addMask];
    [self addMaskAtNavigation];
    [self.view bringSubviewToFront:_shareView];
    [UIView animateWithDuration:0.3 animations:^{
        _shareView.transform = CGAffineTransformMake(self.scale, 0, 0, self.scale, 0, -_shareView.frame.size.height);
    }];
    
}

- (void)addMask
{
    if (!self.maskView) {
        self.maskView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
        [self.maskView setAlpha:0.5];
        [self.maskView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:self.maskView];
    }
    [self.maskView setHidden:NO];
}

- (IBAction)cancelShare:(id)sender {
    [self hideShareView];
}

-(void)hideShareView
{
    [self removeMask];
    [self removeMaskAtNavigation];
    [UIView animateWithDuration:0.3 animations:^{
        _shareView.transform = CGAffineTransformMake(self.scale, 0, 0, self.scale, 0, 0);
    }];
}


- (IBAction)showMore:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}
- (void)loadData
{
    if (!self.post) {
        [[[MPostDetail alloc]init]load:self postid:self.postId];
    } else {
        self.postId = self.post.id_;
    }
    MComments* comments = [[MComments alloc]init];
    comments = (MComments*)[comments setPage:page limit:pageCount];
    [comments load:self postid:_postId];
}



- (void)dispos:(NSDictionary *)data functionName:(NSString *)names
{
    if ([names isEqualToString:@"MComments"]) {
        MCommentList* list = [MCommentList objectWithKeyValues:data];
        for (MComment* comment in list.comments_) {
            NSLog(@"______________%@",comment.id_);
            BOOL has = NO;
            for (MComment* currentComment in self.commentList) {
                if ([currentComment.id_ isEqualToString:comment.id_]) {
                    has = YES;
                    break;
                }
            }
            if (!has) {
                [self.commentList addObject:comment];
            }
        }
        
        if (page==1) {
            [self doneWithView:_header];
        } else {
            [self doneWithView:_footer];
        }
    } else if ([names isEqualToString:@"MCommentPublish"])
    {
        MComments* comments = [[MComments alloc]init];
        comments = (MComments*)[comments setPage:1 limit:self.commentList.count+1];
        [self.commentList removeAllObjects];
        [comments load:self postid:self.post.id_];
        
    } else if ([names isEqualToString:@"MPostDetail"])
    {
        MPost* post = [MPost objectWithKeyValues:data];
        self.post = post;
        [self doneWithView:_header];
    } else if ([names isEqualToString:@"MPostReport"])
    {
        [ToolUtils showToast:@"举报成功!" toView:self.view];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - actionsheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        MPostReport* report = [[MPostReport alloc]init];
        [report load:self pid:self.post.id_];
    }
}
#pragma mark - tableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if (self.post) {
            return 1;

        } else {
            return 0;
        }
    }
    return _commentList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return 5;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.commentList.count>0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 150+[ChatCenterPostCell getHeight:self.post.content_ hasConstraint:NO];
    } else if (indexPath.section==1)
    {
        MComment* comment = [self.commentList objectAtIndex:indexPath.row];
        return 80+[ChatCenterPostCell getHeight:comment.content_ hasConstraint:NO];
    }
    return 0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        ChatCenterPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"square" forIndexPath:indexPath];
        UIImage* placeHolder = [UIImage imageNamed:_post.sex_.integerValue ==0?@"默认男头像":@"默认女头像"];

        [cell.postAltasImageView sd_setImageWithURL:[ToolUtils getImageUrlWtihString:_post.headimg_ width:100 height:100] placeholderImage:placeHolder];
        [cell.postContextLabel setText:_post.content_];
        [cell.postNickNameLabel setText:_post.nickname_.length==0?@"   ":_post.nickname_];
        [cell.postIntervalLabel setText:_post.time_];
        [cell.postTitleLabel setText:_post.title_];
        [cell.postSexImageView setImage:[UIImage imageNamed:_post.sex_.integerValue==0?@"男生图标":@"广场女生图标" ]];
        return cell;
    } else if (indexPath.section==1){
        
        ChatCenterPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reply" forIndexPath:indexPath];
        MComment *comment = [self.commentList objectAtIndex:indexPath.row];
        UIImage* placeHolder = [UIImage imageNamed:comment.sex_.integerValue ==0?@"默认男头像":@"默认女头像"];
        [cell.postAltasImageView sd_setImageWithURL:[ToolUtils getImageUrlWtihString:comment.headimg_ width:100 height:100] placeholderImage:placeHolder];
        [cell.postContextLabel setText:comment.content_];
        [cell.postNickNameLabel setText:comment.nickname_.length==0?@"   ":comment.nickname_];
        [cell.postIntervalLabel setText:comment.time_];
        [cell.replyBt setTag:indexPath.row];
        [cell.postSexImageView setImage:[UIImage imageNamed:comment.sex_.integerValue==0?@"男生图标":@"广场女生图标" ]];
        return cell;
    }
    return nil;
}



- (IBAction)comment:(id)sender {
    
    [self editRemark:sender];
    
    
}



- (void)editRemark:(id)sender
{
    [self addMask];
    [self addMaskAtNavigation];
    if (!_editView) {
        CGRect frame = CGRectMake(0, SC_DEVICE_SIZE.height, SC_DEVICE_SIZE.width, 160);
        _editView = [[UIView alloc]initWithFrame:frame];
        _editView.backgroundColor = [UIColor whiteColor];
        [self.navigationController.view addSubview:_editView];
        CGRect textFrame = CGRectMake(0, 50, SC_DEVICE_SIZE.width, 110);
        
        _editTextView = [[UIPlaceHolderTextView alloc]initWithFrame:textFrame];
        _editTextView.layer.borderWidth = 1;
        _editTextView.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:0.5].CGColor;
        _editTextView.font = [UIFont fontWithName:@"FZLanTingHeiS-EL-GB" size:16];
        _editTextView.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        [_editView addSubview:_editTextView];
        CGRect leftBtFrame = CGRectMake(15, 5, 40, 40);
        UIButton* cancelButton = [[UIButton alloc]initWithFrame:leftBtFrame];
        [cancelButton addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor: [UIColor colorWithRed:31/255.0 green:118/255.0 blue:220/255.0 alpha:1] forState:UIControlStateNormal];
        [_editView addSubview:cancelButton];
        
        CGRect rightBtFrame = CGRectMake(SC_DEVICE_SIZE.width-55, 5, 40, 40);
        UIButton* saveButton = [[UIButton alloc]initWithFrame:rightBtFrame];
        [saveButton addTarget:self action:@selector(saveRemark) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor: [UIColor colorWithRed:31/255.0 green:118/255.0 blue:220/255.0 alpha:1] forState:UIControlStateNormal];
        [_editView addSubview:saveButton];
    }
    NSInteger tag = ((UIButton*)sender).tag;
    if (tag>=0) {
        MComment* comment = [self.commentList objectAtIndex:tag];
        _editTextView.text = [NSString stringWithFormat:@"回复%@:",comment.nickname_];
        self.selectFloor = comment.userid_;
    } else if (self.replyNickname){
        _editTextView.text = [NSString stringWithFormat:@"回复%@:",self.replyNickname];
        self.replyNickname = nil;
        [self.replyLabel setText:@""];
    } else {
        _editTextView.text = @"";
    }
    [_editTextView becomeFirstResponder];
}


- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    keyboardHeight = keyboardSize.height>=240?keyboardSize.height:240;
    [ToolUtils setKeyboardHeight:[NSNumber numberWithDouble:keyboardHeight]];
    CGRect frame = self.editView.frame;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.editView.transform = CGAffineTransformMakeTranslation(0, -frame.size.height-(keyboardHeight==0?240:keyboardHeight));
    } completion:^(BOOL finished) {
    }];
}


-(void)cancelEdit
{
    [self.editTextView resignFirstResponder];
}

-(void)saveRemark
{
    
    if (self.editTextView.text.length==0) {
        [ToolUtils showMessage:@"评论不能为空"];
        return;
    }
    
    MCommentPublish* publish = [[MCommentPublish alloc]init];
    [publish load:self postid:_post.id_ content:self.editTextView.text replyid:self.selectFloor];
    self.selectFloor = nil;
    [self.editTextView resignFirstResponder];
}




- (void) keyboardWasHidden:(NSNotification *) notif
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.editView.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        
    }];
    [self removeMask];
    [self removeMaskAtNavigation];
}
#pragma mark -sharebuttons

- (IBAction)qqShare:(UIButton *)sender {
    [ShareApiUtil qqShare:[self getShareTitle] description:[self getShareContent] imageUrl:[BaseFuncVC getShareImgUrl] shareUrl:[self getShareUrl] from:self];
}

- (IBAction)friendsShare:(UIButton *)sender {
     [ShareApiUtil weixinShare:[self getShareTitle] description:[self getShareContent] imageUrl:[BaseFuncVC getShareImgUrl] shareUrl:[self getShareUrl]scene:WXSceneTimeline];}

- (IBAction)weixinShare:(UIButton *)sender {
     [ShareApiUtil weixinShare:[self getShareTitle] description:[self getShareContent] imageUrl:[BaseFuncVC getShareImgUrl] shareUrl:[self getShareUrl]scene:WXSceneSession];
}


- (IBAction)weiboShare:(UIButton *)sender {
    [ShareApiUtil weiboShare:[self getShareTitle] description:[self getShareContent] imageUrl:[BaseFuncVC getShareImgUrl] shareUrl:[self getShareUrl]];
}


-(void)processShareSuccess{
    [self hideShareView];
    [ShareApiUtil showShareSuccessAlert];
}

-(NSString *)getShareTitle
{
    return self.post.title_;
}

-(NSString *)getShareContent
{
    return self.post.content_;
}

-(NSString *)getShareUrl
{
    return self.post.sharedUrl_;
}


- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            //[msgbox release];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            //[msgbox release];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            //[msgbox release];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            //[msgbox release];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            //[msgbox release];
            
            break;
        }
        default:
        {
            break;
        }
    }
    //[self processShareSuccess];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)onReq:(QQBaseReq *)req
{
}
- (void)onResp:(QQBaseResp *)resp
{
    NSLog(@"过来了");
}
- (void)isOnlineResponse:(NSDictionary *)response
{
}


@end

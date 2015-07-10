//
//  DemoViewController.m
//  GJGCChatInputPanel
//
//  Created by ZYVincent on 15/7/10.
//  Copyright (c) 2015年 ZYProSoft. All rights reserved.
//

#import "DemoViewController.h"
#import "GJGCChatInputPanel.h"
#import "GJCFCoreTextContentView.h"
#import "DemoEmojiParser.h"
#import "GJCFAudioPlayer.h"
#import "TVGDebugQuickUI.h"
#import "GJCFAssetsPickerViewController.h"

#define DemoImageViewTag 112233

@interface DemoViewController ()<GJGCChatInputPanelDelegate,GJCFAudioPlayerDelegate,GJCFAssetsPickerViewControllerDelegate>

@property (nonatomic,strong)GJGCChatInputPanel *inputPanel;

@property (nonatomic,strong)GJCFAudioPlayer *audioPlayer;

@property (nonatomic,strong)GJCFAudioModel *currentRecordFile;

@property (nonatomic,strong)GJCFCoreTextContentView *contentLabel;

@property (nonatomic,strong)NSMutableArray *assetsArray;

@end

@implementation DemoViewController

- (void)dealloc
{
    [self.inputPanel removeObserver:self forKeyPath:@"frame"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.assetsArray = [[NSMutableArray alloc]init];
    
    [self initSubViews];
    
    //contentLabel
    CGFloat contentMaxWidth = GJCFSystemScreenWidth - 2*12.f;
    CGSize contentBaseSize = CGSizeMake(contentMaxWidth, 10);
    
    self.contentLabel = [[GJCFCoreTextContentView alloc]init];
    self.contentLabel.gjcf_size = (CGSize){100,10};
    self.contentLabel.contentBaseSize = contentBaseSize;
    [self.contentLabel appendImageTag:@"imageTag"];
    [self.view addSubview:self.contentLabel];
    
    UIButton *playButton = [TVGDebugQuickUI buttonAddOnView:self.view title:@"播放录音" target:self selector:@selector(starPlayCurrentAudio)];
    
    playButton.gjcf_top = self.view.gjcf_height / 2 - 100;
    playButton.gjcf_left = 15.f;
    
    /* 语音播放工具 */
    self.audioPlayer = [[GJCFAudioPlayer alloc]init];
    self.audioPlayer.delegate = self;
    
}

#pragma mark - 初始化设置
- (void)initSubViews
{
    CGFloat originY = GJCFSystemNavigationBarHeight + GJCFSystemOriginYDelta;
    
    /* 输入面板 */
    self.inputPanel = [[GJGCChatInputPanel alloc]initWithPanelDelegate:self];
    self.inputPanel.frame = (CGRect){0,GJCFSystemScreenHeight-self.inputPanel.inputBarHeight-originY,GJCFSystemScreenWidth,self.inputPanel.inputBarHeight+216};
    
    GJCFWeakSelf weakSelf = self;
    [self.inputPanel configInputPanelKeyboardFrameChange:^(GJGCChatInputPanel *panel,CGRect keyboardBeginFrame, CGRect keyboardEndFrame, NSTimeInterval duration,BOOL isPanelReserve) {
        
        [UIView animateWithDuration:duration animations:^{
            
            CGFloat viewHeight = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight - originY - keyboardEndFrame.size.height;
            
            if (keyboardEndFrame.origin.y == GJCFSystemScreenHeight) {
                
                if (isPanelReserve) {
                    
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight  - originY;
                    
                    
                }else{
                    
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - 216 - weakSelf.inputPanel.inputBarHeight - originY;
                    
                }
                
            }else{
                
                weakSelf.inputPanel.gjcf_top = viewHeight;
                
            }
            
        }];
        
        
    }];
    
    [self.inputPanel configInputPanelRecordStateChange:^(GJGCChatInputPanel *panel, BOOL isRecording) {
        
        if (isRecording) {
            
            
        }else{
            
        }
        
    }];
    
    [self.inputPanel configInputPanelInputTextViewHeightChangedBlock:^(GJGCChatInputPanel *panel, CGFloat changeDelta) {
        
        panel.gjcf_top = panel.gjcf_top - changeDelta;
        
        panel.gjcf_height = panel.gjcf_height + changeDelta;
        
    }];
    
    /* 动作变化 */
    [self.inputPanel setActionChangeBlock:^(GJGCChatInputBar *inputBar, GJGCChatInputBarActionType toActionType) {
        [weakSelf inputBar:inputBar changeToAction:toActionType];
    }];
    [self.view addSubview:self.inputPanel];
    
    /* 观察输入面板变化 */
    [self.inputPanel addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    UITapGestureRecognizer *tapR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnView)];
    [self.view addGestureRecognizer:tapR];
}

- (void)tapOnView
{
    if ([self.inputPanel isInputTextFirstResponse]) {
        
        [self.inputPanel inputBarRegsionFirstResponse];
        
    }
    
    CGFloat originY = GJCFSystemNavigationBarHeight + GJCFSystemOriginYDelta;
    
    if (self.inputPanel.isFullState) {
        
        [UIView animateWithDuration:0.26 animations:^{
            
            self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
            
        }];
        
        [self.inputPanel reserveState];
        
    }
}

#pragma mark - 属性变化观察
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] && object == self.inputPanel) {
        
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        
        CGFloat originY = GJCFSystemNavigationBarHeight + GJCFSystemOriginYDelta;
        
        //50.f 高度是输入条在底部的时候显示的高度，在录音状态下就是50
        if (newFrame.origin.y < GJCFSystemScreenHeight - 50.f - originY) {
            
            self.inputPanel.isFullState = YES;
            
        }else{
            
            self.inputPanel.isFullState = NO;
        }
    }
}


#pragma mark - 输入动作变化

- (void)inputBar:(GJGCChatInputBar *)inputBar changeToAction:(GJGCChatInputBarActionType)actionType
{
    CGFloat originY = GJCFSystemNavigationBarHeight + GJCFSystemOriginYDelta;
    
    switch (actionType) {
        case GJGCChatInputBarActionTypeRecordAudio:
        {
            if (self.inputPanel.isFullState) {
                
                [UIView animateWithDuration:0.26 animations:^{
                    
                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
                    
                }];
            }
        }
            break;
        case GJGCChatInputBarActionTypeChooseEmoji:
        case GJGCChatInputBarActionTypeExpandPanel:
        {
            if (!self.inputPanel.isFullState) {
                
                [UIView animateWithDuration:0.26 animations:^{
                    
                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - 216 - originY;
                    
                }];
                
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - GJGCChatInputPanelDelegate

- (void)chatInputPanel:(GJGCChatInputPanel *)panel sendTextMessage:(NSString *)text
{
    //移除图片
    [self removeImageViews];
    
    NSAttributedString *contentAttributed = [DemoEmojiParser formateContent:text];
    
    CGSize contentSize = [GJCFCoreTextContentView contentSuggestSizeWithAttributedString:contentAttributed forBaseContentSize:self.contentLabel.contentBaseSize];
    
    self.contentLabel.gjcf_size = contentSize;
    
    self.contentLabel.gjcf_left = 12.f;
    self.contentLabel.gjcf_top = 12.f;
    self.contentLabel.contentAttributedString = contentAttributed;
}

- (void)chatInputPanel:(GJGCChatInputPanel *)panel didFinishRecord:(GJCFAudioModel *)audioFile
{
    self.currentRecordFile = audioFile;
}

- (void)chatInputPanel:(GJGCChatInputPanel *)panel didChooseMenuAction:(GJGCChatInputMenuPanelActionType)actionType
{
    switch (actionType) {
        case GJGCChatInputMenuPanelActionTypeCamera:
        {
            
        }
            break;
        case GJGCChatInputMenuPanelActionTypePhotoLibrary:
        {
            GJCFAssetsPickerViewController *picker = [[GJCFAssetsPickerViewController alloc]init];
            picker.pickerDelegate = self;
            picker.mutilSelectLimitCount = 3.f;
            
            [self.navigationController presentViewController:picker animated:YES completion:nil];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - GJCFAudioPlayer Delegate

- (void)starPlayCurrentAudio
{
    [self.audioPlayer playAudioFile:self.currentRecordFile];
}

- (void)stopPlayCurrentAudio
{
    
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didFinishPlayAudio:(GJCFAudioModel *)audioFile
{
    
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didOccusError:(NSError *)error
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self stopPlayCurrentAudio];
        
    });
    
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didUpdateSoundMouter:(CGFloat)soundMouter
{
    NSLog(@"播放录音音量:%f",soundMouter);
}

#pragma mark - GJCFAssetsPickerViewControllerDelegate

- (void)showResultImages
{
    for (NSInteger index = 0; index < self.assetsArray.count; index++ ) {
        
        GJCFAsset *asset = [self.assetsArray objectAtIndex:index];
        
        if (![self.view viewWithTag:DemoImageViewTag + index]) {
            
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.gjcf_left = 12.f;
            imageView.gjcf_size = CGSizeMake(70, 70);
            imageView.gjcf_top = 12*(index + 1) + 70*index;
            imageView.tag = DemoImageViewTag + index;
            imageView.image = asset.thumbnail;
            
            [self.view addSubview:imageView];
        }
    }
}

- (void)removeImageViews
{
    for (NSInteger index = 0; index < self.assetsArray.count; index++ ) {
        
        if ([self.view viewWithTag:DemoImageViewTag + index]) {
            
            [[self.view viewWithTag:DemoImageViewTag + index] removeFromSuperview];
        }
    }
}

- (void)pickerViewController:(GJCFAssetsPickerViewController *)pickerViewController didFinishChooseMedia:(NSArray *)resultArray
{
    [pickerViewController dismissPickerViewController];
    
    [self.assetsArray removeAllObjects];
    [self.assetsArray addObjectsFromArray:resultArray];
    
    [self performSelector:@selector(showResultImages) withObject:nil afterDelay:0.5];
}

- (void)pickerViewControllerPhotoLibraryAccessDidNotAuthorized:(GJCFAssetsPickerViewController *)pickerViewController
{
    [self alertPickerLimitMessage:@"请允许App访问你的相册"];
}

- (void)pickerViewControllerRequirePreviewButNoSelectedImage:(GJCFAssetsPickerViewController *)pickerViewController
{
    [self alertPickerLimitMessage:@"请选择需要预览的图片"];
}

- (void)pickerViewController:(GJCFAssetsPickerViewController *)pickerViewController didReachLimitSelectedCount:(NSInteger)limitCount
{
    [self alertPickerLimitMessage:[NSString stringWithFormat:@"不能选中超过%ld张",(long)limitCount]];
}

- (void)alertPickerLimitMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

@end

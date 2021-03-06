//
//  GJGCChatInputPanelDelegate.h
//  GJGroupChat
//
//  Created by ZYVincent on 14-10-28.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

@class GJGCChatInputPanel;
#import "GJCFAudioModel.h"

@protocol GJGCChatInputPanelDelegate <NSObject>

@optional

/**
 *  当选择扩展面板的时候会执行这个协议来通知动作类型
 *
 *  @param panel
 *  @param actionType GJGCChatInputMenuPanelActionType
 */
- (void)chatInputPanel:(GJGCChatInputPanel *)panel didChooseMenuAction:(GJGCChatInputMenuPanelActionType)actionType;

/**
 *  完成录音
 *
 *  @param panel
 *  @param audioFile 录音结果文件
 */
- (void)chatInputPanel:(GJGCChatInputPanel *)panel didFinishRecord:(GJCFAudioModel *)audioFile;

/**
 *  发送文字消息
 *
 *  @param panel
 *  @param text  
 */
- (void)chatInputPanel:(GJGCChatInputPanel *)panel sendTextMessage:(NSString *)text;

/**
 *  发送gif消息
 *
 *  @param panel
 *  @param gifCode 
 */
- (void)chatInputPanel:(GJGCChatInputPanel *)panel sendGIFMessage:(NSString *)gifCode;

/**
 *  根据会话类型显示扩展面板
 *
 *  @param panel
 *  @param configData 其他一些自定义用来配置的参数
 *
 *  @return 
 */
- (GJGCChatInputExpandMenuPanelConfigModel *)chatInputPanelRequiredCurrentConfigData:(GJGCChatInputPanel *)panel;

/**
 *  会话输入条具体触发哪种动作
 *
 *  @param panel
 *  @param action
 */
- (void)chatInputPanel:(GJGCChatInputPanel *)panel didChangeToInputBarAction:(GJGCChatInputBarActionType)action;

@end

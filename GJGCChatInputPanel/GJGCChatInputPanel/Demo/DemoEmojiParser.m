//
//  DemoEmojiParser.m
//  GJGCChatInputPanel
//
//  Created by ZYVincent on 15/7/10.
//  Copyright (c) 2015年 ZYProSoft. All rights reserved.
//

#import "DemoEmojiParser.h"

@implementation DemoEmojiParser

/* 表情解析方法 */
+ (void)parseEmoji:(NSMutableString *)originString withEmojiTempString:(NSMutableString *)tempString withResultArray:(NSMutableArray *)resultArray
{
    if (!tempString) {
        tempString = [originString mutableCopy];
    }
    
    NSString *regex = @"\\[([\u4E00-\u9FA5OKN]{1,3})\\]";
    
    NSRegularExpression *emojiRegexExp = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *originResult = [emojiRegexExp firstMatchInString:originString options:NSMatchingReportCompletion range:NSMakeRange(0, originString.length)];
    NSTextCheckingResult *tempResult = [emojiRegexExp firstMatchInString:tempString options:NSMatchingReportCompletion range:NSMakeRange(0, tempString.length)];
    
    if (!resultArray) {
        resultArray = [NSMutableArray array];
    }
    
    /* 所有合法表情处理 */
    NSDictionary *emojiNameDict = [NSDictionary dictionaryWithContentsOfFile:GJCFMainBundlePath(@"emojiName.plist")];
    
    while (originResult) {
        
        /* 表情名字 */
        NSString *emoji = [originString substringWithRange:originResult.range];
        
        if ([emoji isEqualToString:@"xxxx"] || [emoji isEqualToString:@"xxx"] || [emoji isEqualToString:@"xxxxx"]) {
            break;
        }
        
        /* 真实占位 */
        NSRange emojiRange = originResult.range;
        
        /* 替换真实占位的表情为空格，取得空格占位 */
        NSRange replaceRange = NSMakeRange(tempResult.range.location, 1);
        
        /* 替换占位，寻找下一个 */
        [tempString replaceCharactersInRange:tempResult.range withString:@" "];
        
        if (originResult.range.length == 3) {
            [originString replaceCharactersInRange:originResult.range withString:@"xxx"];
        }
        if (originResult.range.length == 4) {
            [originString replaceCharactersInRange:originResult.range withString:@"xxxx"];
        }
        if (originResult.range.length == 5) {
            [originString replaceCharactersInRange:originResult.range withString:@"xxxxx"];
        }
        
        /* 如果是合法表情 */
        if ([emojiNameDict objectForKey:emoji]) {
            
            NSDictionary *item = @{@"emoji":emoji,@"origin":[NSValue valueWithRange:emojiRange],@"temp":[NSValue valueWithRange:replaceRange]};
            
            [resultArray addObject:item];
            
        }
        
        [self parseEmoji:originString withEmojiTempString:tempString withResultArray:resultArray];
        
    }
}

+ (NSAttributedString *)formateContent:(NSString *)comment
{
    NSMutableString *originString = [NSMutableString stringWithString:comment];
    
    NSArray *emojiNameArray = [NSArray  arrayWithContentsOfFile:GJCFMainBundlePath(@"emoji.plist")];
    NSMutableDictionary *emojiDict = [NSMutableDictionary dictionary];
    for (NSDictionary *item in emojiNameArray) {
        [emojiDict addEntriesFromDictionary:item];
    }
    
    NSMutableArray *emojiArray = [NSMutableArray array];
    
    NSMutableString *copyOriginString = [NSMutableString stringWithString:comment];
    [DemoEmojiParser parseEmoji:copyOriginString withEmojiTempString:nil withResultArray:emojiArray];
    
    /* 将表情替换成空格 */
    for (NSDictionary *emojiItem in emojiArray) {
        
        NSString *emoji = [emojiItem objectForKey:@"emoji"];
        
        [originString replaceOccurrencesOfString:emoji withString:@"\uFFFC" options:NSCaseInsensitiveSearch range:NSMakeRange(0, originString.length)];
    }
    
    GJCFCoreTextParagraphStyle *paragraphStyle = [[GJCFCoreTextParagraphStyle alloc]init];
    paragraphStyle.maxLineSpace = 3.f;
    paragraphStyle.minLineSpace = 3.f;
    
    GJCFCoreTextAttributedStringStyle *stringStyle = [[GJCFCoreTextAttributedStringStyle alloc]init];
    stringStyle.foregroundColor = GJCFQuickHexColor(@"404040");
    stringStyle.font = [UIFont systemFontOfSize:16];
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc]initWithString:originString attributes:[stringStyle attributedDictionary]];
    [contentAttributedString addAttributes:[paragraphStyle paragraphAttributedDictionary] range:NSMakeRange(0, contentAttributedString.string.length)];
    
    for (NSDictionary *emojiItem in emojiArray) {
        
        NSString *emoji = [emojiItem objectForKey:@"emoji"];
        NSRange   tempRange = [[emojiItem objectForKey:@"temp"] rangeValue];
        
        /* 插入图片 */
        GJCFCoreTextImageAttributedStringStyle *imageStyle = [[GJCFCoreTextImageAttributedStringStyle alloc]init];
        imageStyle.imageTag = @"imageTag";
        NSString *emojiIcon = [emojiDict objectForKey:emoji];
        imageStyle.imageName = [NSString stringWithFormat:@"%@.png",emojiIcon];
        imageStyle.imageSourceString = emoji;
        imageStyle.endGap = 2.f;
        
        /* 替换表情 */
        NSAttributedString *imageString = [imageStyle imageAttributedString];
        [contentAttributedString replaceCharactersInRange:tempRange withAttributedString:imageString];
    }
    
    return contentAttributedString;
    
}

@end

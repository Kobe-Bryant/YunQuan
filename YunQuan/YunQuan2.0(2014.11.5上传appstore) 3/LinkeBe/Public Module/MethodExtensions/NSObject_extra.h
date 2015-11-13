//
//  NSObject_extra.h
//  LinkeBe
//
//  Created by yunlai on 14-9-1.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (expand)

- (UILabel *)newLabelWithText:(NSString*)text 
						   frame:(CGRect)frame 
						    font:(UIFont *)font
					   textColor:(UIColor *)textColor;
				

- (UIButton *)newButtonWithImage:(UIImage *)image 
				   highlightedImage:(UIImage *)highlightedImage 
							  frame:(CGRect)frame 
							  title:(NSString *)title
						 titleColor:(UIColor *)titleColor
				   titleShadowColor:(UIColor *)titleShadowColor
						       font:(UIFont *)font
							 target:(id)target
							 action:(SEL)action;

- (UIImageView *)newImageViewWithImage:(UIImage *)image frame:(CGRect)frame;

- (UITableView *)newTableViewWithFrame:(CGRect)frame
							  style:(UITableViewStyle)style
					backgroundColor:(UIColor *)backgroundColor
						   delegate:(id)delegate
						 dataSource:(id)dataSource
					 separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;

- (UIScrollView *)newScrollViewWithFrame:(CGRect)frame
							 contentSize:(CGSize)contentSize
						 backgroundColor:(UIColor *)backgroundColor
								delegate:(id)delegate
						   pagingEnabled:(BOOL)pagingEnabled;
- (NSData *)JPEGRepresentationImage:(UIImage *)theImage targetImageLength:(int)targetImageLength;

//输入字符串@“abcdefg”和字体大小，计算出字符串像素长度
-(CGFloat)getLengthOfStringForFont:(NSString *)string 
							  font:(UIFont *)font;

//验证email格式地址
-(BOOL)regExpMatch:(NSString *)string 
	   withPattern:(NSString*)pattern;
-(BOOL)isValidEmail:(NSString *)email;


//手机号码验证,现在只是验证11位的手机号码（不包含86）
//根据具体业务需求来修改
//如： 13****,158***,159*** 正确; 12***,157*** 错误.
-(BOOL)isValidMobileNumber:(NSString *)number;

//验证输入的是否是正确格式的手机号
- (BOOL)isMobileNumber:(NSString *)mobileNum;

//验证手机号码和手机格式
-(BOOL)isValidTelMobileNumber:(NSString *)number;

//验证密码为数字和字母的组合
-(BOOL)isValidPwdNumber:(NSString *)number;

//日期格式转换
//如：20111215－>2011－12－15
-(NSString *)addSeparatorForDate:(NSString *)date;

//日期格式转换
//如：2011－12－15－>20111215
-(NSString *)removeSeparatorForDate:(NSString *)date;

//验证字符串是否是纯数字
-(BOOL)isValidNumber:(NSString*)str;

//根据key值对数组进行 降序 排序
//- (NSArray*)sortWithArray:(NSMutableArray*)array ByKey:(NSString*)key;
//根据key值对数组进行 升序 排序
- (NSArray*)sortAscendingWithArray:(NSMutableArray*)array ByKey:(NSString*)key;

//将阿拉伯数字的金额转换成中文大写格式显示出来
- (NSString *)stringArabToChinese:(NSString *)arabString;

/**
 * 功能：读取图片二进制 转换 成 NSString 类型
 * 参数：
 *		path	图片的名称 带 扩展名 
 *		t     YES：Document目录
 *			NO：bundle目录
 *
 * Created by wangmeng at 2011/8/18
 **/
-(NSMutableString*)getStringFromImagePath:(NSString*)path inDocument:(BOOL)t;

//获取运营商的信息
- (NSString* )getCellularProviderName;

//    获得手机类型
- (NSString* )getDeviceHardware;

// 应用的版本
- (NSString *)getVersionString;

//获取uuid
-(NSString* )getUuidString;

//版本升级字符串的截取
- (NSString *)subVersionString:(NSString *)subString;

- (void)alertWithFistButton:(NSString*)firstStr
			SencodButton:(NSString*)secondStr
				 Message:(NSString*)theMessage;

//添加大口号的方法
-(NSString *)addBraces:(NSString *)testString;

//get字典的拼接
-(NSString *)requestURladdress:(NSDictionary *)addressDicionary;

//消除空格
-(NSString *)whitespaceAndNewlineCharacterSet:(NSString *)whitesString;

-(NSString*) phoneNumTypeTurnWith:(NSString *)phoneNum withString:(NSString *)withString;

@end


//
//  UIPlaceHolderTextView.h
//  Property
//
//  Created by admin on 14-1-8.
//  Copyright (c) 2014年 lijun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface UIPlaceHolderTextView : UITextView {
    
    NSString *placeholder;
    
    UIColor *placeholderColor;
    
    
    
@private
    
    UILabel *placeHolderLabel;
    
}



@property(nonatomic, retain) UILabel *placeHolderLabel;

@property(nonatomic, retain) NSString *placeholder;

@property(nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic , strong) IBOutlet UILabel *letterNumLabel;



-(void)textChanged:(NSNotification*)notification;
- (void)setPlaceholder:(NSString *)aPlaceholder;


@end

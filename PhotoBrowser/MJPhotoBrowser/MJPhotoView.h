//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@protocol MJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;
@end

@interface MJPhotoView : UIScrollView <UIScrollViewDelegate>
//UIImageView *_imageView;
@property (nonatomic,strong)UIImageView* imageView;
// 图片
@property (nonatomic, strong) MJPhoto *photo;
// 代理
@property (nonatomic, weak) id<MJPhotoViewDelegate> photoViewDelegate;

@property (nonatomic)NSNumber* orientation;

@property (nonatomic,strong)UIImage* img;

@property (nonatomic, assign) CGFloat parentHeight;
- (void)photoDidFinishLoadWithImage:(UIImage *)image;

@end
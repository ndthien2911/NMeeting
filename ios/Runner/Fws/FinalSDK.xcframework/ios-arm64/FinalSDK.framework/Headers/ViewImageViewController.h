//
//  ViewImageViewController.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 9/21/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewImageViewController : ICEkycBaseViewController


@property (nonatomic) NSInteger indexImage;
@property (nonatomic) UIImage *imageFront;
@property (nonatomic) UIImage *imageBack;
@property (nonatomic) UIImage *imageFace;

@property (nonatomic) BOOL isShowTrademarkViewImage;
@property (nonatomic) UIImage *imageLogoTrademarkViewImage;


@end

NS_ASSUME_NONNULL_END

/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBAssetCollectionViewController.h"
#import "UIViewController+NavigationBar.h"
// Views
#import "QBImagePickerAssetCell.h"
#import "QBImagePickerFooterView.h"
#import "Global.h"

@interface QBAssetCollectionViewController ()

@property (nonatomic, retain) NSMutableArray *assets;
@property (nonatomic, retain) NSMutableOrderedSet *selectedAssets;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

@property(nonatomic,retain) UIScrollView* btmScroll;
@property(nonatomic,retain) UILabel* redLab;

- (void)reloadData;
- (void)updateRightBarButtonItem;
- (void)updateDoneButton;
- (void)done;
- (void)cancel;

@end

@implementation QBAssetCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        /* Initialization */
        [self creteaBackButton];
        
        self.assets = [NSMutableArray array];
        self.selectedAssets = [NSMutableOrderedSet orderedSet];
        
        self.imageSize = CGSizeMake(75, 75);
        // Table View
//        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 60) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.allowsSelection = YES;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:tableView];
        self.tableView = tableView;
        [tableView release];
        
        [self initButtomView];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //title
    NSString *title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80.0f, 40.0f)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor = [UIColor colorWithRed:102.0 /255.0 green:102.0 /255.0 blue:102.0 /255.0 alpha:1.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    
    // Reload
    [self reloadData];
    
    if(self.fullScreenLayoutEnabled) {
        // Set bar styles
        if([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
        {
            self.navigationController.navigationBar.barStyle = UIStatusBarStyleBlackOpaque;
            self.navigationController.navigationBar.translucent = NO;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
            
            CGFloat top = 0;
            if(![[UIApplication sharedApplication] isStatusBarHidden]) top = top + 20;
            if(!self.navigationController.navigationBarHidden) top = top + 44;
            self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
            
            [self setWantsFullScreenLayout:YES];
            
            // Scroll to bottom
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height) animated:NO];
        }else{
            if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:NO];
            }else{
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
            
        }
    }
}

-(void) initButtomView{
    CGFloat buttomHeight;
    if (IOS7_OR_LATER) {
        buttomHeight = MainHeight - 60;
    }else {
        buttomHeight = MainHeight - 60 + 20;
    }
    
    UIView* buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, buttomHeight, self.view.bounds.size.width, 60)];
    buttomView.layer.borderWidth = 0.5f;
    buttomView.layer.borderColor = RGBACOLOR(249, 249, 249, 1).CGColor;
    
    buttomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:buttomView];
    
    _btmScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, 240, 40)];
    _btmScroll.showsHorizontalScrollIndicator = YES;
    _btmScroll.showsVerticalScrollIndicator = NO;
    _btmScroll.delegate = self;
    [buttomView addSubview:_btmScroll];
    
    UIImageView* addImgV = [[UIImageView alloc] initWithImage:IMGREADFILE(@"bg_group_dotted_square.png")];
    addImgV.frame = CGRectMake(5, 0, 40, 40);
    [_btmScroll addSubview:addImgV];
    RELEASE_SAFE(addImgV);
    
    UIButton* sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.backgroundColor = [UIColor colorWithRed:0.12 green:0.55 blue:0.89 alpha:1.0];
    sureBtn.frame = CGRectMake(CGRectGetMaxX(_btmScroll.frame) + 10, CGRectGetMinY(_btmScroll.frame) + 5, 50, 35);
    
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    sureBtn.titleLabel.font = KQLboldSystemFont(14);
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureBtn.layer.cornerRadius = 5.0;
    [sureBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [buttomView addSubview:sureBtn];
    
    _redLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sureBtn.frame) - 10, CGRectGetMinY(_btmScroll.frame), 20, 20)];
    _redLab.backgroundColor = [UIColor colorWithRed:0.96 green:0.30 blue:0.33 alpha:1.0];
    _redLab.textAlignment = NSTextAlignmentCenter;
    _redLab.textColor = [UIColor whiteColor];
    _redLab.font = [UIFont systemFontOfSize:13];
    _redLab.layer.cornerRadius = _redLab.bounds.size.height/2;
    [_redLab.layer setMasksToBounds:YES];
    [buttomView addSubview:_redLab];
    
    _redLab.hidden = YES;
    
    RELEASE_SAFE(buttomView);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Flash scroll indicators
    [self.tableView flashScrollIndicators];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    [self updateRightBarButtonItem];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    [self updateRightBarButtonItem];
}

- (void)dealloc
{
    [_btmScroll release];
    [_redLab release];
    
    [_assetsGroup release];
    
    [_assets release];
    [_selectedAssets release];
    
    [_tableView release];
    [_doneButton release];
    
    [super dealloc];
}


#pragma mark - Instance Methods

- (void)reloadData
{
    // Reload assets
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [self.assets addObject:result];
        }
    }];
    
    [self.tableView reloadData];
    
    // Set footer view
    if(self.showsFooterDescription) {
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        NSUInteger numberOfPhotos = self.assetsGroup.numberOfAssets;
        
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
        NSUInteger numberOfVideos = self.assetsGroup.numberOfAssets;
        
        switch(self.filterType) {
            case QBImagePickerFilterTypeAllAssets:
                [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                break;
            case QBImagePickerFilterTypeAllPhotos:
                [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                break;
            case QBImagePickerFilterTypeAllVideos:
                [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                break;
        }
        
        QBImagePickerFooterView *footerView = [[QBImagePickerFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 48)];
        
        if(self.filterType == QBImagePickerFilterTypeAllAssets) {
            footerView.titleLabel.text = [self.delegate assetCollectionViewController:self descriptionForNumberOfPhotos:numberOfPhotos numberOfVideos:numberOfVideos];
        } else if(self.filterType == QBImagePickerFilterTypeAllPhotos) {
            footerView.titleLabel.text = [self.delegate assetCollectionViewController:self descriptionForNumberOfPhotos:numberOfPhotos];
        } else if(self.filterType == QBImagePickerFilterTypeAllVideos) {
            footerView.titleLabel.text = [self.delegate assetCollectionViewController:self descriptionForNumberOfVideos:numberOfVideos];
        }
        
        self.tableView.tableFooterView = footerView;
        [footerView release];
    } else {
        QBImagePickerFooterView *footerView = [[QBImagePickerFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 4)];
        
        self.tableView.tableFooterView = footerView;
        [footerView release];
    }
}

- (void)updateRightBarButtonItem
{
    if(self.allowsMultipleSelection) {
        // Set done button
        UIButton* doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(0, 30, 30, 30);
        [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        doneBtn.titleLabel.font = KQLboldSystemFont(14);
        [doneBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        
//        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
        doneButton.enabled = NO;
        
        doneBtn.hidden = YES;
        
        [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
        self.doneButton = doneButton;
        [doneButton release];
    } else if(self.showsCancelButton) {
        // Set cancel button
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
        [cancelButton release];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (void)updateDoneButton
{
    if(self.limitsMinimumNumberOfSelection) {
        self.doneButton.enabled = (self.selectedAssets.count >= self.minimumNumberOfSelection);
    } else {
        self.doneButton.enabled = (self.selectedAssets.count > 0);
    }
    
    [self layBtmScroll];
    
}

-(void) layBtmScroll{
    for (UIView* v in _btmScroll.subviews) {
        [v removeFromSuperview];
    }
    
    if (self.selectedAssets.count) {
        for (int i = self.selectedAssets.count - 1; i >= 0; i--) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5 + (5 + 40) * (self.selectedAssets.count - 1 - i), 0, 40, 40)];
            ALAsset* asset = [self.selectedAssets objectAtIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
            [_btmScroll addSubview:imageView];
            [imageView release];
        }
        
        _btmScroll.contentSize = CGSizeMake(5 + (40 + 5)*self.selectedAssets.count, _btmScroll.bounds.size.height);
        
    }else{
        UIImageView* imageV = [[UIImageView alloc] init];
        imageV.frame = CGRectMake(0, 0, 40, 40);
        imageV.image = IMGREADFILE(@"bg_group_dotted_square.png");
        [_btmScroll addSubview:imageV];
        [imageV release];
    }
    
    if (self.selectedAssets.count) {
        _redLab.hidden = NO;
        _redLab.text = [NSString stringWithFormat:@"%d",self.selectedAssets.count];
    }else{
        _redLab.hidden = YES;
    }
    
}

- (void)done
{
    [self.delegate assetCollectionViewController:self didFinishPickingAssets:self.selectedAssets.array];
}

- (void)cancel
{
    [self.delegate assetCollectionViewControllerDidCancel:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    switch(section) {
        case 0: case 1:
        {
            if(self.allowsMultipleSelection && !self.limitsMaximumNumberOfSelection && self.showsHeaderButton) {
                numberOfRowsInSection = 1;
            }
        }
            break;
        case 2:
        {
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            numberOfRowsInSection = self.assets.count / numberOfAssetsInRow;
            if((self.assets.count - numberOfRowsInSection * numberOfAssetsInRow) > 0) numberOfRowsInSection++;
        }
            break;
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch(indexPath.section) {
        case 0:
        {
            NSString *cellIdentifier = @"HeaderCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            
            if(self.selectedAssets.count == self.assets.count) {
                cell.textLabel.text = [self.delegate descriptionForDeselectingAllAssets:self];
                
                // Set accessory view
                UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
                accessoryView.image = [UIImage imageNamed:@"QBImagePickerController.bundle/minus.png"];
                
                accessoryView.layer.shadowColor = [[UIColor colorWithWhite:0 alpha:1.0] CGColor];
                accessoryView.layer.shadowOpacity = 0.70;
                accessoryView.layer.shadowOffset = CGSizeMake(0, 1.4);
                accessoryView.layer.shadowRadius = 2;
                
                cell.accessoryView = accessoryView;
                [accessoryView release];
            } else {
                cell.textLabel.text = [self.delegate descriptionForSelectingAllAssets:self];
                
                // Set accessory view
                UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
                accessoryView.image = [UIImage imageNamed:@"QBImagePickerController.bundle/plus.png"];
                
                accessoryView.layer.shadowColor = [[UIColor colorWithWhite:0 alpha:1.0] CGColor];
                accessoryView.layer.shadowOpacity = 0.70;
                accessoryView.layer.shadowOffset = CGSizeMake(0, 1.4);
                accessoryView.layer.shadowRadius = 2;
                
                cell.accessoryView = accessoryView;
                [accessoryView release];
            }
        }
            break;
        case 1:
        {
            NSString *cellIdentifier = @"SeparatorCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                // Set background view
                UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
                backgroundView.backgroundColor = [UIColor colorWithWhite:0.878 alpha:1.0];
                
                cell.backgroundView = backgroundView;
                [backgroundView release];
            }
        }
            break;
        case 2:
        {
            NSString *cellIdentifier = @"AssetCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(cell == nil) {
                NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
                CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
                
                cell = [[[QBImagePickerAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageSize:self.imageSize numberOfAssets:numberOfAssetsInRow margin:margin] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [(QBImagePickerAssetCell *)cell setDelegate:self];
                [(QBImagePickerAssetCell *)cell setAllowsMultipleSelection:self.allowsMultipleSelection];
            }
            
            // Set assets
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            NSInteger offset = numberOfAssetsInRow * indexPath.row;
            NSInteger numberOfAssetsToSet = (offset + numberOfAssetsInRow > self.assets.count) ? (self.assets.count - offset) : numberOfAssetsInRow;
            
            NSMutableArray *assets = [NSMutableArray array];
            for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
                ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
                
                [assets addObject:asset];
            }
            
            [(QBImagePickerAssetCell *)cell setAssets:assets];
            
            // Set selection states
            for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
                ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
                
                if([self.selectedAssets containsObject:asset]) {
                    [(QBImagePickerAssetCell *)cell selectAssetAtIndex:i];
                } else {
                    [(QBImagePickerAssetCell *)cell deselectAssetAtIndex:i];
                }
            }
        }
            break;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 0;
    
    switch(indexPath.section) {
        case 0:
        {
            heightForRow = 44;
        }
            break;
        case 1:
        {
            heightForRow = 1;
        }
            break;
        case 2:
        {
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
            heightForRow = margin + self.imageSize.height;
        }
            break;
    }
    
    return heightForRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0) {
        if(self.selectedAssets.count == self.assets.count) {
            // Deselect all assets
            [self.selectedAssets removeAllObjects];
        } else {
            // Select all assets
            [self.selectedAssets addObjectsFromArray:self.assets];
        }
        
        // Set done button state
        [self updateDoneButton];
        
        // Update assets
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        
        // Update header text
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        // Cancel table view selection
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - QBImagePickerAssetCellDelegate

- (BOOL)assetCell:(QBImagePickerAssetCell *)assetCell canSelectAssetAtIndex:(NSUInteger)index
{
    BOOL canSelect = YES;
    
//    if(self.allowsMultipleSelection && self.limitsMaximumNumberOfSelection) {
//        canSelect = (self.selectedAssets.count < self.maximumNumberOfSelection);
//    }
    
    //2013.12.27  shaw
    if(self.allowsMultipleSelection && self.limitsMaximumNumberOfSelection)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:assetCell];
        
        NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
        NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
        ALAsset *asset = [self.assets objectAtIndex:assetIndex];

        if(self.selectedAssets.count < self.maximumNumberOfSelection)
        {
            canSelect = YES;
        }
        else
        {
            if([_selectedAssets containsObject:asset])
            {
                canSelect = YES;
            }
            else
            {
                NSString *showStr = [NSString stringWithFormat:@"最多只能同时选择%d张图片",self.maximumNumberOfSelection];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:showStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                
                canSelect = NO;
            }
        }
    }
    
    return canSelect;
}

- (void)assetCell:(QBImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:assetCell];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    ALAsset *asset = [self.assets objectAtIndex:assetIndex];
    
    if(self.allowsMultipleSelection) {
        if(selected) {
            [self.selectedAssets addObject:asset];
        } else {
            [self.selectedAssets removeObject:asset];
        }
        
        // Set done button state
        [self updateDoneButton];
        
        // Update header text
//        if((selected && self.selectedAssets.count == self.assets.count) ||
//           (!selected && self.selectedAssets.count == self.assets.count - 1)) {
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//        }
    } else {
        [self.delegate assetCollectionViewController:self didFinishPickingAsset:asset];
    }
}

//返回按钮
- (void)creteaBackButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

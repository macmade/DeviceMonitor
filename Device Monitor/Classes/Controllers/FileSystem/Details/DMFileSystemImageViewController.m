/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina - www.xs-labs.com
 * Distributed under the Boost Software License, Version 1.0.
 * 
 * Boost Software License - Version 1.0 - August 17th, 2003
 * 
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 * 
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 * FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/
 
/* $Id$ */

/*!
 * @file        ...
 * @copyright   (c) 2012 - Jean-David Gadina - www.xs-labs.com
 * @abstract    ...
 */

#import "DMFileSystemImageViewController.h"
#import "DMFileSystemImageViewController+Private.h"
#import "DMFile.h"
#import "DMImageScrollView.h"
#import "UIImage+DM.h"

@implementation DMFileSystemImageViewController

@synthesize scrollView = _scrollView;

- ( id )initWithFile: ( DMFile * )file
{
    if( ( self = [ self initWithNibName: @"DMFileSystemImageView" bundle: nil ] ) )
    {
        _file = [ file retain ];
    }
    
    return self;
}

- ( void )dealloc
{
    [ _file         release ];
    [ _scrollView   release ];
    [ _image        release ];
    [ _imageView    release ];
    
    [ super dealloc ];
}

- ( void )viewDidUnload
{
    [ _file         release ];
    [ _scrollView   release ];
    [ _image        release ];
    [ _imageView    release ];
    
    [ super viewDidUnload ];
}

- ( void )viewDidLoad
{
    UITapGestureRecognizer * gesture;
    NSUInteger               maxSize;
    
    [ super viewDidLoad ];
    
    self.navigationItem.title = _file.displayName;
    
    maxSize = ( [ [ UIScreen mainScreen ] scale ] > 1 && [ [ UIDevice currentDevice ] userInterfaceIdiom ] == UIUserInterfaceIdiomPad ) ? 4096 : 2048;
    _image  = [ [ UIImage thumbnailForImageAtPath: _file.path maxSize: maxSize ] retain ];
    
    gesture                      = [ [ UITapGestureRecognizer alloc ] initWithTarget: self action: @selector( handleDoubleTap: ) ];
    gesture.numberOfTapsRequired = 2;
    
    [ self.view addGestureRecognizer: gesture ];
    [ gesture release ];
}

- ( void )viewWillAppear: ( BOOL )animated
{
    [ super viewWillAppear: animated ];
    
    [ _imageView removeFromSuperview ];
    [ _imageView release ];
    
    _imageView       = [ [ DMImageScrollView alloc ] initWithFrame: _scrollView.bounds ];
    _imageView.image = _image;
    
    [ _scrollView addSubview: _imageView ];
}

- ( void )viewWillDisappear: ( BOOL )animated
{
    [ super viewWillDisappear: animated ];
}

- ( void )viewDidAppear: ( BOOL )animated
{
    UIImage         * image;
    UIBarButtonItem * spacer;
    UIBarButtonItem * item;
    UIBarButtonItem * infos;
    UIBarButtonItem * openIn;
    UILabel         * label;
    
    [ super viewDidAppear: animated ];
    
    spacer = [ [ UIBarButtonItem alloc ] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL ];
    
    label                   = [ [ UILabel alloc ] initWithFrame: CGRectMake( 0, 0, self.navigationController.toolbar.bounds.size.width - 50, self.navigationController.toolbar.bounds.size.height ) ];
    label.backgroundColor   = [ UIColor clearColor ];
    label.textColor         = [ UIColor whiteColor ];
    label.font              = [ UIFont systemFontOfSize: [ UIFont smallSystemFontSize ] ];
    label.textAlignment     = UITextAlignmentCenter;
    label.lineBreakMode     = UILineBreakModeMiddleTruncation;
    label.autoresizingMask  = UIViewAutoresizingFlexibleWidth
                            | UIViewAutoresizingFlexibleHeight
                            | UIViewAutoresizingFlexibleLeftMargin
                            | UIViewAutoresizingFlexibleTopMargin
                            | UIViewAutoresizingFlexibleRightMargin
                            | UIViewAutoresizingFlexibleBottomMargin;
    
    if( [ [ UIDevice currentDevice ] userInterfaceIdiom ] == UIUserInterfaceIdiomPad )
    {
        label.textColor = [ UIColor colorWithRed: ( CGFloat )0.44 green: ( CGFloat )0.47 blue: ( CGFloat )0.5 alpha: ( CGFloat )1 ];
    }
    
    image      = [ UIImage imageWithContentsOfFile: _file.path ];
    label.text = [ NSString stringWithFormat: @"%lu x %lu", ( unsigned long )image.size.width, ( unsigned long )image.size.height ];
    
    item                                    = [ [ UIBarButtonItem alloc ] initWithCustomView: label ];
    infos                                   = [ [ UIBarButtonItem alloc ] initWithBarButtonSystemItem: UIBarButtonSystemItemSearch target: self action: @selector( showInfos: ) ];
    openIn                                  = [ [ UIBarButtonItem alloc ] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: self action: @selector( openIn: ) ];
    self.navigationController.toolbar.items = [ NSArray arrayWithObjects: infos, spacer, item, spacer, openIn, nil ];
    
    [ spacer    release ];
    [ item      release ];
    [ label     release ];
    [ infos     release ];
    [ openIn    release ];
}

- ( BOOL )shouldAutorotateToInterfaceOrientation: ( UIInterfaceOrientation )orientation
{
    ( void )orientation;
    
    return YES;
}

- ( void )willAnimateRotationToInterfaceOrientation: ( UIInterfaceOrientation )orientation duration: ( NSTimeInterval )duration
{
    CGPoint restorePoint;
    CGFloat restoreScale;
    
    ( void )orientation;
    ( void )duration;
    
    _scrollView.contentSize = _scrollView.bounds.size;
    restorePoint            = [ _imageView pointToCenterAfterRotation ];
    restoreScale            = [ _imageView scaleToRestoreAfterRotation ];
    _imageView.frame        = _scrollView.bounds;
    
    [ _imageView setMaxMinZoomScalesForCurrentBounds ];
    [ _imageView restoreCenterPoint: restorePoint scale: restoreScale ];
}

@end

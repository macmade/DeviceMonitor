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
 * @header      ...
 * @copyright   (c) 2012 - Jean-David Gadina - www.xs-labs.com
 * @abstract    ...
 */

#import "DMGroupedTableViewCellBackgroundView.h"

@implementation DMGroupedTableViewCellBackgroundView

@synthesize borderColor        = _borderColor;
@synthesize fillColor          = _fillColor;
@synthesize borderWidth        = _borderWidth;
@synthesize borderRadius       = _borderRadius;
@synthesize backgroundViewType = _backgroundViewType;

- ( id )initWithFrame: ( CGRect )frame
{
    if( ( self = [ super initWithFrame: frame ] ) )
    {
        self.borderColor        = [ UIColor lightGrayColor ];
        self.fillColor          = [ UIColor whiteColor ];
        self.borderWidth        = ( CGFloat )0.5;
        self.borderRadius       = 10;
        self.backgroundViewType = DMGroupedTableViewCellBackgroundViewTypeMiddle;
    }
    
    return self;
}

- ( void )dealloc
{
    [ _borderColor release ];
    [ _fillColor   release ];
    
    [ super dealloc ];
}

- ( BOOL )isOpaque
{
    return NO;
}

-( void )drawRect: ( CGRect )rect 
{
    CGFloat      minX;
    CGFloat      minY;
    CGFloat      midX;
    CGFloat      midY;
    CGFloat      maxX;
    CGFloat      maxY;
    CGContextRef context;
    
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor( context, [ _fillColor CGColor ] );
    CGContextSetStrokeColorWithColor( context, [ _borderColor CGColor ] );
    CGContextSetLineWidth( context, _borderWidth );
    
    if( _backgroundViewType == DMGroupedTableViewCellBackgroundViewTypeTop )
    {
        minX  = CGRectGetMinX( rect );
        midX  = CGRectGetMidX( rect );
        maxX  = CGRectGetMaxX( rect );
        minY  = CGRectGetMinY( rect );
        maxY  = CGRectGetMaxY( rect );
        minX += _borderWidth;
        minY += _borderWidth;
        maxX -= _borderWidth;
        
        CGContextMoveToPoint( context, minX, maxY );
        CGContextAddArcToPoint( context, minX, minY, midX, minY, _borderRadius );
        CGContextAddArcToPoint( context, maxX, minY, maxX, maxY, _borderRadius );
        CGContextAddLineToPoint( context, maxX, maxY );
        CGContextClosePath( context );
        CGContextDrawPath( context, kCGPathFillStroke );
    }
    else if( _backgroundViewType == DMGroupedTableViewCellBackgroundViewTypeBottom )
    {
        minX  = CGRectGetMinX( rect );
        midX  = CGRectGetMidX( rect );
        maxX  = CGRectGetMaxX( rect );
        minY  = CGRectGetMinY( rect );
        maxY  = CGRectGetMaxY( rect );
        minX += _borderWidth;
        maxX -= _borderWidth;
        maxY -= _borderWidth;
        
        CGContextMoveToPoint( context, minX, minY );
        CGContextAddArcToPoint( context, minX, maxY, midX, maxY, _borderRadius );
        CGContextAddArcToPoint( context, maxX, maxY, maxX, minY, _borderRadius );
        CGContextAddLineToPoint( context, maxX, minY );
        CGContextClosePath( context );
        CGContextDrawPath( context, kCGPathFillStroke );
    }
    else if( _backgroundViewType == DMGroupedTableViewCellBackgroundViewTypeSingle )
    {
        minX  = CGRectGetMinX( rect );
        midX  = CGRectGetMidX( rect );
        maxX  = CGRectGetMaxX( rect );
        minY  = CGRectGetMinY( rect );
        midY  = CGRectGetMidY( rect );
        maxY  = CGRectGetMaxY( rect );
        minX += 1;
        minY += 1;
        maxX -= 1;
        maxY -= 1;

        CGContextMoveToPoint( context, minX, midY );
        CGContextAddArcToPoint( context, minX, minY, midX, minY, _borderRadius );
        CGContextAddArcToPoint( context, maxX, minY, maxX, midY, _borderRadius );
        CGContextAddArcToPoint( context, maxX, maxY, midX, maxY, _borderRadius );
        CGContextAddArcToPoint( context, minX, maxY, minX, midY, _borderRadius );
        CGContextClosePath( context );
        CGContextDrawPath( context, kCGPathFillStroke );                
    }
    else if( _backgroundViewType == DMGroupedTableViewCellBackgroundViewTypeMiddle )
    {
        minX  = CGRectGetMinX( rect );
        maxX  = CGRectGetMaxX( rect );
        minY  = CGRectGetMinY( rect );
        maxY  = CGRectGetMaxY( rect );
        minX += _borderWidth;
        maxX -= _borderWidth;
        
        CGContextMoveToPoint( context, minX, minY );
        CGContextAddLineToPoint( context, maxX, minY );
        CGContextAddLineToPoint( context, maxX, maxY );
        CGContextAddLineToPoint( context, minX, maxY );
        CGContextClosePath( context );
        CGContextDrawPath( context, kCGPathFillStroke );
    }
}

@end
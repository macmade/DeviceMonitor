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

#import "DMFileSystemTextViewController+Private.h"
#import "DMFileSystemTextViewController+UIDocumentInteractionControllerDelegate.h"
#import "DMFile.h"
#import "DMHUDView.h"
#import "DMFileSystemFileInfosViewController.h"

#define HEX_BUFFER_LENGTH 4096

@implementation DMFileSystemTextViewController( Private )

- ( void )loadText: ( UISegmentedControl * )segment
{
    NSData   * data;
    NSString * text;
    
    @autoreleasepool
    {
        _hasText = NO;
        _hasHex  = NO;
        
        data = [ [ NSFileManager defaultManager ] contentsAtPath: _file.path ];
        text = [ [ NSString alloc ] initWithData: data encoding: NSASCIIStringEncoding ];
        
        [ _textView performSelectorOnMainThread: @selector( setText: ) withObject: text waitUntilDone: YES ];
        [ text release ];
        
        dispatch_async
        (
            dispatch_get_main_queue(),
            ^( void )
            {
                [ UIView animateWithDuration: 1
                         animations: ^( void )
                         {
                            _hud.alpha = ( CGFloat )0;
                         }
                         completion: ^( BOOL finished )
                         {
                            ( void )finished;
                            
                            [ _hud removeFromSuperview ];
                            [ segment setEnabled: YES ];
                            
                            _hasText = YES;
                         }
                ];
            }
        );
    }
}

- ( void )loadHex: ( UISegmentedControl * )segment
{
    size_t            length;
    unsigned int      i;
    unsigned int      j;
    size_t            fileSize;
    char              ascii;
    char              buffer[ HEX_BUFFER_LENGTH ];
    FILE            * f;
    NSMutableString * hex;
    NSUInteger        hexLineLength;
    
    @autoreleasepool
    {
        _hasText = NO;
        _hasHex  = NO;
        
        f = fopen( [ _file.path cStringUsingEncoding: NSASCIIStringEncoding ], "r" );
        
        if( f == NULL )
        {
            return;
        }
        
        if( [ [ UIDevice currentDevice ] userInterfaceIdiom ] == UIUserInterfaceIdiomPad )
        {
            hexLineLength = 23;
        }
        else if( [ [ [ UIDevice currentDevice ] systemVersion ] integerValue ] >= 5 )
        {
            hexLineLength = 10;
        }
        else
        {
            hexLineLength = 9;
        }
        
        fseek( f, 0, SEEK_END );
        
        fileSize = ( size_t )ftell( f );
        
        fseek( f, 0, SEEK_SET );
        
        hex = [ NSMutableString stringWithCapacity: ( fileSize * 5 ) ];
        
        while( ( length = fread( buffer, sizeof( char ), HEX_BUFFER_LENGTH, f ) ) )
        {
            for( i = 0; i < length; i += hexLineLength )
            {
                for( j = 0; j < hexLineLength; j++ )
                {
                    if( ( i + j ) < length )
                    {
                        [ hex appendFormat: @"%02x ", ( unsigned char )buffer[ i + j ] ];
                    }
                    else
                    {
                        [ hex appendString: @"   " ];
                    }
                }
                
                [ hex appendString: @": " ];
                
                for( j = 0; j < hexLineLength; j++ )
                {
                    ascii = ' ';
                    
                    if( ( i + j ) < length )
                    {
                        ascii = buffer[ i + j ];
                    }
                    
                    [ hex appendFormat: @"%c", ( ( ( ascii & 0x80 ) == 0 ) && isprint( ( int )ascii ) ) ? ascii : '.' ];
                }
                
                [ hex appendString: @"\n" ];
            }
        }
        
        fclose( f );
        
        [ _textView performSelectorOnMainThread: @selector( setText: ) withObject: hex waitUntilDone: YES ];
        
        dispatch_async
        (
            dispatch_get_main_queue(),
            ^( void )
            {
                [ UIView animateWithDuration: 1
                         animations: ^( void )
                         {
                            _hud.alpha = ( CGFloat )0;
                         }
                         completion: ^( BOOL finished )
                         {
                            ( void )finished;
                            
                            [ _hud removeFromSuperview ];
                            [ segment setEnabled: YES ];
                            
                            _hasHex = YES;
                         }
                ];
            }
        );
    }
}

- ( IBAction )openIn: ( id )sender
{
    UIAlertView                     * alert;
    UIDocumentInteractionController * controller;
    
    ( void )sender;
    
    controller          = [ UIDocumentInteractionController interactionControllerWithURL: [ NSURL fileURLWithPath: _file.path ] ];
    controller.delegate = self;
    
    [ controller retain ];
    
    if( [ controller presentOpenInMenuFromBarButtonItem: sender animated: YES ] == NO )
    {
        alert = [ [ UIAlertView alloc ] initWithTitle: NSLocalizedString( @"OpenInAlertTitle", @"OpenInAlertTitle" ) message: NSLocalizedString( @"OpenInAlertText", @"OpenInAlertText" ) delegate: nil cancelButtonTitle: NSLocalizedString( @"OK", @"OK" ) otherButtonTitles: nil ];
        
        [ alert show ];
        [ alert autorelease ];
    }
}

- ( IBAction )showInfos: ( id )sender
{
    UIViewController * controller;
    DMFile           * file;
    
    ( void )sender;
    
    file       = ( _file.targetFile == nil ) ? _file : _file.targetFile;
    controller = [ [ DMFileSystemFileInfosViewController alloc ] initWithFile: file ];
    
    if( controller != nil )
    {
        [ self.navigationController pushViewController: controller animated: YES ];
    }
    
    [ controller release ];
}

- ( IBAction )toggleDisplay: ( id )sender
{
    UISegmentedControl * segment;
    
    if( [ sender isKindOfClass: [ UISegmentedControl class ] ] == NO )
    {
        return;
    }
    
    segment = ( UISegmentedControl * )sender;
    
    [ segment setEnabled: NO ];
    
    _hud.alpha = ( CGFloat )1;
    
    [ self.view addSubview: _hud ];
    
    if( segment.selectedSegmentIndex == 0 )
    {
        [ NSThread detachNewThreadSelector: @selector( loadText: ) toTarget: self withObject: segment ];
    }
    else if( segment.selectedSegmentIndex == 1 )
    {
        [ NSThread detachNewThreadSelector: @selector( loadHex: ) toTarget: self withObject: segment ];
    }
}

@end

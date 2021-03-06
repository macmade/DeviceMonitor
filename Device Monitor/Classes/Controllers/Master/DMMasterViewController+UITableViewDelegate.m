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

#import "DMMasterViewController+UITableViewDelegate.h"
#import "DMBatteryViewController.h"
#import "DMDeviceInfosViewController.h"
#import "DMFileSystemPartitionTableViewController.h"
#import "DMLogsViewController.h"
#import "DMProcessesViewController.h"
#import "DMUsageViewController.h"
#import "DMNetworkViewController.h"

@implementation DMMasterViewController( UITableViewDelegate )

- ( void )tableView: ( UITableView * )tableView didSelectRowAtIndexPath: ( NSIndexPath * )indexPath
{
    DMDetailViewController * controller;
    
    [ tableView deselectRowAtIndexPath: indexPath animated: YES ];
    
    if( indexPath.section > 0 )
    {
        return;
    }
    
    switch( indexPath.row )
    {
        case 0:
            
            controller = [ DMDeviceInfosViewController new ];
            break;
            
        case 1:
            
            controller = [ DMUsageViewController new ];
            break;
            
        case 2:
            
            controller = [ DMProcessesViewController new ];
            break;
            
        case 3:
            
            controller = [ DMNetworkViewController new ];
            break;
            
        case 4:
            
            controller = [ DMLogsViewController new ];
            break;
            
        case 5:
            
            controller = [ DMFileSystemPartitionTableViewController new ];
            break;
            
        case 6:
            
            controller = [ DMBatteryViewController new ];
            break;
            
        default:
            
            controller = nil;
            break;
    }
    
    if( controller == nil )
    {
        return;
    }
    
    if( [ [ UIDevice currentDevice ] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone )
    {
        [ self.navigationController pushViewController: controller animated: YES ];
    }
    else
    {
        {
            UINavigationController * navigationController;
            
            navigationController      = [ [ [ UINavigationController alloc ] initWithRootViewController: controller ] autorelease ];
            
            self.splitViewController.delegate           = controller;
            self.splitViewController.viewControllers    = [ NSArray arrayWithObjects: self.navigationController, navigationController, nil ];
        }
    }
    
    [ controller release ];
}

@end

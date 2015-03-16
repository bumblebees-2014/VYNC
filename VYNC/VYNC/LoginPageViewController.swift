//
//  LoginPageViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 2/23/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit


class LoginPageViewController : UIViewController, UIPageViewControllerDataSource {


    var pageViewController = UIPageViewController()
    var pageColors = [String]()
    var pageTitles = [String]()
    var pageImages = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        pageColors.append("Red")
        pageColors.append("Green")
        pageColors.append("Blue")
        pageColors.append("Red")
        
        for i in 1...4 {
            pageImages.append("p\(i).png")
        }

        pageTitles.append("Take Videos")
        pageTitles.append("Play Videos")
        pageTitles.append("Add Titles")
        pageTitles.append("Share with Friends")
        
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        pageViewController.dataSource = self
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.backgroundColor = UIColor.blackColor()
        
        let viewController = [viewControllerAtIndex(0)!]
        pageViewController.setViewControllers(viewController, direction: .Forward, animated: false, completion: nil)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as LoginViewController).pageIndex
        if index == 0 {
            return nil
        }
        return viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as LoginViewController).pageIndex
        if index + 1 == pageColors.count {
            return nil
        }
        return viewControllerAtIndex(index + 1)
    }

    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageColors.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func viewControllerAtIndex(index: Int) -> LoginViewController? {
        if pageColors.count == 0 || index >= pageColors.count {
            return nil
        }
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("Login") as LoginViewController
        loginVC.color = pageColors[index]
        loginVC.titleString = pageTitles[index]
        loginVC.imageString = pageImages[index]
        loginVC.pageIndex = index
        return loginVC
    }
}
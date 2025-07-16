//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 14.07.2025.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    let pageControl = UIPageControl()
    let skipButton = UIButton()
    var pages = [UIViewController]()
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createPages()
        setupPageControl()
        setupSkipButton()
    }
    
    private func setupUI() {
        dataSource = self
        delegate = self
        view.backgroundColor = .systemBackground
    }
    
    private func createPages() {
        pages = OnboardingData.pages.map { pageData in
            OnboardingViewController(
                imageName: pageData.imageName,
                title: pageData.title
            )
        }
        
        setViewControllers([pages[0]], direction: .forward, animated: true)
    }
    
    private func setupPageControl() {
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupSkipButton() {
        skipButton.setTitle("Вот это технологии!", for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.backgroundColor = .black
        skipButton.layer.cornerRadius = 16
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        view.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func skipButtonTapped() {
        UserDefaults.standard.set(true, forKey: "onboardingShown")
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let tabBarVC = sceneDelegate.tabBarController else {
            return
        }
        
        sceneDelegate.changeRootViewController(to: tabBarVC)
    }
}


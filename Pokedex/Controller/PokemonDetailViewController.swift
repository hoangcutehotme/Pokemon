//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by SMin on 04/08/2022.
//

import UIKit
import Alamofire
import BetterSegmentedControl
import Kingfisher

enum DragDirection {
    case Up
    case Down
}

protocol InnerTableViewScrollDelegate: AnyObject {
    
    var currentHeaderHeight: CGFloat { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

class PokemonDetailViewController: UIViewController {
    
    
    @IBOutlet var imgPoke: UIImageView!
    @IBOutlet var powerPoke1: UIImageView!
    @IBOutlet var namePoke: UILabel!
    @IBOutlet weak var stickyHeaderView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentFromLib: BetterSegmentedControl!
    @IBOutlet var infoView: UIView!
    @IBOutlet var childBottom: UIView!
    @IBOutlet var textStart: UILabel!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var titleLable: UILabel!
    
    @IBOutlet var segmentView: UIView!
    var pokemon : Pokemon?
    
    var pageViewController = UIPageViewController()
    var pageCollection = PageCollection()
    
    var topViewInitialHeight : CGFloat = 400
    let topViewFinalHeight : CGFloat = 0
    var topViewHeightConstraintRange: Range<CGFloat>? = nil
    var oldIndex = 0
    
    var species :SpeciesPoke?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentView.layer.cornerRadius = 30
        segmentView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        setUpNavigationBar()
        fetchSpecies()
        updateTopViewHeight()
        setupSegment()
    }
    
    
    // MARK: - Function
    func setupSegment() {
        segmentFromLib.segments = LabelSegment.segments(withTitles: ["STATS", "EVOLUTIONS", "MOVES"],normalTextColor: .systemCyan,
                                                        selectedBackgroundColor: .systemCyan, selectedTextColor: .white)
        
    }
    
    func setUpNavigationBar(){
        btnBack.addTarget(self, action: #selector(popUpCV), for: .touchUpInside)
    }
    @objc private func popUpCV(){
        dismiss(animated: true)
    }
    func updateTopViewHeight() {
        
        loadingImg(url: pokemon!.sprites.other.official.img)
        namePoke.text = pokemon?.name.capitalized
        powerPoke1.image = UIImage(named: ((pokemon?.types[0].pokeType.name)! + "Tag"))
        
        infoView.layer.cornerRadius = 40
        infoView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        //bottomView.layer.cornerRadius = 30
        segmentView.layer.cornerRadius = 30
        segmentView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight
    }
    
    func loadingImg(url: String) {
        let url = URL(string: url)
        imgPoke.kf.setImage(with: url, placeholder: UIImage(named: "ic_pokemon_placeholder"), options: [
            .loadDiskFileSynchronously,
            .cacheOriginalImage,
            .transition(.fade(0.25))
        ])
    }
    
    func setupBottom() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Setup PageView
        let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "PokemonStatsViewController") as? PokemonStatsViewController
        firstVC?.pokemon = self.pokemon
        firstVC?.species = self.species
        firstVC?.innerTableViewScrollDelegate = self
        let page1 = Page(_vc: firstVC!)
        pageCollection.pages.append(page1)
        
        let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "EvolutionsViewController") as? EvolutionsViewController
        secondVC?.innerTableViewScrollDelegate = self
        secondVC?.pokemon = self.pokemon
        secondVC?.species = self.species
        let page2 = Page(_vc: secondVC!)
        pageCollection.pages.append(page2)
        
        let thirdVC = self.storyboard?.instantiateViewController(withIdentifier: "MovesViewController") as? MovesViewController
        thirdVC?.innerTableViewScrollDelegate = self
        thirdVC?.pokemon = self.pokemon
        thirdVC?.species = self.species
        let page3 = Page(_vc: thirdVC!)
        pageCollection.pages.append(page3)
        
        let initialPage = 0
        
        pageViewController.setViewControllers([pageCollection.pages[initialPage].vc],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        childBottom.addSubview(pageViewController.view)
        childBottom.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.leadingAnchor.constraint(equalTo: childBottom.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: childBottom.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: childBottom.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: childBottom.bottomAnchor).isActive = true
    }
    
    func setPageView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        
        pageViewController.setViewControllers([pageCollection.pages[index].vc],
                                              direction: navigationDirection,
                                              animated: true,
                                              completion: nil)
    }
    
    // MARK: - View action
    
    @IBAction func tappedLibSegment(_ sender: Any) {
        
        var direction: UIPageViewController.NavigationDirection
        
        if segmentFromLib.index == 0 {
            
            direction = .reverse
            
            setPageView(toPageWithAtIndex: 0, andNavigationDirection: direction)
        } else if segmentFromLib.index == 1{
            
            direction = oldIndex == 0 ? .forward : .reverse
            
            setPageView(toPageWithAtIndex: 1, andNavigationDirection: direction)
        } else {
            direction = .forward
            
            setPageView(toPageWithAtIndex: 2, andNavigationDirection: direction)
        }
        oldIndex = segmentFromLib.index
    }

    func fetchSpecies() {
        
        guard let url = URL(string: (pokemon!.species.url)) else {
            return
        }
        AF.request(url)
        .validate()
        .responseDecodable(of : SpeciesPoke.self)
        {
            (response) in guard let specie = response.value else {
                return
            }

            self.species = specie
            let text = specie.flavorTextEntries.first(where: {$0.language.name == "en" && $0.version.name == "alpha-sapphire"})?.flavorText.replacingOccurrences(of: "\n", with: " ")
            self.textStart.text = text
            self.setupBottom()
        }
    }
}

extension PokemonDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pendingVC = pendingViewControllers.first else { return }
        let index = pageCollection.pages.firstIndex(where: { $0.vc == pendingVC })
        segmentFromLib.setIndex(index ?? 0, animated: true, shouldSendValueChangedEvent: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        let index = pageCollection.pages.firstIndex(where: { $0.vc == currentVC })
        segmentFromLib.setIndex(index ?? 0, animated: false, shouldSendValueChangedEvent: false)
        guard index != nil else { return }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                
                return pageCollection.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
}

extension PokemonDetailViewController: InnerTableViewScrollDelegate {
    
    var currentHeaderHeight: CGFloat {
        
        return headerViewHeightConstraint.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        
        headerViewHeightConstraint.constant -= scrollDistance
        
        
        if headerViewHeightConstraint.constant > topViewInitialHeight {
            
            headerViewHeightConstraint.constant = topViewInitialHeight
        }
        
        if headerViewHeightConstraint.constant < topViewFinalHeight {
            
            headerViewHeightConstraint.constant = topViewFinalHeight
        }
        
        let percentage = (headerViewHeightConstraint.constant) / 100
        
        self.stickyHeaderView.alpha = percentage
    }
    
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        
        let topViewHeight = headerViewHeightConstraint.constant
        
        if topViewHeight <= topViewFinalHeight {
            
            scrollToFinalView()
            
        } else if topViewHeight <= topViewInitialHeight {
            
            switch scrollDirection {
                
            case .Down: scrollToInitialView()
            case .Up: scrollToFinalView()
                
            }
            
        } else {
            
            scrollToInitialView()
        }
        
        let percentage = (headerViewHeightConstraint.constant) / 100
        
        UIView.animate(withDuration: 0.25) {
            self.stickyHeaderView.alpha = percentage
        }
        
    }
    
    func scrollToInitialView() {
        
        let topViewCurrentHeight = stickyHeaderView.frame.height
        
        let distanceToBeMoved = abs(topViewCurrentHeight - topViewInitialHeight)
        
        var time = distanceToBeMoved / 500
        
        if time < 0.25 {
            
            time = 0.25
        }
        
        headerViewHeightConstraint.constant = topViewInitialHeight
        // layoutIfNeeded
        UIView.animate(withDuration: TimeInterval(time), animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    func scrollToFinalView() {
        
        let topViewCurrentHeight = stickyHeaderView.frame.height
        
        let distanceToBeMoved = abs(topViewCurrentHeight - topViewFinalHeight)
        
        var time = distanceToBeMoved / 500
        
        if time < 0.25 {
            
            time = 0.25
        }
        
        headerViewHeightConstraint.constant = topViewFinalHeight
        
        UIView.animate(withDuration: TimeInterval(time), animations: {
            
            self.view.layoutIfNeeded()
        })
    }
}



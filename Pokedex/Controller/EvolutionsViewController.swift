//
//  EvolutionsViewController.swift
//  Pokedex
//
//  Created by Nguyen on 11/08/2022.
//

import UIKit
import Alamofire

struct InfoPoke {
    var name : String
    //var img : String
}

class EvolutionsViewController: UIViewController {

    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    @IBOutlet weak var tableEvolution: UITableView!
    
    var pokemon: Pokemon?
    var species : SpeciesPoke?
    var listInfoPoke = [String]()
    var chain : Evolution?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEvolution()
        // Do any additional setup after loading the view.
    }
    func fetchEvoluChain(){
        guard let url = URL(string: (species!.evolution_chain.url)) else {
            return
        }
        AF.request(url)
        .validate()
        .responseDecodable(of: Evolution.self)
        {
        (response) in guard let chain = response.value else { return }
            self.chain = chain
            var i = chain.chain
            while (i.evolves_to[0] != nil) {
                self.listInfoPoke.append(i.species.name)
                i = i.evolves_to[0]
                self.tableEvolution.reloadData()
            }
        }
        
        
        
    }
    
    func fetchEvolution(){
        for i in listInfoPoke {
            let name : String = i
                AF.request("https://pokeapi.co/api/v2/pokedex/\(name)/")
                .validate()
                .responseDecodable(of: Pokemon.self)
                {
                (response) in guard let chain = response.value else { return }
                }
        }
    }

}
//extension EvolutionsViewController : UITableViewDelegate,UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return listInfoPoke.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return
//    }
//
//    
//}

extension EvolutionsViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = innerTableViewScrollDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            if let parentVC = parent?.parent as? PokemonDetailViewController {
                if delta > 0,
                   topViewUnwrappedHeight > parentVC.topViewHeightConstraintRange?.lowerBound ?? 0,
                   scrollView.contentOffset.y > 0 {
                    
                    
                    dragDirection = .Up
                    innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                    scrollView.contentOffset.y -= delta
                }
                
                
                if delta < 0,
                   topViewUnwrappedHeight < parentVC.topViewHeightConstraintRange?.upperBound ?? 0,
                   scrollView.contentOffset.y < 0 {
                    
                    dragDirection = .Down
                    innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                    scrollView.contentOffset.y -= delta
                }
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
    }
}

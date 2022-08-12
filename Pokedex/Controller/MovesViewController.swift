//
//  MovesViewController.swift
//  Pokedex
//
//  Created by Nguyen on 11/08/2022.
//

import UIKit
import Alamofire


class MovesViewController: UIViewController {

    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    
    @IBOutlet weak var movesTable: UITableView!
    
    var pokemon: Pokemon?
    var species: SpeciesPoke?
    var moves = [Moves]()
    var moves2 = [Moves]()
    var detailMove = [MoveDetail]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMoves()
        self.movesTable.reloadData()
        print(moves2)
        for i in moves2 {
            fetchMove(link: i.move.url)
        }
    }
    func fetchMoves(){
        
        for i in pokemon!.moves {
            if i.versionGroupDetails.first(where: { $0.level_learned_at > 0 && $0.move_learn_method.name == "level-up" && $0.version_group.name == "omega-ruby-alpha-sapphire" }) != nil {
                moves.append(i)
            }
        }
        
        moves2 = moves.sorted { $0.versionGroupDetails.first(where: { $0.level_learned_at > 0 && $0.move_learn_method.name == "level-up" && $0.version_group.name == "omega-ruby-alpha-sapphire" })!.level_learned_at < $1.versionGroupDetails.first(where: { $0.level_learned_at > 0 && $0.move_learn_method.name == "level-up" && $0.version_group.name == "omega-ruby-alpha-sapphire" })!.level_learned_at }
        
        for i in moves2 {
            fetchMove(link: i.move.url)
            self.movesTable.reloadData()
        }
    }
    
    func fetchMove(link : String) {
        guard let url = URL(string: link) else {
            return
        }
        AF.request(url)
            .validate()
            .responseDecodable(of: MoveDetail.self){
                (response) in guard let detail = response.value else {
                    return
                }
                self.detailMove.append(detail)
                self.movesTable.reloadData()
            }
    }

}
extension MovesViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moves2.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moveCell",for: indexPath) as! MovesCell
        let item = moves2[indexPath.row]
        cell.nameMove.text = item.move.name.capitalized
        cell.level.text = "Level " +  String(item.versionGroupDetails.first(where: { $0.move_learn_method.name == "level-up" && $0.version_group.name == "omega-ruby-alpha-sapphire" })!.level_learned_at)
        //cell.imgPower.image = UIImage(named: detailMove[indexPath.item].type.name)
        return cell
    }
    
    
}

extension MovesViewController : UIScrollViewDelegate {
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

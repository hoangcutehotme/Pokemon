//
//  PokemonStatsViewController.swift
//  Pokedex
//
//  Created by Finofantashi on 08/08/2022.
//

import UIKit
import Alamofire
import Kingfisher
import ALProgressView

class PokemonStatsViewController: UIViewController{
    
    @IBOutlet weak var scrollBar: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var typeTag: UIImageView!
    @IBOutlet weak var script: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var statCollection: UICollectionView!
    @IBOutlet weak var typeCollection: UICollectionView!
    @IBOutlet weak var spriteCollection: UICollectionView!
    
    @IBOutlet var tableAbility: UITableView!
    
    //Breeding
    @IBOutlet weak var eggGroup1: UILabel!
    @IBOutlet weak var eggGroup2: UILabel!
    
    @IBOutlet weak var Steps: UILabel!
    @IBOutlet weak var cycle: UILabel!
    
    @IBOutlet weak var Male: UILabel!
    @IBOutlet weak var Female: UILabel!
    //Capture
    @IBOutlet weak var habitat: UILabel!
    @IBOutlet weak var generation: UILabel!
    @IBOutlet weak var percent: UILabel!
    //ProgressRing
    @IBOutlet weak var viewGenderRing: UIView!
    private lazy var genderProgressRing = ALProgressRing()
    @IBOutlet weak var viewCaptureRing: UIView!
    private lazy var captureProgressRing = ALProgressRing()
    
    var stats : [String] = ["HP", "ATK", "DEF", "SATK", "SDEF", "SPD"]
    var normalShiny : [String] = ["Normal","Shiny"]
    var double = Set<String>()
    var half = Set<String>()
    var no = Set<String>()
    
    var pokemon : Pokemon?
    var effect = [Effect]()
    var species : SpeciesPoke?
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GUI()
        fetchSpecies()
        fetchType(url: pokemon!.types[0].pokeType.url)
        if (pokemon!.types.count == 2)
        {
            fetchType(url: pokemon!.types[1].pokeType.url)
        }
        fetchAbilities()
        setUpData()
        scrollBar.delegate = self
        statCollection.delegate = self
        statCollection.dataSource = self
        typeCollection.delegate = self
        typeCollection.dataSource = self
        spriteCollection.delegate = self
        spriteCollection.dataSource = self
        tableAbility.rowHeight = UITableView.automaticDimension
        tableAbility.estimatedRowHeight = 200
        
        // Do any additional setup after loading the view.
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
        }
    }
    func GUI() {
        setGradientBackground()
        
    }
    func setUpData(){
        //Breeding
        //EggGroup
        eggGroup1.text = species?.eggGroups[0].name.capitalized
        if species!.eggGroups.count > 1 {
            eggGroup2.text = species?.eggGroups[1].name.capitalized
        }else {
            eggGroup2.text = ""
        }
        //Hatch Time
        let x : Int = species!.hatchCounter
        cycle.text = String(x) + " Cycles"

//        //ProgressRing
        let value = 0.125
        ringGender(value: Float(value))
        //Capture
        habitat.text = species?.habitat.name.capitalized
        generation.text = species?.generation.name.capitalized

        percent.text = String(species!.captureRate) + "%"
        let per = Float(species!.captureRate) / 100
        ringCapture(value : Float(per))
    }
    
    func ringGender(value : Float) {
        viewGenderRing.addSubview(genderProgressRing)
        genderProgressRing.translatesAutoresizingMaskIntoConstraints = false
        genderProgressRing.centerXAnchor.constraint(equalTo: viewGenderRing.centerXAnchor).isActive = true
        genderProgressRing.centerYAnchor.constraint(equalTo: viewGenderRing.centerYAnchor).isActive = true
                  // Make sure to set the view size
        genderProgressRing.widthAnchor.constraint(equalToConstant: 45).isActive = true
        genderProgressRing.heightAnchor.constraint(equalToConstant: 45).isActive = true
        genderProgressRing.setProgress(value, animated: true)
        
        genderProgressRing.startAngle = -.pi / 2 //
        genderProgressRing.endAngle = 1.5 * .pi // The end angle of the ring to end drawing.
        genderProgressRing.startGradientPoint = .init(x: 0.5, y: 0) // The starting poin of the gradient
        genderProgressRing.endGradientPoint = .init(x: 0.5, y: 1) // The ending position of the gradient.
        genderProgressRing.lineWidth = 10
        genderProgressRing.startColor = UIColor(named: "cl-#CE71E1")!
        genderProgressRing.grooveColor = UIColor(named: "cl-80B6F4")!
        genderProgressRing.ringWidth = 4
        genderProgressRing.grooveWidth = 4
    }
    
    func ringCapture(value : Float){
        viewCaptureRing.addSubview(captureProgressRing)
        captureProgressRing.translatesAutoresizingMaskIntoConstraints = false
        captureProgressRing.centerXAnchor.constraint(equalTo: viewCaptureRing.centerXAnchor).isActive = true
        captureProgressRing.centerYAnchor.constraint(equalTo: viewCaptureRing.centerYAnchor).isActive = true
                  // Make sure to set the view size
        captureProgressRing.widthAnchor.constraint(equalToConstant: 45).isActive = true
        captureProgressRing.heightAnchor.constraint(equalToConstant: 45).isActive = true
        captureProgressRing.setProgress(value, animated: true)
        captureProgressRing.startAngle = -.pi / 2 //
        captureProgressRing.endAngle = 1.5 * .pi // The end angle of the ring to end drawing
        captureProgressRing.lineWidth = 10
        captureProgressRing.startColor = UIColor(named: "cl-80B6F4")!
        captureProgressRing.endColor = UIColor(named: "cl-80B6F4")!
        captureProgressRing.grooveColor = .systemGray4
        captureProgressRing.ringWidth = 4
        captureProgressRing.grooveWidth = 4
    }
    
    func setGradientBackground() {
        let colorLeft =  UIColor(red: 85.0/255.0, green: 194.0/255.0, blue: 251.0/255.0, alpha: 1.0).cgColor
        let colorRight = UIColor(red: 145.0/255.0, green: 235.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft, colorRight]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    
    // fetch all abilities
    func fetchAbilities(){
        for i in pokemon!.abilities {
            guard let url = URL(string: i.ability.url) else {return}
            fetchAbility(url: url)
        }
    }
    func fetchAbility(url : URL){
            AF.request(url)
            .validate()
            .responseDecodable(of: Effect.self)
            {
            (response) in guard let effect1 = response.value else { return }
                self.effect.append(effect1)
                self.tableAbility.reloadData()
            }
    }
    // loading image
    func loadingImg(url: String) {
        let url = URL(string: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print("Error fetching the image!")
                } else {
                    self.img.image = UIImage(data: data!)
                }
            }
        }
        dataTask.resume()
    }
    // fetch type of power
    func fetchType(url: String) {
        AF.request(url)
            .validate()
            .responseDecodable(of: DamageRelations.self)
        {
            (response) in guard let items = response.value else { return }
            for i in items.all.doubleDamageFrom
            {
                self.double.insert(i.name)
            }
            for i in items.all.halfDamageFrom
            {
                self.half.insert(i.name)
            }
            for i in items.all.noDamegeFrom
            {
                self.no.insert(i.name)
            }
            self.typeCollection.reloadData()
        }
    }
    // fetch img Normal Shiny
}

extension PokemonStatsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(collectionView == statCollection)
        {
            return stats.count
        }
        else if (collectionView == typeCollection)
        {
            return type.count
        }
        else {
            return normalShiny.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(collectionView == statCollection)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatCollectionViewCell", for: indexPath) as! StatCollectionViewCell
            cell.statName.text = stats[indexPath.row]
            cell.baseStat.text = String(format: "%03d",(pokemon?.stats[indexPath.row].baseStat)!)
            cell.statPercent.progress = Float((pokemon?.stats[indexPath.row].baseStat)!) / 150
            
            return cell
        }
        else if (collectionView == typeCollection)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCollectionViewCell", for: indexPath) as! TypeCollectionViewCell
            cell.icon.image = UIImage(named: type[indexPath.row]!)
            cell.value.text = "1x"
            if (self.double.contains(type[indexPath.row]!))
            { cell.value.text = "2x"}
            if (self.half.contains(type[indexPath.row]!))
            { cell.value.text = "1/2x"}
            if (self.no.contains(type[indexPath.row]!))
            { cell.value.text = "0x"}
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! NormalShiny
            if(normalShiny[indexPath.row] == "Normal"){
                cell.titleImg.text = "Normal"
                let url = URL(string: pokemon!.sprites.other.official.img)
                cell.img.kf.setImage(with: url)
            }
            else {
                cell.titleImg.text = "Shiny"
                let url = URL(string: pokemon!.sprites.other.official.img)
                cell.img.kf.setImage(with: url)
                
            }
            return cell
        }
    }
}

extension PokemonStatsViewController: UIScrollViewDelegate {
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
extension PokemonStatsViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return effect.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "abilityCell") as! AbilityCell
        let item = pokemon?.abilities[indexPath.row]
        cell.nameAbility.text = item?.ability.name.capitalized
        let text = effect[indexPath.row].flavorTextEntries.first(where: {$0.language.name == "en" && $0.versionGroup.name == "x-y"})?.flavorText.replacingOccurrences(of: "\n", with: " ")
        cell.decripText.text = text
        if item?.isHidden == true {
            cell.hideImg.image = UIImage(systemName: "eye.slash")
        }
        else {
            cell.hideImg.image = nil
        }
        return cell
    }
    
}
// Breeding


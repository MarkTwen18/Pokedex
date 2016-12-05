//
//  ViewController.swift
//  Pokedex
//
//  Created by İlyas İsabekov on 11/8/16.
//  Copyright © 2016 İlyas İsabekov. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    

    var pokemon: [Pokemon] = []
    var filterPokemon = [Pokemon]()
    var musicPlayer: AVAudioPlayer!
    var isPlaying = true
    var timer:Timer!
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.default
        initAudio()
        parsePokemonCSV()
        
}
    
    
    func initAudio() {
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        }catch let err as Error {
            print(err.localizedDescription)
        }
    }
    
    
    func updateTime() {
        let currentTime = Int(musicPlayer.currentTime)
        let minutes = currentTime/60
        var seconds = currentTime - minutes * 60
        
    }
 
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let poke: Pokemon!
            
            if inSearchMode {
                poke = filterPokemon[indexPath.row]
            }else{
                poke = pokemon[indexPath.row]
            }
            
            
            
            cell.configureCell(pokemon: poke)
            return cell
            
        }else{
            return UICollectionViewCell()
        }
    }
    
    
    
    func parsePokemonCSV() {
    
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")
        
        do {
            let csv = try CSV(contentsOfURL: path!)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name: name, pokedexId: pokeId)
                pokemon.append(poke)
            }
            
        }catch let err as Error {
            print(err.localizedDescription)
        }
    }
    
    
    // CollectionView funcs

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        performSegue(withIdentifier: "PokemonDetailVC", sender: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filterPokemon.count
        }
        return pokemon.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 105, height: 105)
        
    }
    
    

    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            collection.reloadData()
        }else{
            inSearchMode = true
            
            let lower = searchBar.text!.lowercased()
            filterPokemon = pokemon.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destination as? PokemonDetailVC {
                
                let poke: Pokemon!
                let indexPath = self.collection.indexPathsForSelectedItems!.first!
                
                if inSearchMode {
                    poke = filterPokemon[indexPath.row]
                }else {
                    poke = pokemon[indexPath.row]
                }
                
                detailsVC.pokemon = poke
            }
        }
    }

    
    @IBAction func musicBtn(_ sender: UIButton!) {
        
        if isPlaying {
            musicPlayer.pause()
            isPlaying = false
            sender.alpha = 0.2 //fading music button
        } else {
            musicPlayer.play()
            isPlaying = true
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
            sender.alpha = 1
        }
    }
    
    }


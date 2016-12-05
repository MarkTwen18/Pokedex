//
//  Pokemon.swift
//  Pokedex
//
//  Created by İlyas İsabekov on 11/8/16.
//  Copyright © 2016 İlyas İsabekov. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _typeLbl: String!
    private var _heightLbl: String!
    private var _weightLbl: String!
    private var _armorLbl: String!
    private var _pokedexIDLbl: String!
    private var _attackLbl: String!
    private var _currentEvoImg: String!
    private var _weight: String!
    private var _evoLbl: String!
    private var _pokemonUrl: String!
    private var _description: String!
    private var _nextEvolutionLvl: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionId: String!
    
    var nextEvolutionLvl: String {
        get {
            if _nextEvolutionLvl == nil {
                _nextEvolutionLvl = ""
            }
            return _nextEvolutionLvl
        }
    }
    
    var nextEvolutionTxt: String {
        
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        
        return _nextEvolutionTxt
    }
    
    var nextEvolutionId: String {
        
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var description: String {
        
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _typeLbl == nil {
            _typeLbl = ""
        }
        return _typeLbl
    }
    
    var defense: String {
        if _armorLbl == nil {
            _armorLbl = ""
        }
        return _armorLbl
    }
    
    var height: String {
        if _heightLbl == nil {
            _heightLbl = ""
        }
        return _heightLbl
    }
    
    var weight: String {
        if _weightLbl == nil {
            _weightLbl = ""
        }
        return _weightLbl
    }
    
    var attack: String {
        if _attackLbl == nil {
            _attackLbl = ""
        }
        return _attackLbl
    }
    
    
    var name: String {
        
        return _name
        
    }
    
    var pokedexId: Int {
        
        return _pokedexId
        
    }
    
    init(name: String,pokedexId: Int){
        
        self._name = name
        self._pokedexId = pokedexId
        _pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        
        Alamofire.request(_pokemonUrl).responseJSON {(response:DataResponse<Any>) -> Void in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    if let dict = data as? Dictionary<String,AnyObject> {
                        if let weight = dict["weight"] as? String{
                            self._weightLbl = weight
                        }
                        if let height = dict["height"] as? String{
                            self._heightLbl = "\(height)"
                        }
                        if let attack = dict["attack"] as? Int {
                            self._attackLbl = "\(attack)"
                        }
                        if let defense = dict["defense"] as? Int {
                            self._armorLbl = "\(defense)"
                        }
                        print(self._weightLbl)
                        print(self._heightLbl)
                        print(self._attackLbl)
                        print(self._armorLbl)
                        
                        if let types = dict["types"] as? [Dictionary<String,String>], types.count > 0 {
                            
                            if let name = types[0]["name"]{
                                self._typeLbl = name
                            }
                            if types.count > 1 {
                                for x in 1 ..< types.count {
                                    if let name = types[x]["name"]{
                                        self._typeLbl! += "/\(name)"
                                    }
                                }
                            }
                        }else{
                            self._typeLbl = ""
                        }
                        print(self._typeLbl)
                        
                        if let descArr = dict["descriptions"] as? [Dictionary<String, String>], descArr.count > 0 {
                            
                            if let url = descArr[0]["resource_uri"] {
                                let nsurl = URL(string: "\(URL_BASE)\(url)")!
                                
                                Alamofire.request(nsurl).responseJSON { response in
                                    
                                    let desResult = response.result
                                    if let descDict = desResult.value as? Dictionary<String, AnyObject> {
                                        
                                        if let description = descDict["description"] as? String {
                                            self._description = description
                                            print(self._description)
                                        }
                                    }
                                    
                                    completed()
                                }
                            }
                            
                        } else {
                            self._description = ""
                        }
                        if let evolutions = dict["evolutions"] as? [Dictionary<String,AnyObject>], evolutions.count > 0{
                            
                            if let to = evolutions[0]["to"] as? String {
                                
                                //Can't support mega pokemon right now but
                                //api still has mega data
                                if to.range(of: "mega") == nil {
                                    
                                    if let uri = evolutions[0]["resource_uri"] as? String {
                                        
                                        let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                        
                                        let num = newStr.replacingOccurrences(of: "/", with: "")
                                        
                                        self._nextEvolutionId = num
                                        self._nextEvolutionTxt = to
                                        
                                        if let lvl = evolutions[0]["level"] as? Int {
                                            self._nextEvolutionLvl = "\(lvl)"
                                        }
                                        
                                        print(self._nextEvolutionId)
                                        print(self._nextEvolutionTxt)
                                        print(self._nextEvolutionLvl)
                                        
                                    }
                                }
                                
                            }
                            
                        }
                }
                break
                
                    
            }
            case .failure(_):
                print(response.result.error!)
                break

        }
       
    }
}
}


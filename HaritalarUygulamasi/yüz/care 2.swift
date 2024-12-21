//
//  care.swift
//  SkinCareIntroduction
//
//  Created by Beyza Gürbüz on 8.10.2024.
//

import Foundation
import UIKit
class FaceCare {
    var isim : String
    var bolge : String
    var aciklama : String
    var gorsel : UIImage
    
    init(isim : String, bolge : String,aciklama : String, gorsel : UIImage) {
        
        self.isim = isim
        self.bolge = bolge
        self.aciklama = aciklama
        self.gorsel = gorsel
    }
    
}

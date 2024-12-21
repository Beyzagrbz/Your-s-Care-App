//
//  DetailsViewController.swift
//  HaritalarUygulamasi
//
//  Created by Beyza Gürbüz on 21.10.2024.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    
    @IBOutlet weak var labelBilgi: UILabel!
    
    @IBOutlet weak var textBilgi: UITextView!
    
    var secilenUrun : Care?
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text=secilenUrun?.isim
        labelBilgi.text=secilenUrun?.bolge
        textBilgi.text=secilenUrun?.aciklama
        imageView.image=secilenUrun?.gorsel
        

       
    }
 
    
    

 

}

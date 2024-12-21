//
//  FaceDetailsViewController.swift
//  HaritalarUygulamasi
//
//  Created by Beyza Gürbüz on 23.10.2024.
//

import UIKit

class FaceDetailsViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelBilgi: UILabel!
    @IBOutlet weak var textBilgi: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var secilenUrun : FaceCare?
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text=secilenUrun?.isim
        labelBilgi.text=secilenUrun?.bolge
        textBilgi.text=secilenUrun?.aciklama
        imageView.image=secilenUrun?.gorsel
        

       
    }
}

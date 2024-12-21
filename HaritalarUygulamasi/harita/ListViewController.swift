//
//  ListViewController.swift
//  HaritalarUygulamasi
//
//  Created by Beyza Gürbüz on 9.10.2024.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenYerIsmi = ""
    var secilenyerId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
/*
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector (addButtonTapped))*/
        veriAl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("yeniYerOlusturuldu") , object: nil)
    }
    
    
   @objc func veriAl(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult> (entityName: "Yer")
        request.returnsObjectsAsFaults = false
        do{
            let sonuclar = try context.fetch(request)
            print(sonuclar)
            if sonuclar.count > 0 {
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let isim =  sonuc.value(forKey: "isim") as? String{ isimDizisi.append(isim)
                        
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        idDizisi.append(id)
    
                    }
                }
                tableView.reloadData()
            }
        }catch{
            print("Hata")
        }
        
    }
    
    
    @objc func addButtonTapped(){
        print("Add button tapped!")
        secilenYerIsmi = " "
        secilenyerId = nil
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]    
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerIsmi = isimDizisi[indexPath.row]
        secilenyerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC"{
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.secilenIsim = secilenYerIsmi
            destinationVC.secilenId = secilenyerId
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Core Data'dan veriyi silmek için gerekli hazırlık
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            let uuidString = idDizisi[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        context.delete(sonuc) // Core Data'dan sil
                    }
                    
                    // Dizilerden ilgili elemanları sil
                    isimDizisi.remove(at: indexPath.row)
                    idDizisi.remove(at: indexPath.row)
                    
                    // Core Data'yı güncelle
                    do {
                        try context.save()
                        print("Kayıt başarıyla silindi.")
                    } catch {
                        print("Core Data güncellenirken hata oluştu: \(error.localizedDescription)")
                    }
                    
                    // Tablodaki değişikliği yansıt
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } catch {
                print("Core Data'dan veri silme sırasında hata: \(error.localizedDescription)")
            }
        }
    }

/*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar=try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row]{
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                } catch {
                                    print("hata")
                                }
                                break
                            }
                        }
                    }
                }

            } catch {
                print("hata")
            }
        }
    }
*/
}

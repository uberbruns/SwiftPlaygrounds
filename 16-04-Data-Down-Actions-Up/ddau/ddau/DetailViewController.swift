//
//  DetailViewController.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit


struct DetailAction : ActionPackage {
    let name: String
}


struct DetailData : DataPackage {
    let name: String
}


class DetailViewController: UIViewController, DataReceiver {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
    deinit {
        print("Gone")
    }


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        sendActionPackageUp(DetailAction(name: "Action from DetailViewController"))
    }
    
    
    static func directDataPackage(dataPackage: DataPackage) -> DataDirection {
        return .HandleHere
    }

    
    func receiveDataPackage(dataPackage: DataPackage) -> DataReceipt {
        switch dataPackage {
        case let package as DetailData :
            print(self, package)
            return .HandledDefinitely
        default:
            return .SendDown
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
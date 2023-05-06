//
//  OrderConfirmationViewController.swift
//  OrderApp
//
//  Created by Christian Manzaraz on 05/05/2023.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    
    @IBOutlet var confirmationLabel: UILabel!
    
    let minutesToPrepare: Int
    
    init?(coder: NSCoder ,minutesToPrepare: Int) {
        self.minutesToPrepare = minutesToPrepare
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Init(coder: ) has not been implemented ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        confirmationLabel.text = "¡Gracias por tu pedido! El tiempo de espera es de aproximadamente \(minutesToPrepare) minutos."
    }
    
}

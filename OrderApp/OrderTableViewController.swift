//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Christian Manzaraz on 02/05/2023.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
    var order = Order()
    var minutesToPrepareOrder = 0
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Cancel image fetching tasks that are no longer needed
        imageLoadTasks.forEach { key, value in value.cancel() }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    @IBSegueAction func confirmOrder(_ coder: NSCoder) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepareOrder)
    }
    
    @IBAction func unwindToOrderList(_ segue: UIStoryboardSegue) {
        if segue.identifier == "dismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        
        let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
        
        let alertController = UIAlertController(title: "Confirmar Órden", message: "Está a punto de enviar su pedido por un total de \(formattedTotal)", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Enviar", style: .default, handler: { _ in
            self.uploadOrder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func uploadOrder() {
        let  menuIds = MenuController.shared.order.menuItems.map { $0.id }
        Task.init {
            do {
                let minutesToPrepare = try await MenuController.shared.submitOrder(forMenuIDs: menuIds)
                minutesToPrepareOrder = minutesToPrepare
                performSegue(withIdentifier: "confirmOrder", sender: nil)
            } catch {
                displayError(error, title: "Envío de Pedido Fallido")
            }
        }
        
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Descartar", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return order.menuItems.count
        return MenuController.shared.order.menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath)

        // Configure the cell...
        configure(cell, forItemAt: indexPath)

        return cell
    }
    
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        
        
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                // Image was returned
                if
                    let currentIndexPath = self.tableView.indexPath(for: cell),
                    currentIndexPath == indexPath
                {
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Cancel the image fetching task if it's no longer needed
        imageLoadTasks[indexPath]?.cancel()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

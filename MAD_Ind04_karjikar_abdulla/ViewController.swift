//
//  ViewController.swift
//  MAD_Ind04_karjikar_abdulla
//
//  Created by Abdulla Karjikar on 3/31/22.
//

import UIKit

class ViewController: UIViewController {
    
    // Created Structure to store the "Table Structure"
    struct StateDetails: Decodable{
        var ID: String
        var name: String
        var nickname: String
    }
    
    // Structure to store the response from the API call.
    struct JSONResponse: Decodable {
        var allDataRetrieved: Bool
        var stateDetails : [StateDetails]
    }
    
    // This variable will store the name and nick name from after retrieving from server.
    var results = [(String, String)]()
    
    // This outlet will be used to refresh the table view once the API returns the details from server.
    @IBOutlet weak var tableViewController_: UITableView!
    
    // To add spinner while data is being fetched.
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        // Starting to animate spinner while the API completes its call and once spinner is stopped it will be hidden.
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        super.viewDidLoad()
        
        // this function call will retrieve the information from the Server and once loaded it will stop the spinner and reload the table view.
        getStateInformation{
            data in
            self.results = data
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.tableViewController_.reloadData()
            }
        }
        
        tableViewController_.dataSource = self
    }
    
    
    // API call
    func getStateInformation(comp: @escaping ([(String, String)])->()){
        
        // Setting the URL
        let urlString =  "https://cs.okstate.edu/~akarjik/retrieveStateDetailsAPIVersion2.php"
        guard let url = URL(string: urlString)
        else
        {
            return
        }
        
        // This closure will get the data from URL and will check if the data being returned is empty or is there any error.
        let task = URLSession.shared.dataTask(with: url)
        {(data, response, error) -> Void in
            // Check to see if any error was encountered.
            guard error == nil  else {
                print("URL Session error: \(error!)")
                return
            }
            // Check to see if we received any data.
            guard let data = data else {
                print("No data received")
                return
            }
            
            var resultLocal: [(String, String)] = []
            
            do {
                // Decoding the JSON response in the JSONResponse structure.
                let jsonResponse = try JSONDecoder().decode(JSONResponse.self,
                                                            from: data)
                // Storing just name and nickname for all the rows into local object as we have ID as well in the response being returned.
                for eachStateDetail in jsonResponse.stateDetails{
                    resultLocal.append((eachStateDetail.name, eachStateDetail.nickname))
                }
                // Returning the data which is in form [(String, String)]
                comp(resultLocal)
                
            } catch let error as NSError {
                print("Error serializing JSON Data: \(error)")
            }
            
        }
        task.resume()
    }
}


// Extending the ViewController to add numberOfRowsInSection and cellForRowAt for table view.
extension ViewController: UITableViewDataSource{
    
    // This will return the number of elements stored in the "results" array.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    // This will load the each element on to the table veiw and will reuse the cell if it goes out of screen.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateTableList", for: indexPath)
        
        // Fetching the cell data from the array. indexPath[1] holds the each values for a section.
        let cellData = results[indexPath[1]]
        
        // Setting StateName in the title field of each row of table view.
        cell.textLabel?.text = cellData.0
        
        // Setting NickName in the subtitle field of each row of table view.
        cell.detailTextLabel?.text = cellData.1
        
        return cell
        
    }
}




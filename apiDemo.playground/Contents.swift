import Foundation

// The following code is an example of making a put request to our heroku api service;
// all api calls follow a similar format, so we only showing one example

let url = URL(string: "https://attendify.herokuapp.com/students")!
var request = URLRequest(url: url)
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.httpMethod = "POST"



let dict:[String:String] = ["first_name": "Frank", "last_name": "Liao", "andrew_id": "fliao"]
let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

request.httpBody = jsonData

let task = URLSession.shared.dataTask(with: request) { data, response, error in
  guard let data = data, error == nil else {                                                 // check for fundamental networking error
    print("error")
    return
  }
  
  if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 201 {           // check for http errors
    print("statusCode should be 201, student was create successfully!!!!\n\n\n")
    print(response)
  }
//  
//  let responseString = String(data: data, encoding: .utf8)
//  print(responseString)
}
task.resume()

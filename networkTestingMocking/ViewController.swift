//
//  ViewController.swift
//  networkTestingMocking
//
//  Created by Bilal on 11.07.2022.
//

import UIKit
import OHHTTPStubs

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        stub(condition: isHost("reqres.in")) { req in
            let stubPath = OHPathForFile("samplejson.json", type(of: self))
            return fixture(filePath: stubPath!, headers: nil)
        }

        fetchFilms { datum in
            print(datum)
            datum.map{ print($0.firstName)}
        }
    }
}

extension ViewController {
    func fetchFilms(completionHandler: @escaping ([Datum]) -> Void) {
        let url = URL(string: "https://reqres.in/api/users?page=2")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if let error = error {
            print("Error with fetching films: \(error)")
            return
          }
          
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(response)")
            return
          }

          if let data = data,
            let filmSummary = try? JSONDecoder().decode(RandomUser.self, from: data) {
              completionHandler(filmSummary.data )
          }
        })
        task.resume()
      }
}

// MARK: - RandomUser
struct RandomUser: Codable {
    let page, perPage, total, totalPages: Int
    let data: [Datum]
    let support: Support

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, support
    }
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int
    let email, firstName, lastName: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}

// MARK: - Support
struct Support: Codable {
    let url: String
    let text: String
}

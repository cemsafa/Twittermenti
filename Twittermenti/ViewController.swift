//
//  ViewController.swift
//  Twittermenti
//
//  Created by Cem Safa on 25.07.2020.
//  Copyright © 2020 Cem Safa. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    let swifter = Swifter(consumerKey: Secrets().consumerKey, consumerSecret: Secrets().consumerSecret)
    let sentimentClassifier = TweetSentimentClassifier()
    let tweetCount = 100
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassify = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassify)
                    }
                }
                self.makePrediction(with: tweets)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for prediction in predictions {
                if prediction.label == "Neg" {
                    sentimentScore -= 1
                } else if prediction.label == "Pos" {
                    sentimentScore += 1
                }
            }
            updateUI(with: sentimentScore)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUI(with sentimentScore: Int) {
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😔"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
    
}

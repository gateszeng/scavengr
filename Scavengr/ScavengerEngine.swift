//
//  ScavengerEngine.swift
//  Scavengr
//
//  Created by Gates Zeng on 3/15/18.
//  Copyright © 2018 Gates Zeng. All rights reserved.
//

import UIKit

class ScavengerEngine: NSObject {
    
    static var currQ: Int = 0
    static var qList = ["Keep it clean and keep it dry. Can you guess? Come on, just try!", "Wash your hands, get a drink. Look for me in the ___." , "What is filled six days a week but if you don't own it you shouldn't take a peek?"]
    static var aList = ["washingmachine", "sink", "mailbox"]
    
    // user entered text, check if command
    class func parseText(text: String) -> String {
        if text.hasPrefix("/") {
            var command: String
            var answer: String?
            
            // separate text at the space
            if text.characters.contains(" ") {
                command = text.substring(to: text.characters.index(of: " ")!)
                answer = text.substring(from: text.characters.index(of: " ")!).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                command = text
                answer = ""
            }
            
            switch (command) {
            // user attempting to try answer
            case "/answer":
                return testAnswer(text: answer!)
            // user attempting to get question
            case "/clue":
                return getClue()
            // invalid request
            default:
                return "Not a Command"
            }

        } else {
            return text
        }
    }
    
    class func testAnswer(text: String) -> String {
        // lower case and remove white space to check answer
        var normalized = text.lowercased()
        normalized = normalized.replacingOccurrences(of: " ", with: "")
        
        if normalized == self.aList[self.currQ] {
            self.currQ += 1
            return "Correct! It is " + text
        } else {
            return "It's not " + text.lowercased() + ". Try again!"
        }
    }
    
    class func getClue() -> String {
        if (self.currQ < self.qList.count) {
            return self.qList[self.currQ]
        } else {
            return "You won!"
        }

    }
    
    // upon receiving a message
    class func newMessage(text:String) -> String {
        // check if it was a synchronization request
        if text.hasPrefix("/") {
            var command: String
            var number: Int?
            // separate number at the space
            if text.characters.contains(" ") {
                command = text.substring(to: text.characters.index(of: " ")!)
                number = Int(text.substring(from: text.characters.index(of: " ")!).trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                command = text
            }
            
            // check if received message was request/response for question number
            switch (command) {
            // someone requesting number, send our number
            case "/reqQ":
                print("reqQ received")
                return "/resQ \(self.currQ)"
            case "/resQ":
                // received response for question number
                print("resQ received: \(number!)")
                // set question number if too low
                if number! > self.currQ {
                    print("setting currQ to \(number!)")
                    self.currQ = number!
                }
                return ""
            default:
                return "/error"
            }
            
        } else {
            return text
        }
    }

}

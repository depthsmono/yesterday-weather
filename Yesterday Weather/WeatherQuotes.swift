//
//  WeatherQuotes.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import Foundation

// MARK: - Weather Quote Models

struct WeatherQuote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
    let work: String

    var attribution: String {
        return "\(author), \(work)"
    }
}

// MARK: - Quote Bank

struct WeatherQuoteBank {
    static let shakespeareQuotes: [WeatherQuote] = [
        WeatherQuote(
            text: "Blow, winds, and crack your cheeks! rage! blow!\nYou cataracts and hurricanes, spout\nTill you have drench'd our steeples, drown'd the cocks!",
            author: "William Shakespeare",
            work: "King Lear"
        ),
        WeatherQuote(
            text: "Rough winds do shake the darling buds of May,\nAnd summer's lease hath all too short a date.",
            author: "William Shakespeare",
            work: "Sonnet 18"
        ),
        WeatherQuote(
            text: "When clouds appear, wise men put on their cloaks;\nWhen great leaves fall, the winter is at hand.",
            author: "William Shakespeare",
            work: "Richard III"
        ),
        WeatherQuote(
            text: "The seasons alter: hoary-headed frosts\nFall in the fresh lap of the crimson rose.",
            author: "William Shakespeare",
            work: "A Midsummer Night's Dream"
        ),
        WeatherQuote(
            text: "Our revels now are ended. These our actors,\nAs I foretold you, were all spirits and\nAre melted into air, into thin air.",
            author: "William Shakespeare",
            work: "The Tempest"
        ),
        WeatherQuote(
            text: "When icicles hang by the wall\nAnd Dick the shepherd blows his nail\nAnd Tom bears logs into the hall\nAnd milk comes frozen home in pail.",
            author: "William Shakespeare",
            work: "Love's Labour's Lost"
        ),
        WeatherQuote(
            text: "The rain it raineth every day.",
            author: "William Shakespeare",
            work: "Twelfth Night"
        ),
        WeatherQuote(
            text: "Poor Tom's a-cold.",
            author: "William Shakespeare",
            work: "King Lear"
        ),
        WeatherQuote(
            text: "Fair is foul, and foul is fair:\nHover through the fog and filthy air.",
            author: "William Shakespeare",
            work: "Macbeth"
        ),
        WeatherQuote(
            text: "Shall I compare thee to a summer's day?\nThou art more lovely and more temperate.",
            author: "William Shakespeare",
            work: "Sonnet 18"
        ),
        WeatherQuote(
            text: "In winter's tedious nights sit by the fire\nWith good old folks, and let them tell thee tales.",
            author: "William Shakespeare",
            work: "Richard III"
        ),
        WeatherQuote(
            text: "What freezings have I felt, what dark days seen!\nWhat old December's bareness everywhere!",
            author: "William Shakespeare",
            work: "Sonnet 97"
        ),
        WeatherQuote(
            text: "Full fathom five thy father lies;\nOf his bones are coral made;\nThose are pearls that were his eyes;\nNothing of him that doth fade.",
            author: "William Shakespeare",
            work: "The Tempest"
        ),
        WeatherQuote(
            text: "There is a tide in the affairs of men,\nWhich taken at the flood, leads on to fortune.",
            author: "William Shakespeare",
            work: "Julius Caesar"
        ),
        WeatherQuote(
            text: "Come not between the dragon and his wrath.",
            author: "William Shakespeare",
            work: "King Lear"
        )
    ]

    static func randomQuote() -> WeatherQuote {
        return shakespeareQuotes.randomElement() ?? shakespeareQuotes[0]
    }
}
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

    static let wordsworthQuotes: [WeatherQuote] = [
        WeatherQuote(
            text: "I wandered lonely as a cloud\nThat floats on high o'er vales and hills,\nWhen all at once I saw a crowd,\nA host, of golden daffodils.",
            author: "William Wordsworth",
            work: "I Wandered Lonely as a Cloud"
        ),
        WeatherQuote(
            text: "The cataracts blow their trumpets from the steep;\nNo more shall grief of mine the season wrong;\nI hear the Echoes through the mountains throng,\nThe Winds come to me from the fields of sleep.",
            author: "William Wordsworth",
            work: "Ode: Intimations of Immortality"
        ),
        WeatherQuote(
            text: "A rainbow and a cuckoo's song\nMay never come together again;\nMay never come\nThis side the tomb.",
            author: "William Wordsworth",
            work: "The Rainbow"
        ),
        WeatherQuote(
            text: "My heart leaps up when I behold\nA rainbow in the sky:\nSo was it when my life began;\nSo is it now I am a man.",
            author: "William Wordsworth",
            work: "My Heart Leaps Up"
        ),
        WeatherQuote(
            text: "The sea that bares her bosom to the moon,\nThe winds that will be howling at all hours,\nAnd are up-gathered now like sleeping flowers.",
            author: "William Wordsworth",
            work: "The World Is Too Much with Us"
        ),
        WeatherQuote(
            text: "The clouds that gather round the setting sun\nDo take a sober colouring from an eye\nThat hath kept watch o'er man's mortality.",
            author: "William Wordsworth",
            work: "Ode: Intimations of Immortality"
        ),
        WeatherQuote(
            text: "Earth has not anything to show more fair:\nDull would he be of soul who could pass by\nA sight so touching in its majesty:\nThis City now doth, like a garment, wear\nThe beauty of the morning; silent, bare.",
            author: "William Wordsworth",
            work: "Composed upon Westminster Bridge"
        ),
        WeatherQuote(
            text: "The frost performs its secret ministry,\nUnhelped by any wind. The owlet's cry\nCame loud—and hark, again! loud as before.",
            author: "William Wordsworth",
            work: "Frost at Midnight"
        ),
        WeatherQuote(
            text: "There was a time when meadow, grove, and stream,\nThe earth, and every common sight\nTo me did seem\nApparelled in celestial light.",
            author: "William Wordsworth",
            work: "Ode: Intimations of Immortality"
        ),
        WeatherQuote(
            text: "And 'tis my faith that every flower\nEnjoys the air it breathes.",
            author: "William Wordsworth",
            work: "Lines Written in Early Spring"
        ),
        WeatherQuote(
            text: "The sunshine is a glorious birth;\nBut yet I know, where'er I go,\nThat there hath passed away a glory from the earth.",
            author: "William Wordsworth",
            work: "Ode: Intimations of Immortality"
        ),
        WeatherQuote(
            text: "The morning rose, in memorable pomp,\nGlorious as e'er I had beheld—in front,\nThe sea lay laughing at a distance; near,\nThe solid mountains shone, bright as the clouds.",
            author: "William Wordsworth",
            work: "The Prelude"
        ),
        WeatherQuote(
            text: "Fair seed-time had my soul, and I grew up\nFostered alike by beauty and by fear:\nMuch favoured in my birthplace, and no less\nIn that beloved Vale to which erelong\nWe were transplanted.",
            author: "William Wordsworth",
            work: "The Prelude"
        ),
        WeatherQuote(
            text: "The woods decay, the woods decay and fall,\nThe vapours weep their burthen to the ground,\nMan comes and tills the field and lies beneath,\nAnd after many a summer dies the swan.",
            author: "William Wordsworth",
            work: "Tithonus"
        ),
        WeatherQuote(
            text: "When the storm is gathering; when the sky\nO'ercast by clouds is reddening\nWith lightning's fire,\nThe honest man is not afraid to die.",
            author: "William Wordsworth",
            work: "Character of the Happy Warrior"
        ),
        WeatherQuote(
            text: "The wind, a sightless labourer, whistles at his task,\nVapours, and clouds, and storms be with me still;\nI ask not smoother songs, more sweet than these.",
            author: "William Wordsworth",
            work: "The Prelude"
        ),
        WeatherQuote(
            text: "A slumber did my spirit seal;\nI had no human fears:\nShe seemed a thing that could not feel\nThe touch of earthly years.",
            author: "William Wordsworth",
            work: "A Slumber Did My Spirit Seal"
        ),
        WeatherQuote(
            text: "Bliss was it in that dawn to be alive,\nBut to be young was very Heaven!\nO times,\nIn which the meagre, stale, forbidding ways\nOf custom, law, and statute, took at once\nThe attraction of a country in romance!",
            author: "William Wordsworth",
            work: "The French Revolution as It Appeared"
        ),
        WeatherQuote(
            text: "The breath of Morning's waxing might\nHave blown apart the folded night;\nBut she has vanished from my sight,\nBearing away the crimson light.",
            author: "William Wordsworth",
            work: "She Dwelt Among the Untrodden Ways"
        ),
        WeatherQuote(
            text: "Nature never did betray\nThe heart that loved her; 'tis her privilege,\nThrough all the years of this our life, to lead\nFrom joy to joy.",
            author: "William Wordsworth",
            work: "Lines Composed Above Tintern Abbey"
        )
    ]

    static func randomQuote() -> WeatherQuote {
        let allQuotes = shakespeareQuotes + wordsworthQuotes
        return allQuotes.randomElement() ?? shakespeareQuotes[0]
    }
}
import Foundation

struct TravelPhrase: Identifiable {
    let id: String
    let english: String
    let translation: String
    let language: String
}

enum TravelPhraseCatalog {
    static let essential: [TravelPhrase] = [
        TravelPhrase(id: "hello", english: "Hello", translation: "Bonjour", language: "French"),
        TravelPhrase(id: "thanks", english: "Thank you", translation: "Gracias", language: "Spanish"),
        TravelPhrase(id: "please", english: "Please", translation: "Bitte", language: "German"),
        TravelPhrase(id: "help", english: "I need help", translation: "Aiuto", language: "Italian"),
        TravelPhrase(id: "bathroom", english: "Where is the bathroom?", translation: "Où sont les toilettes?", language: "French"),
        TravelPhrase(id: "water", english: "Water, please", translation: "Agua, por favor", language: "Spanish"),
        TravelPhrase(id: "bill", english: "The bill, please", translation: "L'addition, s'il vous plaît", language: "French"),
        TravelPhrase(id: "airport", english: "Where is the airport?", translation: "空港はどこですか", language: "Japanese"),
        TravelPhrase(id: "taxi", english: "I need a taxi", translation: "Preciso de um táxi", language: "Portuguese"),
        TravelPhrase(id: "hotel", english: "I have a reservation", translation: "Ho una prenotazione", language: "Italian")
    ]
}

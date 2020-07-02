// RichTextRenderer

enum OrderedListIndicator {
    case alphabet(Bool) // uppercased
    case number
    case romanNumber

    func indicator(forItemAt index: Int) -> String {
        switch self {
        case .alphabet(let uppercased):
            return letterIndicator(forItemAt: index, uppercased: uppercased)
        case .number:
            return numberIndicator(forItemAt: index + 1)
        case .romanNumber:
            return romanNumberIndicator(forItemAt: index + 1)
        }
    }

    private func letterIndicator(forItemAt index: Int, uppercased: Bool) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
        let character = String(characters[index % characters.count])
        return uppercased ? character.uppercased() : character
    }

    private func numberIndicator(forItemAt index: Int) -> String {
        return String(index)
    }

    // Inspired by: https://gist.github.com/kumo/a8e1cb1f4b7cff1548c7
    private func romanNumberIndicator(forItemAt index: Int) -> String {
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues: [Int] = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]

        var romanValue = ""
        var startingValue = index

        for i in 0..<romanValues.count {
            let arabic = arabicValues[i]
            let divisor = startingValue / arabic

            guard divisor > 0 else { continue }
            for _ in 0..<divisor {
                romanValue += romanValues[i]
            }
            startingValue -= arabic * divisor
        }

        return romanValue.lowercased()
    }
}

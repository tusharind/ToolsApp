import Foundation

extension String {

    func formattedDate(_ format: String = "dd MMM yyyy, HH:mm") -> String {

        let fixed = self.replacingOccurrences(
            of: ":",
            with: ".",
            options: .backwards,
            range: nil
        )

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = inputFormatter.date(from: fixed) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            outputFormatter.locale = Locale.current
            return outputFormatter.string(from: date)
        }

        return self
    }
}


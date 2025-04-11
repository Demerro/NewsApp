# NewsApp 📰

**NewsApp** is a simple iOS application that displays news articles fetched from a remote API. Built with a focus on clean code and modern iOS development practices, it showcases the use of Swift, UIKit, Combine, and URLSession within an MVVM architecture.

## Features

- **News List Screen**: Displays a list of news articles fetched from a public API.
- **Article Screen**: Shows detailed information about a selected news article.
- **Web View Screen**: Loads the full article in a web view for a seamless reading experience.
- Real-time data fetching with error handling.
- Responsive UI built programmatically with UIKit.

## Screenshots

| News List | Article | Article Full Text |
| --------- | ------- | ----------------- |
| <img src="images/articleList.png"> | <img src="images/article.png"> | <img src="images/articleText.png"> |

## Tech Stack

- **Language**: Swift 5.0
- **Framework**: UIKit (programmatic UI)
- **Networking**: URLSession
- **Reactive Programming**: Combine
- **Architecture**: MVVM (Model-View-ViewModel)
- **iOS Version**: iOS 14.0+

## Architecture

The app follows the MVVM architecture to ensure separation of concerns and maintainable code:

- **Model**: Represents the data layer, including news article structs and API response models.
- **View**: UIKit-based views and view controllers that display the UI.
- **ViewModel**: Handles business logic, communicates with the network layer, and prepares data for the views using Combine publishers.

## Installation

To run **NewsApp** locally, follow these steps:

### Prerequisites

- Xcode 15.0 or later
- iOS 14.0 or later
- An active internet connection (for API requests)

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/Demerro/NewsApp.git
   cd NewsApp
   ```
2. Open the project: Open `NewsApp.xcodeproj` in Xcode.
3. Get the API key from here: https://newsapi.org
4. - Create `API Keys.plist` in `NewsApp/Resources/`
   - Add your key into the property list
    ```
    <dict>
      <key>News API</key>
      <string>Your news API key</string>
    </dict>
    ```
   - Add on-demand tag `API keys`

5. Build and run:
     - Select a simulator or connected device.
     - Press `Cmd + R` to build and run the app.

## Dependencies

The app is dependency-free and uses only native Apple frameworks (UIKit, Combine, WebKit).

## Contributing

Contributions are welcome! To contribute:

- Fork the repository.
- Create a new branch (`git checkout -b feature/your-feature`).
- Commit your changes (`git commit -m "Add your feature"`).
- Push to the branch (`git push origin feature/your-feature`).
- Open a pull request.

Please ensure your code follows the existing style.

## License

This project is licensed under the MIT License. See the `LICENSE.txt` file for details.

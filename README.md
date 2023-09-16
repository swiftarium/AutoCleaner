# AutoCleaner

`AutoCleaner` is a utility in Swift designed to automatically clean elements from a given collection. Based on a specified condition and frequency, it ensures your collection remains tidy and efficient.

## Installation

To install `AutoCleaner` into your Xcode project using SPM, add it to the dependencies value of your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/jinyongp/AutoCleaner.git", from: "1.1.0"),
]
```

And specify `"AutoCleaner"` as a dependency of the Target in which you wish to use `AutoCleaner`.

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AutoCleaner",
        ]
    ),
]
```

## Usage

### Initialization

Initialize AutoCleaner by providing a collection and a condition:

```swift
let cleaner = AutoCleaner([1, 2, 3, 4, 5]) { $0 <= 3 }
```

### Start and Stop Cleaning

Start automatic cleaning with a specified frequency:

```swift
// count is the number of elements in the collection
cleaner.start { count in 
    if count > 100 {
        return .seconds(30)
    } else {
        return .seconds(60)
    }
}
```

### To stop the cleaning:

```swift
cleaner.stop()
```

### Manual Update and Clean

Update the collection:

```swift
cleaner.update { collection in 
    collection.append(6)
}
```

### Manually initiate a clean operation:

```swift
cleaner.clean()
```

### Callbacks

Get notified after every cleaning operation:

```swift
cleaner.onCleaned = { removedCount in 
    print("\(removedCount) elements removed.")
}
```

## License

This library is released under the MIT license. See [LICENSE](/LICENSE) for details.

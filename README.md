## Thunderbird [Nixified]

Funded by the European Commission under the [Next Generation Internet](https://www.ngi.eu/ngi-projects/ngi-zero/) initiative

### Objective

1. Create a wrapper for Thunderbird which would allow for declarative management of its extensions.
2. Package Enigmail for Thunderbird

### Current State

As of 2020, September 11, this flake is in a working state and achieving all of its objectives.

As of Thunderbird 78.2.1, encryption is now built into the app, which renders the packaging of Enigmail to be redundant. However, the wrapper can still be used to declaratively manage other extensions (although they are not packaged yet) though there are helper functions, to build an extension from source (`buildThunderbirdExtension`) and to fetch an extension from the web store (`buildMozillaExtension`).

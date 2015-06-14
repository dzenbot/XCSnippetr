#XCSnippetr

Share code snippets to Slack and Gist without leaving XCode ever again! 😱

## Features

- Upload code snippets using Slack's and Github's APIs.
- The plugin is available from the code editor's contextual menu and main menu.
- Extremely easy to sign-in using your API tokens. Your tokens are secure 🙈, stored in the system's Keychain.
- Share to any of your teams, channels, groups and users.
- Upload as a file snippet or as a message with fenced code block.
- Add an initial comment (optional).
- Code syntax highlight, thanks to [ACEView](https://github.com/faceleg/ACEView) 👏.
- Auto-detection of the source file name, used as the snippet title by default.
- Auto-detection of the source code type. No Swift support for now 😔.

## Configuration

First, select any code snippet you would like to share, and right click on it.
![contextual menu](Documentation/Screenshots/screenshot_contextual_menu.png)

The first time, you will be prompt to sign in.

For Slack, use your API tokens available at https://api.slack.com/web
![login view](Documentation/Screenshots/screenshot_login_slack.png)

For Gist, use generate a new API tokens in [https://github.com/settings/tokens/](https://github.com/settings/tokens/new?description=xcsnippetr&scopes=gist)
![login view](Documentation/Screenshots/screenshot_login_github.png)


You should be ready to go now.
Simply pick the team and channel to share to. Add a comment. Share! 💥
![main view](Documentation/Screenshots/screenshot_main.png)

## Install

1. Run `pod update` to install the dependencies.

2. Build the project to install the plugin. The plugin is installed in `/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SlackBoard.xcplugin`.

2. Restart Xcode for the plugin to be loaded.

Alternatively, install through [Alcatraz](http://alcatraz.io/), the package manager for Xcode (soon).
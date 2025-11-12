# AI Recipe Generator

> Flutter + Firebase + Gemini AI  
> Smart recipe generation from ingredient photos

## 🚀 Quick Start

**New to the project?** Start here:
- **[Quick Start Guide](documentation/guides/QUICK_START.md)** - Complete setup guide (budget several hours for first-time setup)
- **[Firebase Troubleshooting](documentation/guides/FIREBASE_TROUBLESHOOTING.md)** - Common issues and fixes (bookmark this!)
- **[Development Guide](documentation/guides/DEVELOPMENT_GUIDE.md)** - Comprehensive developer documentation
- **[Gemini API Setup](documentation/guides/GEMINI_API_SETUP.md)** - AI configuration guide

## Features

- 📸 **Camera Integration** - Scan ingredients from photos
- 🤖 **AI-Powered Detection** - Gemini AI detects ingredients automatically
- 🍳 **Smart Recipe Generation** - Personalized recipes based on your ingredients
- 💾 **Recipe History** - Save and organize your favorite recipes
- 👤 **User Profiles** - Customize dietary preferences and cooking skills
- 🔒 **Firebase Authentication** - Secure Google Sign-In

## Tech Stack

- **Flutter** 3.24+ - Cross-platform mobile framework
- **Firebase** - Backend infrastructure (Auth, Firestore, Storage)
- **Gemini AI** - Cloud-based generative AI via Firebase AI
- **Riverpod** - State management

## Documentation

- 📚 [Product Requirements Document](documentation/PRD.md)
- ⚡ [Quick Start Guide](documentation/guides/QUICK_START.md) - **Start here!**
- 🔧 [Firebase Troubleshooting](documentation/guides/FIREBASE_TROUBLESHOOTING.md) - Common fixes
- 🛠️ [Development Guide](documentation/guides/DEVELOPMENT_GUIDE.md)
- 🤖 [Gemini API Setup](documentation/guides/GEMINI_API_SETUP.md)

## Getting Started (TL;DR)

```bash
# Clone the repo
git clone https://github.com/Berkay2002/tdde02.git
cd tdde02

# Install dependencies
flutter pub get

# Run the app (will fail first time - see Quick Start for SHA setup)
flutter run
```

⚠️ **First-time setup requires:**
- Flutter SDK, Android SDK, Firebase CLI installation
- SHA certificate configuration (each developer)
- App Check debug token setup

**For complete setup instructions, see [QUICK_START.md](documentation/guides/QUICK_START.md).**

**Having issues?** See [FIREBASE_TROUBLESHOOTING.md](documentation/guides/FIREBASE_TROUBLESHOOTING.md).

## Project Structure

```
lib/
├── core/           # Core functionality (AI, services, theme)
├── features/       # Feature modules (auth, camera, recipes)
└── shared/         # Shared providers and widgets
```

## Contributing

See [DEVELOPMENT_GUIDE.md](documentation/guides/DEVELOPMENT_GUIDE.md#git-branching-strategy) for Git workflow and branching strategy.

## License

This project is part of a university course project.

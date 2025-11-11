# AI Recipe Generator

> Flutter + Firebase + Gemini AI  
> Smart recipe generation from ingredient photos

## 🚀 Quick Start

**New to the project?** Get the app running in 10 minutes:
- **[Quick Start Guide](documentation/guides/QUICK_START.md)** - For new developers (start here!)
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
- 🛠️ [Development Guide](documentation/guides/DEVELOPMENT_GUIDE.md)
- 🤖 [Gemini API Setup](documentation/guides/GEMINI_API_SETUP.md)
- ⚡ [Quick Commands](documentation/guides/QUICK_COMMANDS.md)

## Getting Started (TL;DR)

```bash
# Clone the repo
git clone https://github.com/Berkay2002/tdde02.git
cd tdde02

# Install dependencies
flutter pub get

# Run the app
flutter run
```

For detailed setup instructions, see [QUICK_START.md](documentation/guides/QUICK_START.md).

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

# Christmas Planner

A comprehensive Christmas planning application for managing gifts, meals, budgets, and holiday timelines.

## Features

- **Gift Planning**: Track gifts for all recipients with budgets and purchase status
- **Meal Planning**: Organize Christmas Eve and Christmas Day meals with guest counts and menus
- **Budget Management**: Monitor spending across all categories with real-time updates
- **Calendar**: Schedule important dates and deadlines
- **Shopping Lists**: Consolidated shopping lists for all gifts and meals
- **Timeline Calculator**: Automatic calculation of ordering deadlines based on shipping times

## Tech Stack

- **Frontend**: Flutter (Dart) - Cross-platform support for iOS, Android, and Web
- **Backend**: Supabase (PostgreSQL) - Real-time database with authentication
- **State Management**: Riverpod - Reactive state management
- **Deployment**: Docker - Containerized deployment

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Docker and Docker Compose (for local development)
- Supabase account (or use local Supabase via Docker)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/christmas-planner.git
cd christmas-planner
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:
Create a `.env` file in the root directory:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Run database migrations:
Execute the SQL files in `supabase/migrations/` in your Supabase project.

### Running the Application

#### Web
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

#### Mobile
```bash
flutter run
```

#### Docker
```bash
docker-compose up --build
```

The application will be available at `http://localhost:8080`

## Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## Project Structure

```
lib/
├── core/                 # Core utilities, constants, theme
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── features/            # Feature modules
│   ├── auth/           # Authentication
│   ├── dashboard/      # Main dashboard
│   ├── gifts/          # Gift planning
│   ├── meals/          # Meal planning
│   ├── budget/         # Budget management
│   ├── calendar/       # Calendar events
│   ├── shopping/       # Shopping lists
│   └── settings/       # App settings
└── shared/             # Shared models and services
```

## Database Schema

The application uses the following main tables:
- `user_profiles` - User information and preferences
- `recipients` - Gift recipients
- `gifts` - Gift items
- `meals` - Meal planning
- `meal_items` - Meal ingredients and items
- `family_budgets` - Overall budget configuration
- `shopping_lists` - Shopping list management
- `calendar_events` - Calendar and events
- `tasks` - Task management
- `notifications` - User notifications

All tables include Row Level Security (RLS) policies to ensure data privacy.

## Security

- All user data is protected with Supabase Row Level Security (RLS)
- Input validation and sanitization on all forms
- Secure password requirements (min 8 chars, uppercase, lowercase, number, special character)
- XSS and SQL injection protection
- HTTPS encryption for all communications
- Content Security Policy headers in production

## Deployment

### Docker Production Build

```bash
docker build -t christmas-planner:latest .
docker run -p 8080:80 -e SUPABASE_URL=$SUPABASE_URL -e SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY christmas-planner:latest
```

### Web Hosting

Build for web:
```bash
flutter build web --release
```

Deploy the `build/web` directory to your hosting provider.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support, email support@christmasplanner.app or open an issue on GitHub.

## Acknowledgments

- Flutter team for the amazing framework
- Supabase team for the backend infrastructure
- All contributors who help improve this project

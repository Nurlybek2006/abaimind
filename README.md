# AbaiMind

## Русская версия

**AbaiMind** — мобильное образовательное приложение для студентов Университета имени Абая. Приложение помогает проходить тесты, отслеживать учебный прогресс и поддерживать связь с куратором в одном месте.

### Возможности

- регистрация и вход по электронной почте;
- отдельные роли для студентов, кураторов и администраторов;
- тесты с категориями, уровнями сложности, ограничением времени и начислением баллов;
- ежедневные задания и мотивационные сообщения;
- результаты тестов с отображением правильных и неправильных ответов;
- общий, недельный и месячный рейтинг студентов;
- новости университета;
- чат студента с куратором;
- профиль со статистикой, достижениями, серией активности и настройкой темы;
- административная панель для управления пользователями, тестами и новостями.

### Технологии

- Flutter и Dart;
- Firebase Authentication — регистрация и авторизация;
- Cloud Firestore — хранение пользователей, тестов, новостей, результатов и сообщений;
- Firebase Storage — хранение файлов и изображений;
- Riverpod — управление состоянием;
- Hive — локальное хранение данных;
- Lottie, Flutter Animate и Shimmer — анимации и состояния загрузки;
- FL Chart — визуализация статистики.

### Структура проекта

```text
lib/
├── core/       # тема, цвета, константы и общие настройки
├── models/     # модели данных
├── pages/      # экраны авторизации, студента и администратора
├── providers/  # Riverpod-провайдеры
├── services/   # Firebase, Hive и другие сервисы
└── widgets/    # переиспользуемые UI-компоненты
```

### Запуск проекта

1. Установите Flutter SDK и убедитесь, что команда `flutter doctor` не показывает критических ошибок.
2. Клонируйте репозиторий и перейдите в его папку.
3. Установите зависимости:

	```bash
	flutter pub get
	```

4. Проверьте настройки Firebase для выбранной платформы. Конфигурация проекта хранится в `lib/firebase_options.dart`, а Android-конфигурация — в `android/app/google-services.json`.
5. Запустите приложение:

	```bash
	flutter run
	```

Для запуска генерации кода Riverpod используйте:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## English version

**AbaiMind** is a mobile educational application for students of Abai University. It brings tests, academic progress tracking, university news and curator communication together in one place.

### Features

- email registration and sign-in;
- separate roles for students, curators and administrators;
- tests with categories, difficulty levels, time limits and point rewards;
- daily challenges and motivational messages;
- test results with correct and incorrect answer details;
- overall, weekly and monthly student leaderboards;
- university news feed;
- student-to-curator chat;
- profile with statistics, achievements, activity streak and theme settings;
- admin panel for managing users, tests and news.

### Tech stack

- Flutter and Dart;
- Firebase Authentication for registration and sign-in;
- Cloud Firestore for users, tests, news, results and messages;
- Firebase Storage for files and images;
- Riverpod for state management;
- Hive for local data storage;
- Lottie, Flutter Animate and Shimmer for animations and loading states;
- FL Chart for statistics visualization.

### Project structure

```text
lib/
├── core/       # theme, colors, constants and shared configuration
├── models/     # data models
├── pages/      # authentication, student and admin screens
├── providers/  # Riverpod providers
├── services/   # Firebase, Hive and other services
└── widgets/    # reusable UI components
```

### Getting started

1. Install the Flutter SDK and make sure `flutter doctor` reports no critical issues.
2. Clone the repository and open its directory.
3. Install dependencies:

	```bash
	flutter pub get
	```

4. Check the Firebase configuration for the target platform. The project configuration is stored in `lib/firebase_options.dart`, while the Android configuration is stored in `android/app/google-services.json`.
5. Run the application:

	```bash
	flutter run
	```

To generate Riverpod code, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

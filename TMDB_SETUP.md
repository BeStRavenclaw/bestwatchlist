# TMDb API Setup

To enable movie browsing in BeStWatchList, you need to set up a free TMDb API key.

## Steps to get your API key:

1. Go to [https://www.themoviedb.org/signup](https://www.themoviedb.org/signup) and create a free account

2. After logging in, go to your account settings: [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)

3. Click on "Create" or "Request an API Key"

4. Select "Developer" option

5. Fill out the application form:
   - **Application Name**: BeStWatchList (or any name you prefer)
   - **Application URL**: You can use a placeholder like `http://localhost` or `https://github.com/yourusername/bestwatchlist` since this is a local app
   - **Application Summary**: Personal movie tracking app for cinema releases and streaming availability
   - Accept the terms of use

6. Once approved, you'll get an API key (v3 auth)

7. Copy your API key

8. Open `lib/services/tmdb_service.dart` in your project

9. Replace `YOUR_API_KEY_HERE` with your actual API key:
   ```dart
   static const String _apiKey = 'your_actual_api_key_here';
   ```

10. Save the file and restart the app

## Note:
The TMDb API is free for non-commercial use and has generous rate limits. Your API key should be kept private and not committed to public repositories.

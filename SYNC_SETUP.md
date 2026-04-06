# AppWrite Cloud Sync Setup Guide

This guide will help you set up AppWrite for cloud synchronization of your BeStWatchList data.

## Prerequisites

- An AppWrite account (sign up at https://cloud.appwrite.io/)
- Your Flutter development environment set up

## Step 1: Create an AppWrite Project

1. Go to https://cloud.appwrite.io/
2. Create a new account or log in
3. Click "Create Project"
4. Give your project a name (e.g., "BeStWatchList")
5. Copy the **Project ID** - you'll need this later

## Step 2: Create a Database

1. In your AppWrite project, navigate to **Databases**
2. Click "Create Database"
3. Set the Database ID to: `bestwatchlist`
4. Click "Create"

## Step 3: Create Collections

### Collection 1: Movies

1. Click "Create Collection"
2. Set Collection ID to: `movies`
3. Set permissions:
   - **Create**: Anyone
   - **Read**: Anyone
   - **Update**: Anyone
   - **Delete**: Anyone

   *(Note: For production, you should implement proper authentication and permissions)*

4. Create the following attributes:
   - `id` (String, required, size: 255) - Unique movie identifier
   - `title` (String, required, size: 500) - Movie title
   - `releaseDate` (String, required, size: 50) - ISO8601 DateTime string (e.g., "2025-12-27T18:00:00.000Z")
   - `posterUrl` (String, size: 1000) - URL to movie poster image
   - `description` (String, size: 2000) - Movie overview/synopsis
   - `status` (Integer, required) - Watch status: 0=wantToWatch, 1=watched, 2=lostInterest, 3=wantToRewatch
   - `isInCinema` (Boolean, required) - Whether movie is currently in cinemas
   - `leftCinemaDate` (String, size: 50) - ISO8601 DateTime when movie left cinemas
   - `availableOnStreamingServices` (String array) - List of streaming service names
   - `notificationSundayBefore` (String, size: 50) - ISO8601 DateTime for scheduled notification
   - `notificationReleaseDay` (String, size: 50) - ISO8601 DateTime for scheduled notification
   - `notificationSaturdayAfter` (String, size: 50) - ISO8601 DateTime for scheduled notification
   - `notifiedLeftCinema` (Boolean, required) - Whether "left cinema" notification was sent
   - `notifiedStreamingAvailable` (Boolean, required) - Whether "streaming available" notification was sent
   - `imdbId` (String, size: 50) - IMDb identifier (e.g., "tt1234567")
   - `lastModified` (String, size: 50) - ISO8601 DateTime of last modification (for conflict resolution)
   - `deviceId` (String, required, size: 100) - Unique device identifier for anonymous sync

   **Note on DateTime fields**: AppWrite stores dates as ISO8601 strings. The app automatically converts between DateTime objects and string format during sync.

5. Create an index:
   - Key: `deviceId`
   - Type: Key
   - Attributes: `deviceId`

### Collection 2: Settings

1. Click "Create Collection"
2. Set Collection ID to: `settings`
3. Set the same permissions as the movies collection

4. Create the following attributes:
   - `cinemaLocation` (String, size: 255)
   - `streamingServices` (String array)
   - `notificationsEnabled` (Boolean, required)
   - `sundayBeforeNotifications` (Boolean, required)
   - `releaseDayNotifications` (Boolean, required)
   - `saturdayAfterNotifications` (Boolean, required)
   - `leftCinemaNotifications` (Boolean, required)
   - `streamingAvailableNotifications` (Boolean, required)
   - `darkMode` (Boolean, required)
   - `lastModified` (String, size: 50)
   - `deviceId` (String, required, size: 100)

## Step 4: Configure Your App

1. Open `lib/services/appwrite_service.dart`
2. Find these lines:
   ```dart
   static const String _endpoint = 'https://cloud.appwrite.io/v1';
   static const String _projectId = 'YOUR_PROJECT_ID';
   ```
3. Replace `YOUR_PROJECT_ID` with your actual Project ID from Step 1

## Step 5: Test the Sync

1. Run your Flutter app
2. Go to the Settings screen
3. You should see a "Data Sync" section at the top
4. Click "Sync Now" to test the synchronization
5. Check your AppWrite console to verify that data is being synced

## How It Works

### Anonymous Sync
- Each device gets a unique UUID-based device ID
- Data is tagged with this device ID in AppWrite
- Currently, each device syncs its own data independently
- Future enhancement: Add user authentication for multi-device sync

### Automatic Background Sync
- Syncs automatically every Monday at 6pm
- Checks hourly for the correct time
- Only syncs when network is available
- Uses exponential backoff on failures

### Conflict Resolution
- Uses "last write wins" strategy
- Compares `lastModified` timestamps
- Remote data overwrites local if newer

### Manual Sync
- Available in Settings > Data Sync > "Sync Now" button
- Shows sync status and last sync time
- Displays success/error messages

### What Gets Synced

**Movie Data:**
- Movie details (title, description, poster, release date)
- Watch status (want to watch, watched, etc.)
- Cinema availability
- Streaming service availability
- IMDb ID
- **Notification timestamps and flags** - Used to track scheduled notifications

**User Settings:**
- Cinema location preference
- Streaming services selection
- Notification preferences (enabled/disabled for each type)
- Dark mode setting

**Note on Notifications**: Currently, notification scheduling data is synced. This means if you set up notifications on one device, the timestamps are shared. However, each device manages its own notification system independently. In the future, you may want to exclude notification timestamps from sync and only sync the notification preferences (enabled/disabled).

## Production Considerations

### Security
1. **Enable Authentication**: Replace anonymous access with proper user authentication
2. **Update Permissions**: Restrict collection permissions to authenticated users only
3. **Environment Variables**: Move the Project ID to environment variables
4. **API Key Security**: Never commit API keys to version control

### Performance
1. **Pagination**: Implement pagination for large datasets
2. **Delta Sync**: Only sync changed items instead of full sync
3. **Batch Operations**: Batch multiple updates into single requests

### Monitoring
1. **Error Logging**: Implement proper error logging service
2. **Analytics**: Track sync success rates and failures
3. **User Feedback**: Show more detailed sync progress to users

## Troubleshooting

### Sync Fails
- Check your internet connection
- Verify Project ID is correct
- Check AppWrite console for error logs
- Ensure collections exist with correct IDs

### Data Not Appearing
- Verify deviceId is being set correctly
- Check collection permissions
- Look for errors in Flutter console
- Verify attribute types match the data

### Background Sync Not Working
- Check device battery optimization settings
- Verify WorkManager is initialized
- Test manual sync first
- Check Android/iOS permissions

## Alternative Backends

If you prefer not to use AppWrite, you can replace the `AppWriteService` with:
- Firebase Firestore
- Supabase
- Your own REST API
- AWS Amplify

The sync architecture is designed to be backend-agnostic.

# Debugging Connection Issue

## Steps to Debug

1. **Stop the running app** (if still running)

2. **Hot restart the app:**
   - Press `r` in the terminal where `flutter run` is running
   - Or stop and run again: `flutter run -d windows`

3. **Check the console output** when you click "Create Room"

You should see messages like:
```
🔌 Connecting to server: https://web-production-703bf.up.railway.app
✅ Connected to server: <socket-id>
📤 Emitting createRoom: YourName (Connected: true, Socket ID: <id>)
📥 Received roomCreated: ...
```

## Common Issues

### Issue 1: Not Connected
If you see:
```
⚠️ Warning: Socket not connected yet
```

**Solution:** The app is trying to create room before connection is established. Wait 1-2 seconds after app starts.

### Issue 2: Connection Error
If you see:
```
🔴 Connection error: ...
```

**Possible causes:**
- CORS issue on server
- Server not running
- Wrong URL

**Check server logs** in Railway dashboard.

### Issue 3: No Response
If createRoom is emitted but no roomCreated received:

**Check:**
1. Server logs in Railway
2. Make sure server.js has the createRoom event handler
3. Verify CORS is set to allow all origins

## Quick Test

Run this in terminal to test server directly:
```bash
curl https://web-production-703bf.up.railway.app/health
```

Should return:
```json
{"status":"ok","timestamp":"...","rooms":0,"environment":"production"}
```

## Next Steps

After fixing, commit the changes:
```bash
cd d:\Niyazi\Game1\kings_fate_mobile
git add .
git commit -m "Fix server URL and add better connection logging"
git push
```

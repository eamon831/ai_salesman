# Backend Proxy for OpenAI API

This is an example of how to create a secure backend proxy to hide your OpenAI API key.

## Why Use a Backend Proxy?

When you deploy a Flutter web app, all code (including API keys) is visible in the browser. A backend proxy:
- Keeps your API key secret on the server
- Adds rate limiting and usage controls
- Provides better security and monitoring

## Option 1: Vercel Serverless Function (Recommended - Free)

### Setup Steps:

1. **Create a new Vercel project:**
   ```bash
   mkdir ai-salesman-api
   cd ai-salesman-api
   mkdir api
   ```

2. **Copy the function:**
   - Copy `vercel-function.js` to `api/chat.js`

3. **Create vercel.json:**
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "api/**/*.js",
         "use": "@vercel/node"
       }
     ]
   }
   ```

4. **Deploy to Vercel:**
   ```bash
   npm install -g vercel
   vercel login
   vercel
   ```

5. **Add environment variable:**
   - Go to your Vercel project settings
   - Add `OPENAI_API_KEY` with your OpenAI key

6. **Your API endpoint will be:**
   `https://your-project.vercel.app/api/chat`

### Update Flutter App:

In `lib/services/open_ai_service.dart`, change:

```dart
static const String _apiEndpoint = 'https://your-project.vercel.app/api/chat';

// Remove the Authorization header and API key
final response = await http.post(
  Uri.parse(_apiEndpoint),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'messages': messages,
    'temperature': _temperature,
    'max_tokens': _maxTokens,
  }),
);
```

## Option 2: AWS Lambda

Similar approach but using AWS Lambda + API Gateway.

## Option 3: Google Cloud Functions

Similar approach but using Google Cloud Functions.

## Option 4: Simple Node.js Server

If you have your own server, you can run a simple Express.js API:

```javascript
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors({ origin: 'https://eamon831.github.io' }));
app.use(express.json());

app.post('/api/chat', async (req, res) => {
  // Same logic as Vercel function
});

app.listen(3000);
```

## Testing Your Proxy

```bash
curl -X POST https://your-project.vercel.app/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant"},
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

## Benefits

✅ API key stays secret  
✅ Can add rate limiting  
✅ Can add usage analytics  
✅ Can add caching  
✅ Can add request validation  
✅ Free tier available on Vercel  

## Cost

- Vercel: Free tier includes 100GB bandwidth and 100 hours of serverless function execution
- AWS Lambda: Free tier includes 1M requests/month
- Google Cloud: Free tier includes 2M invocations/month


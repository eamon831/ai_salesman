# Deployment Guide for GitHub Pages

## ✅ Current Setup

Your Flutter app is configured to automatically deploy to `eamon831.github.io` when you push to the `main` branch.

## 🔧 Required GitHub Secrets

You need to set up these secrets in your GitHub repository:

### 1. OPENAI_API_KEY
- Go to: `https://github.com/eamon831/ai_salesman/settings/secrets/actions`
- Click "New repository secret"
- Name: `OPENAI_API_KEY`
- Value: Your OpenAI API key (starts with `sk-...`)

### 2. GH_PAT (Personal Access Token)
- Go to: `https://github.com/settings/tokens`
- Click "Generate new token (classic)"
- Give it a name like "Deploy to GitHub Pages"
- Select scopes: `repo` (all), `workflow`
- Generate and copy the token
- Add it to your repository secrets:
  - Go to: `https://github.com/eamon831/ai_salesman/settings/secrets/actions`
  - Name: `GH_PAT`
  - Value: Your personal access token

## 🚀 How to Deploy

### Automatic Deployment
Simply push your code to the `main` branch:
```bash
git add .
git commit -m "Update app"
git push origin main
```

The GitHub Actions workflow will automatically:
1. Build your Flutter web app
2. Deploy it to `eamon831.github.io`

### Manual Deployment (Local Build)
If you want to build and test locally first:

```bash
# Build for web
flutter build web --release --base-href "/" --dart-define=OPENAI_API_KEY=your_key_here

# Test locally
cd build/web
python3 -m http.server 8000
# Visit http://localhost:8000
```

## 🔍 Checking Deployment Status

1. Go to: `https://github.com/eamon831/ai_salesman/actions`
2. Click on the latest workflow run
3. Check if all steps completed successfully
4. Your app should be live at: `https://eamon831.github.io`

## ⚠️ Security Warning

**IMPORTANT:** Your OpenAI API key will be embedded in the JavaScript bundle and can be extracted by anyone who visits your site.

### Recommended Solutions:

#### Option 1: Backend Proxy (Most Secure)
Create a simple backend API that:
- Receives requests from your Flutter app
- Calls OpenAI API with your secret key
- Returns responses to your app

Example services:
- Vercel Serverless Functions
- AWS Lambda
- Google Cloud Functions
- Your own Node.js/Python server

#### Option 2: API Key Restrictions
In your OpenAI dashboard:
1. Set spending limits (e.g., $5/month)
2. Enable rate limiting
3. Monitor usage regularly
4. Rotate keys frequently

#### Option 3: Use a Demo Key
Create a separate OpenAI API key specifically for this demo with:
- Very low spending limits
- Rate limiting enabled
- Regular monitoring

## 🐛 Troubleshooting

### Issue: Site shows README instead of app
**Solution:** Make sure the workflow completed successfully and deployed to the root of `eamon831.github.io`

### Issue: Blank page or loading errors
**Solution:** 
- Check browser console for errors
- Verify `--base-href "/"` is set correctly
- Check that all assets are loading properly

### Issue: API calls failing
**Solution:**
- Verify `OPENAI_API_KEY` secret is set correctly
- Check browser console for CORS errors
- Verify API key is valid and has credits

### Issue: Assets not loading (404 errors)
**Solution:**
- Ensure `--base-href "/"` matches your deployment path
- Check that assets are included in `pubspec.yaml`
- Verify asset files exist in the `assets/` directory

## 📱 Testing Your Deployment

After deployment, test these features:
- [ ] App loads without errors
- [ ] Product image displays correctly
- [ ] Chat button opens the modal
- [ ] Can send messages to AI
- [ ] AI responds correctly
- [ ] Conversation history works
- [ ] Dialog closes and resets properly

## 🔄 Updating Your App

To update your deployed app:
1. Make changes to your code
2. Commit and push to `main` branch
3. Wait for GitHub Actions to complete
4. Refresh `eamon831.github.io` (may need hard refresh: Cmd+Shift+R)

## 📊 Monitoring

Keep an eye on:
- OpenAI API usage: https://platform.openai.com/usage
- GitHub Actions runs: https://github.com/eamon831/ai_salesman/actions
- Browser console for errors when testing

## 🎯 Next Steps

1. ✅ Set up GitHub secrets (OPENAI_API_KEY and GH_PAT)
2. ✅ Push code to trigger deployment
3. ✅ Wait for workflow to complete
4. ✅ Visit https://eamon831.github.io
5. ⚠️ Consider implementing a backend proxy for API key security


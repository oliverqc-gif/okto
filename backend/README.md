# Okto Backend API

A FastAPI backend for the Okto personal finance news app.

## Setup

### 1. Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables
Edit `.env` file and add:
- `NEWSAPI_KEY`: Your NewsAPI key (get from https://newsapi.org)
- `SECRET_KEY`: A secure random string for JWT
- `DATABASE_URL`: Database connection string (defaults to SQLite)

### 4. Run the Server
```bash
python -m uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

API docs: `http://localhost:8000/docs` (Swagger UI)

## API Endpoints

### Authentication
- `POST /auth/signup` - Create a new account
- `POST /auth/login` - Log in and get access token
- `GET /users/me` - Get current user info

### Profile
- `GET /users/{user_id}/profile` - Get user profile
- `PUT /users/{user_id}/profile` - Update user profile

### News
- `GET /news/feed` - Get personalized news feed
- `GET /news/sources` - List available news sources
- `POST /news/refresh` - Force refresh news from API

### Insights
- `GET /insights/{user_id}` - Get AI insights for user

## Database

The backend uses SQLite by default (great for development). For production, configure PostgreSQL:

```
DATABASE_URL=postgresql://user:password@localhost/okto_db
```

## File Structure

```
backend/
├── main.py              # FastAPI app and endpoints
├── models.py            # SQLAlchemy database models
├── auth.py              # JWT authentication logic
├── news.py              # NewsAPI integration
├── config.py            # Configuration management
├── requirements.txt     # Python dependencies
├── .env                 # Environment variables (not in git)
└── README.md            # This file
```

## Cost Optimization

NewsAPI has rate limits on the free plan. The backend implements:
- **Caching**: Articles cached for up to 24 hours
- **Smart Filtering**: Only fetch news relevant to user profiles
- **Batch Requests**: Fetch multiple categories in one call

## Authentication Flow

1. User signs up with email and password
2. Password is hashed with bcrypt
3. JWT token is issued for subsequent requests
4. Token is valid for 30 minutes
5. Client includes token in `Authorization: Bearer <token>` header

## Next Steps

1. Test the API with Postman or curl
2. Set up PostgreSQL for production
3. Configure CORS for your frontend domain
4. Add more news sources and filters
5. Implement AI insights generation

## Troubleshooting

**Issue**: `NEWSAPI_KEY not set`
- Solution: Add your NewsAPI key to `.env` file

**Issue**: Database errors
- Solution: Delete `okto.db` file to reset the database

**Issue**: CORS errors from frontend
- Solution: Update `allow_origins` in `main.py` with your frontend URL

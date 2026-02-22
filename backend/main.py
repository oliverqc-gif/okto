from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from datetime import timedelta
from typing import List, Optional
import logging

from config import settings
from models import Base, User, Profile, CachedNews
from auth import (
    hash_password,
    verify_password,
    create_access_token,
    decode_token,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)
from news import fetch_and_cache_news, get_cached_news, filter_news_for_profile

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database setup
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if "sqlite" in settings.database_url else {}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create tables
Base.metadata.create_all(bind=engine)

# FastAPI app
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    debug=settings.debug
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ============= SCHEMAS =============
from pydantic import BaseModel
from typing import Optional, List


class UserSignup(BaseModel):
    first_name: str
    last_name: str
    email: str
    password: str


class UserLogin(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user_id: int


class ProfileUpdate(BaseModel):
    age: Optional[int] = None
    region: Optional[str] = None
    employment: Optional[str] = None
    annual_gross_income: Optional[float] = None
    housing_type: Optional[str] = None
    housing_value: Optional[float] = None
    loan_types: Optional[List[str]] = None
    num_loans: Optional[int] = None
    total_debt: Optional[float] = None
    interest_rate_type: Optional[str] = None
    vehicle_type: Optional[str] = None
    savings_types: Optional[List[str]] = None
    insurance_types: Optional[List[str]] = None
    breaking_news: Optional[bool] = None
    daily_digest: Optional[bool] = None
    ai_insights: Optional[bool] = None


class NewsArticle(BaseModel):
    id: int
    source: str
    title: str
    description: str
    url: str
    image_url: Optional[str] = None
    published_at: str
    category: str
    author: Optional[str] = None

    class Config:
        from_attributes = True


# ============= ENDPOINTS =============

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "ok"}


@app.post("/auth/signup", response_model=TokenResponse)
async def signup(user_data: UserSignup, db: Session = Depends(get_db)):
    """Sign up a new user."""
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Create new user
    hashed_password = hash_password(user_data.password)
    new_user = User(
        email=user_data.email,
        first_name=user_data.first_name,
        last_name=user_data.last_name,
        hashed_password=hashed_password,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Create empty profile
    profile = Profile(user_id=new_user.id)
    db.add(profile)
    db.commit()

    # Create access token
    access_token = create_access_token(
        data={"sub": new_user.email},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": new_user.id
    }


@app.post("/auth/login", response_model=TokenResponse)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    """Log in a user."""
    user = db.query(User).filter(User.email == user_data.email).first()

    if not user or not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    access_token = create_access_token(
        data={"sub": user.email},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id
    }


def get_user_from_token(token: str, db: Session) -> User:
    """Get user from JWT token."""
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

    email = payload.get("sub")
    user = db.query(User).filter(User.email == email).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    return user


@app.get("/users/me")
async def get_current_user(token: str, db: Session = Depends(get_db)):
    """Get current authenticated user."""
    user = get_user_from_token(token, db)
    return {
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
    }


@app.get("/users/{user_id}/profile")
async def get_profile(user_id: int, token: str, db: Session = Depends(get_db)):
    """Get user profile."""
    user = get_user_from_token(token, db)
    if user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    profile = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )

    return {
        "id": profile.id,
        "user_id": profile.user_id,
        "age": profile.age,
        "region": profile.region,
        "employment": profile.employment,
        "annual_gross_income": profile.annual_gross_income,
        "housing_type": profile.housing_type,
        "housing_value": profile.housing_value,
        "loan_types": profile.loan_types,
        "num_loans": profile.num_loans,
        "total_debt": profile.total_debt,
        "interest_rate_type": profile.interest_rate_type,
        "vehicle_type": profile.vehicle_type,
        "savings_types": profile.savings_types,
        "insurance_types": profile.insurance_types,
        "breaking_news": profile.breaking_news,
        "daily_digest": profile.daily_digest,
        "ai_insights": profile.ai_insights,
    }


@app.put("/users/{user_id}/profile")
async def update_profile(
    user_id: int,
    profile_data: ProfileUpdate,
    token: str,
    db: Session = Depends(get_db)
):
    """Update user profile."""
    user = get_user_from_token(token, db)
    if user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    profile = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )

    # Update fields
    for key, value in profile_data.model_dump(exclude_unset=True).items():
        setattr(profile, key, value)

    db.commit()
    db.refresh(profile)

    return {"message": "Profile updated successfully"}


@app.get("/news/feed", response_model=List[NewsArticle])
async def get_news_feed(
    user_id: int,
    token: str,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """Get personalized news feed for user."""
    user = get_user_from_token(token, db)
    if user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    # Fetch and cache news if needed
    try:
        await fetch_and_cache_news(db, force_refresh=False)
    except Exception as e:
        logger.error(f"Error fetching news: {e}")

    # Get cached news
    articles = await get_cached_news(db, limit=limit * 2)

    # Get user profile for filtering
    profile = db.query(Profile).filter(Profile.user_id == user_id).first()
    profile_dict = {}
    if profile:
        profile_dict = {
            "age": profile.age,
            "housing_type": profile.housing_type,
            "num_loans": profile.num_loans,
            "vehicle_type": profile.vehicle_type,
            "savings_types": profile.savings_types,
        }

    # Filter news based on profile
    filtered_articles = filter_news_for_profile(articles, profile_dict)

    return filtered_articles[:limit]


@app.post("/news/refresh")
async def refresh_news(token: str, db: Session = Depends(get_db)):
    """Force refresh news from API."""
    # In production, verify this is an admin or system user
    try:
        await fetch_and_cache_news(db, force_refresh=True)
        return {"message": "News refreshed successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error refreshing news: {str(e)}"
        )


@app.get("/news/sources")
async def get_news_sources(token: str, db: Session = Depends(get_db)):
    """Get list of available news sources."""
    sources = db.query(CachedNews.source).distinct().all()
    return {"sources": [s[0] for s in sources if s[0]]}


@app.get("/insights/{user_id}")
async def get_insights(
    user_id: int,
    token: str,
    db: Session = Depends(get_db)
):
    """Get AI insights for user (stub for MVP)."""
    user = get_user_from_token(token, db)
    if user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    # TODO: Implement AI insight generation
    # For MVP, return placeholder insights based on profile

    profile = db.query(Profile).filter(Profile.user_id == user_id).first()

    insights = []

    if profile:
        if profile.num_loans and profile.num_loans > 0:
            insights.append({
                "title": "Loan Opportunity",
                "description": "Interest rates are dropping. Consider refinancing your loans for better terms.",
                "type": "opportunity"
            })

        if profile.vehicle_type == "Elbil":
            insights.append({
                "title": "EV Tax Benefits",
                "description": "New EV tax benefits are available. You may be eligible for additional deductions.",
                "type": "benefit"
            })

        if profile.housing_type == "Andelsbolig":
            insights.append({
                "title": "Housing Market Update",
                "description": "Co-housing properties in your region have increased in value by 4.2% this quarter.",
                "type": "market"
            })

    return {"insights": insights}


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Okto API",
        "version": settings.app_version,
        "docs": "/docs"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

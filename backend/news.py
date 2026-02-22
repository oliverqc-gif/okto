import httpx
import logging
from datetime import datetime, timedelta
from typing import List, Optional
from sqlalchemy.orm import Session
from models import CachedNews
import os
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

NEWSAPI_KEY = os.getenv("NEWSAPI_KEY", "")
NEWSAPI_BASE_URL = "https://newsapi.org/v2"

# Keywords for filtering financial news
FINANCE_KEYWORDS = [
    "finance", "economic", "stock", "cryptocurrency", "banking",
    "mortgage", "interest rate", "loan", "tax", "investment",
    "market", "trading", "bond", "fund", "portfolio"
]

RELEVANT_CATEGORIES = [
    "business", "technology"  # NewsAPI main categories
]


async def fetch_news_from_api(query: str = "finance", page: int = 1, page_size: int = 20) -> List[dict]:
    """
    Fetch news from NewsAPI.

    Args:
        query: Search query
        page: Page number
        page_size: Number of results per page

    Returns:
        List of news articles
    """
    if not NEWSAPI_KEY:
        logger.warning("NEWSAPI_KEY not set")
        return []

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{NEWSAPI_BASE_URL}/everything",
                params={
                    "q": query,
                    "sortBy": "publishedAt",
                    "language": "en",
                    "apiKey": NEWSAPI_KEY,
                    "page": page,
                    "pageSize": page_size
                },
                timeout=10.0
            )
            response.raise_for_status()
            data = response.json()

            if data.get("status") != "ok":
                logger.error(f"NewsAPI error: {data.get('message')}")
                return []

            articles = []
            for article in data.get("articles", []):
                articles.append({
                    "source": article.get("source", {}).get("name", "Unknown"),
                    "title": article.get("title", ""),
                    "description": article.get("description", ""),
                    "url": article.get("url", ""),
                    "image_url": article.get("urlToImage"),
                    "published_at": article.get("publishedAt"),
                    "author": article.get("author"),
                    "content": article.get("content"),
                    "category": "finance"  # We'll tag these as finance
                })

            return articles

    except httpx.HTTPError as e:
        logger.error(f"Error fetching from NewsAPI: {e}")
        return []


async def cache_articles(db: Session, articles: List[dict]) -> None:
    """Cache articles in the database."""
    for article in articles:
        # Check if article already exists
        existing = db.query(CachedNews).filter(
            CachedNews.url == article["url"]
        ).first()

        if not existing:
            try:
                published_at = datetime.fromisoformat(
                    article.get("published_at", "").replace("Z", "+00:00")
                )
            except (ValueError, AttributeError):
                published_at = datetime.utcnow()

            cached_news = CachedNews(
                source=article.get("source", ""),
                title=article.get("title", ""),
                description=article.get("description", ""),
                url=article.get("url", ""),
                image_url=article.get("image_url"),
                published_at=published_at,
                category=article.get("category", "finance"),
                author=article.get("author"),
                content=article.get("content"),
                cached_at=datetime.utcnow()
            )
            db.add(cached_news)

    db.commit()


async def get_cached_news(
    db: Session,
    category: str = "finance",
    max_age_hours: int = 24,
    limit: int = 20
) -> List[CachedNews]:
    """
    Get cached news articles.

    Args:
        db: Database session
        category: News category to filter
        max_age_hours: Maximum age of cached articles
        limit: Maximum number of articles to return

    Returns:
        List of cached news articles
    """
    cutoff_time = datetime.utcnow() - timedelta(hours=max_age_hours)

    articles = db.query(CachedNews).filter(
        CachedNews.category == category,
        CachedNews.cached_at >= cutoff_time
    ).order_by(
        CachedNews.published_at.desc()
    ).limit(limit).all()

    return articles


async def fetch_and_cache_news(db: Session, force_refresh: bool = False) -> None:
    """
    Fetch news from API and cache it.

    Args:
        db: Database session
        force_refresh: Whether to ignore cache and fetch fresh data
    """
    # Check if we have recent cached data
    if not force_refresh:
        recent = await get_cached_news(db, max_age_hours=6, limit=1)
        if recent:
            logger.info("Using cached news, skipping API fetch")
            return

    # Fetch fresh data from API
    try:
        articles = await fetch_news_from_api(
            query="finance economy stock market",
            page=1,
            page_size=30
        )
        if articles:
            await cache_articles(db, articles)
            logger.info(f"Cached {len(articles)} articles from NewsAPI")
    except Exception as e:
        logger.error(f"Error in fetch_and_cache_news: {e}")


def filter_news_for_profile(articles: List[CachedNews], profile: dict) -> List[CachedNews]:
    """
    Filter news articles based on user profile.

    Args:
        articles: List of articles
        profile: User profile data

    Returns:
        Filtered list of articles relevant to the profile
    """
    filtered = []

    for article in articles:
        title_lower = article.title.lower() if article.title else ""
        description_lower = article.description.lower() if article.description else ""
        content_lower = article.content.lower() if article.content else ""

        text = f"{title_lower} {description_lower} {content_lower}"

        # Check for loan/mortgage related
        if profile.get("num_loans", 0) > 0 and any(
            word in text for word in ["loan", "mortgage", "interest", "rate"]
        ):
            filtered.append(article)
            continue

        # Check for housing/real estate
        if profile.get("housing_type") and any(
            word in text for word in ["housing", "real estate", "property", "apartment", "home"]
        ):
            filtered.append(article)
            continue

        # Check for investment/savings
        if profile.get("savings_types") and any(
            word in text for word in ["investment", "stock", "fund", "savings", "portfolio"]
        ):
            filtered.append(article)
            continue

        # Check for tax/economic news
        if any(word in text for word in ["tax", "economic", "economy", "government"]):
            filtered.append(article)
            continue

        # Check for vehicle/transportation (if electric vehicle owner)
        if profile.get("vehicle_type") == "Elbil" and any(
            word in text for word in ["electric", "ev", "vehicle", "car", "tax", "subsidy"]
        ):
            filtered.append(article)
            continue

    return filtered[:20]  # Return top 20 articles

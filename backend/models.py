from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, JSON, ForeignKey, Text
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    first_name = Column(String)
    last_name = Column(String)
    hashed_password = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)

    profile = relationship("Profile", back_populates="user", uselist=False)

    def __repr__(self):
        return f"<User {self.email}>"


class Profile(Base):
    __tablename__ = "profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)

    # Basic info
    age = Column(Integer)
    region = Column(String)
    employment = Column(String)  # e.g., "Lønmodtager", "Selvstændig", "Studerende", "Pensioneret"
    annual_gross_income = Column(Float)

    # Housing
    housing_type = Column(String)  # e.g., "Lejebolig", "Andelsbolig", "Ejerbolig", "Sommerhus"
    housing_value = Column(Float)

    # Loans
    loan_types = Column(JSON)  # List of loan types
    num_loans = Column(Integer)
    total_debt = Column(Float)
    interest_rate_type = Column(String)  # e.g., "Fast", "Variabel", "Blandet"

    # Vehicle
    vehicle_type = Column(String)  # e.g., "Benzin/diesel", "Elbil", "Cykel/offentlig", "Hybrid"

    # Savings
    savings_types = Column(JSON)  # List of savings types

    # Insurance
    insurance_types = Column(JSON)  # List of insurance types

    # Preferences
    breaking_news = Column(Boolean, default=True)
    daily_digest = Column(Boolean, default=True)
    ai_insights = Column(Boolean, default=True)

    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="profile")

    def __repr__(self):
        return f"<Profile user_id={self.user_id}>"


class CachedNews(Base):
    __tablename__ = "cached_news"

    id = Column(Integer, primary_key=True, index=True)
    source = Column(String, index=True)  # e.g., "NewsAPI"
    title = Column(String)
    description = Column(Text)
    url = Column(String, unique=True)
    image_url = Column(String, nullable=True)
    published_at = Column(DateTime)
    category = Column(String)  # e.g., "business", "finance", "technology"
    author = Column(String, nullable=True)
    content = Column(Text, nullable=True)
    cached_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<CachedNews {self.title[:50]}>"

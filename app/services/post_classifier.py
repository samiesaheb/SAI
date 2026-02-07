#!/usr/bin/env python3
"""
Post Classifier - ML classification for Common Consensus posts.
Classifies text into categories and assigns a quality score.

Usage:
    echo "text content" | python3 post_classifier.py
    python3 post_classifier.py --text "text content"

Output (JSON):
    {"category": "psychology", "quality_score": 72.5}
"""

import sys
import json
import re
import math
from collections import Counter

CATEGORY_KEYWORDS = {
    "psychology": {
        "high": ["cognitive", "behavioral", "consciousness", "perception", "emotion",
                 "psychology", "psychological", "mental health", "therapy", "trauma",
                 "anxiety", "depression", "personality", "psychotherapy", "neuroscience",
                 "cognition", "subconscious", "unconscious", "freud", "jung",
                 "attachment", "developmental", "social psychology"],
        "medium": ["mind", "brain", "behavior", "feeling", "stress", "memory",
                   "learning", "motivation", "habit", "identity", "self",
                   "awareness", "intelligence", "disorder", "mental"],
    },
    "psychedelics": {
        "high": ["psychedelic", "psilocybin", "lsd", "dmt", "ayahuasca", "mescaline",
                 "mushroom", "entheogen", "microdosing", "trip", "hallucinogen",
                 "psychonautic", "ketamine", "ibogaine", "mdma", "serotonin",
                 "tryptamine", "5-ht2a", "neuroplasticity"],
        "medium": ["visionary", "mystical", "altered state", "expanded consciousness",
                   "set and setting", "integration", "ceremony", "plant medicine",
                   "shamanic", "transcendent"],
    },
    "religion": {
        "high": ["religion", "religious", "theology", "scripture", "divine", "god",
                 "prayer", "worship", "sacred", "spiritual", "faith", "church",
                 "mosque", "temple", "bible", "quran", "torah", "buddhism",
                 "christianity", "islam", "hinduism", "meditation", "dharma",
                 "karma", "salvation", "enlightenment"],
        "medium": ["soul", "holy", "ritual", "belief", "doctrine", "prophetic",
                   "mysticism", "transcendence", "afterlife", "heaven", "sin"],
    },
    "philosophy": {
        "high": ["philosophy", "philosophical", "epistemology", "ontology", "metaphysics",
                 "ethics", "morality", "existentialism", "phenomenology", "dialectic",
                 "socrates", "plato", "aristotle", "nietzsche", "kant", "hegel",
                 "descartes", "empiricism", "rationalism", "stoicism", "utilitarianism",
                 "determinism", "free will", "categorical imperative"],
        "medium": ["truth", "reason", "logic", "virtue", "justice", "wisdom",
                   "existence", "meaning", "purpose", "consciousness", "being",
                   "reality", "knowledge", "moral"],
    },
    "science": {
        "high": ["scientific", "hypothesis", "experiment", "data", "research",
                 "peer-reviewed", "empirical", "theory", "quantum", "evolution",
                 "biology", "chemistry", "physics", "genetics", "molecular",
                 "statistical", "methodology", "observation", "replication"],
        "medium": ["study", "evidence", "discovery", "laboratory", "analysis",
                   "measurement", "variable", "correlation", "causation", "model",
                   "cell", "atom", "energy", "natural", "species"],
    },
    "politics": {
        "high": ["politics", "political", "democracy", "government", "legislation",
                 "policy", "republican", "democrat", "congress", "parliament",
                 "sovereignty", "constitution", "amendment", "voting", "election",
                 "geopolitics", "authoritarianism", "liberalism", "conservatism",
                 "socialism", "capitalism", "anarchism", "diplomacy"],
        "medium": ["power", "state", "rights", "freedom", "liberty", "law",
                   "regulation", "citizen", "protest", "reform", "ideology",
                   "governance", "public", "civic"],
    },
    "economics": {
        "high": ["economics", "economic", "inflation", "gdp", "monetary", "fiscal",
                 "supply and demand", "market", "capitalism", "keynesian",
                 "macroeconomics", "microeconomics", "trade", "tariff", "subsidy",
                 "central bank", "interest rate", "cryptocurrency", "bitcoin",
                 "blockchain", "deficit", "surplus"],
        "medium": ["price", "cost", "profit", "investment", "stock", "bond",
                   "wealth", "poverty", "income", "tax", "budget", "finance",
                   "currency", "debt", "growth"],
    },
    "technology": {
        "high": ["technology", "software", "hardware", "algorithm", "artificial intelligence",
                 "machine learning", "programming", "computer", "internet", "digital",
                 "cybersecurity", "encryption", "cloud computing", "neural network",
                 "automation", "robotics", "quantum computing", "api", "database"],
        "medium": ["tech", "code", "app", "platform", "system", "network",
                   "device", "innovation", "data", "server", "protocol",
                   "interface", "virtual", "simulation"],
    },
    "art": {
        "high": ["art", "artistic", "aesthetic", "painting", "sculpture", "music",
                 "literature", "poetry", "cinema", "theater", "dance", "photography",
                 "creative", "composition", "expression", "surrealism", "impressionism",
                 "renaissance", "contemporary art", "avant-garde"],
        "medium": ["beauty", "design", "visual", "performance", "gallery", "museum",
                   "culture", "style", "form", "canvas", "color", "harmony",
                   "inspiration", "imagination"],
    },
}

HIGH_WEIGHT = 3
MEDIUM_WEIGHT = 1


def classify_category(text):
    """Classify text into a category based on keyword matching."""
    text_lower = text.lower()
    scores = {}

    for category, keywords in CATEGORY_KEYWORDS.items():
        score = 0
        for keyword in keywords.get("high", []):
            count = len(re.findall(r'\b' + re.escape(keyword) + r'\b', text_lower))
            score += count * HIGH_WEIGHT
        for keyword in keywords.get("medium", []):
            count = len(re.findall(r'\b' + re.escape(keyword) + r'\b', text_lower))
            score += count * MEDIUM_WEIGHT
        scores[category] = score

    if not scores or max(scores.values()) == 0:
        return "other"

    return max(scores, key=scores.get)


def calculate_quality_score(text):
    """
    Calculate a quality score (0-100) based on multiple text features:
    - Word count contribution (up to 5 points)
    - Paragraph structure (up to 20 points)
    - Source citations present (up to 20 points)
    - Vocabulary diversity (up to 30 points)
    - Sentence length variation (up to 25 points)
    """
    score = 0.0
    words = text.split()
    word_count = len(words)

    # Word count (up to 5 points)
    if word_count >= 1000:
        score += 5
    elif word_count >= 300:
        score += 2 + (word_count - 300) / 700 * 3
    else:
        score += word_count / 300 * 2

    # Paragraph structure (up to 20 points)
    paragraphs = [p.strip() for p in text.split('\n\n') if p.strip()]
    para_count = len(paragraphs)
    if para_count >= 5:
        score += 20
    elif para_count >= 3:
        score += 13
    elif para_count >= 2:
        score += 7

    # Source citations (up to 20 points)
    url_pattern = r'https?://[^\s]+'
    citation_patterns = [
        r'\[\d+\]',           # [1] style
        r'\(.*?\d{4}.*?\)',   # (Author, 2024) style
        url_pattern,           # URLs
    ]
    citation_count = 0
    for pattern in citation_patterns:
        citation_count += len(re.findall(pattern, text))

    if citation_count >= 5:
        score += 20
    elif citation_count >= 3:
        score += 15
    elif citation_count >= 1:
        score += 8

    # Vocabulary diversity (up to 30 points)
    if word_count > 0:
        unique_words = len(set(w.lower().strip('.,!?;:"\'-()[]') for w in words))
        diversity = unique_words / word_count
        # Typical diversity ranges from 0.3 (repetitive) to 0.7+ (diverse)
        diversity_score = min(30, max(0, (diversity - 0.3) / 0.4 * 30))
        score += diversity_score

    # Sentence length variation (up to 25 points)
    sentences = re.split(r'[.!?]+', text)
    sentences = [s.strip() for s in sentences if s.strip()]
    if len(sentences) >= 3:
        lengths = [len(s.split()) for s in sentences]
        avg_len = sum(lengths) / len(lengths)
        if avg_len > 0:
            variance = sum((l - avg_len) ** 2 for l in lengths) / len(lengths)
            std_dev = math.sqrt(variance)
            # Good writing typically has std_dev between 5-15
            if 5 <= std_dev <= 20:
                score += 25
            elif 3 <= std_dev < 5 or 20 < std_dev <= 25:
                score += 15
            else:
                score += 6

    return round(min(100, max(0, score)), 1)


def classify(text):
    """Main classification function."""
    category = classify_category(text)
    quality_score = calculate_quality_score(text)
    return {"category": category, "quality_score": quality_score}


if __name__ == "__main__":
    if "--text" in sys.argv:
        idx = sys.argv.index("--text")
        if idx + 1 < len(sys.argv):
            text = sys.argv[idx + 1]
        else:
            print(json.dumps({"error": "No text provided after --text"}))
            sys.exit(1)
    else:
        text = sys.stdin.read()

    if not text.strip():
        print(json.dumps({"category": "other", "quality_score": 0.0}))
        sys.exit(0)

    result = classify(text)
    print(json.dumps(result))

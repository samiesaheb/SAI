# SAI - Self-governing AI Communities

SAI is a community governance platform where users create and manage self-governing communities through democratic proposals, reputation-weighted voting, and blockchain-anchored content.

## Features

### Communities
- Create communities with configurable consensus thresholds, quorum requirements, and voting periods
- Invite-based membership via shareable invite links
- Categories spanning technology, science, philosophy, politics, art, and more

### Democratic Governance
- **Proposals** - Members submit proposals that go through a timed voting period
- **Consensus & Quorum** - Proposals pass only when quorum is met and the consensus threshold is reached
- **Laws** - Passed proposals become laws, forming the community's rule book
- **Law Votes** - Members can vote on existing laws to signal ongoing approval or dissent

### Content
- **Posts** - Short-form content across categories (psychology, philosophy, science, etc.) with ML-based classification and quality scoring
- **Memes** - Image-based content with community voting
- **Comments** - Threaded comments on posts and memes with upvote/downvote support

### Reputation System
- Five-tier reputation levels: Newcomer, Member, Trusted, Veteran, Elder
- Reputation earned through community participation (passing proposals, canonical content, voting with majority)
- **Weighted voting** - Higher reputation means greater vote influence (1x to 3x)

### Blockchain Integration
- Posts are timestamped with Bitcoin block height and hash via the Blockchain.info API
- Content can be time-locked until a specific block height
- Built-in block explorer

### Other
- Activity feed tracking community events
- Global search across communities, posts, and memes
- ML-powered post classification and quality scoring

## Tech Stack

- **Framework:** Ruby on Rails 8.0
- **Ruby:** 3.4.4
- **Database:** SQLite3
- **Frontend:** Hotwire (Turbo + Stimulus), Import Maps, Propshaft
- **Auth:** bcrypt (has_secure_password)
- **Background Jobs:** Solid Queue
- **Caching:** Solid Cache
- **WebSockets:** Solid Cable
- **Deployment:** Kamal + Docker

## Getting Started

### Prerequisites

- Ruby 3.4.4
- SQLite3
- Python 3 (for ML post classifier)

### Setup

```bash
git clone https://github.com/samiesaheb/SAI.git
cd SAI
bin/setup
```

This will install dependencies, create the database, and run migrations.

### Run the Server

```bash
bin/dev
```

Visit `http://localhost:3000`.

### Run Tests

```bash
bin/rails test
```

### Run Background Jobs

```bash
bin/jobs
```

## Database Schema

Key models and their relationships:

```
User
 ├── Memberships (has reputation, role, vote weight)
 ├── Proposals (authored)
 ├── Posts (authored, ML-classified, Bitcoin-stamped)
 ├── Memes (authored)
 └── Comments (authored)

Community
 ├── Memberships
 ├── Proposals → Votes → Laws
 ├── Posts → PostVotes
 ├── Memes → MemeVotes
 └── Activities (feed)

Block (Bitcoin block mirror)
```

## License

All rights reserved.

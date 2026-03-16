# AceUp Tech Assessment - Backend

Ruby on Rails 7.2 API-only application for the order management system.

## Ruby Version
- Ruby 3.2.8
- Rails 7.2.0

## System Dependencies
- PostgreSQL 15
- Redis 7
- Node.js (for asset pipeline)

## Testing Framework
This project uses RSpec for testing with the following gems:
- `rspec-rails` (~> 7.1) - Testing framework
- `factory_bot_rails` (~> 6.2) - Test data generation
- `faker` (~> 3.2) - Realistic test data
- `shoulda-matchers` (~> 5.3) - Validation testing

### Test Structure
```
spec/
├── factories/          # FactoryBot definitions
├── models/            # Model tests
├── requests/          # API endpoint tests
├── services/          # Business logic tests
└── support/           # Test configuration
```

## Database Configuration
- Uses transactional fixtures for test isolation
- Test database: `aceup_db_test`
- No Database Cleaner needed (Rails 7.2 native approach)

## Development Commands

Common development tasks are available through the Makefile. running `make {command}`

Build Docker images.(Or Installing new gems.):

`images.build`

Installing new gems.Start all services:

`make start`

Stop all services:

`make stop`

Open a Rails console:

`make rails.c`

Open a shell inside the backend container:

`make sh`

Update gems:

`make bundle.update`

Run RuboCop:

`make rubocop`

Auto-fix RuboCop issues:

`make rubocop.autofix`

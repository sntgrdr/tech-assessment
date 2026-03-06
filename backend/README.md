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

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test types
bundle exec rspec spec/models
bundle exec rspec spec/requests
bundle exec rspec spec/services

# Run with verbose output
bundle exec rspec --format documentation
```

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
```bash
# Start development server
rails server -b 0.0.0.0

# Run migrations
rails db:migrate

# Access Rails console
rails console

# Run tests
bundle exec rspec
```

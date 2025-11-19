---
name: code-review
description: Code review checklist, quality standards, and best practices. Use when: review, code quality, refactor, clean code.
---

# Code Review Skill

## Quick Start Checklist

- [ ] Code follows project style guide
- [ ] No hardcoded values (use config/env)
- [ ] Error handling implemented
- [ ] Tests cover new code
- [ ] No security vulnerabilities
- [ ] Performance acceptable
- [ ] Documentation updated

## Review Focus Areas

### Readability
- Clear variable/function names
- Logical code organization
- Appropriate comments
- No overly complex functions

### Correctness
- Logic is sound
- Edge cases handled
- No race conditions
- Proper null/undefined checks

### Security
- Input validation
- No SQL injection risk
- No XSS vulnerabilities  
- Secrets not in code

### Performance
- No N+1 queries
- Efficient algorithms
- Appropriate caching
- Resource cleanup

### Maintainability
- DRY principle followed
- Single responsibility
- Low coupling
- High cohesion

## Common Issues

**Magic Numbers**: Replace with named constants
**God Functions**: Break into smaller functions
**Tight Coupling**: Use dependency injection
**Missing Tests**: Add unit/integration tests
**Poor Naming**: Use descriptive names

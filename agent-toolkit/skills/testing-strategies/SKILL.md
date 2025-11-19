---
name: testing-strategies
description: Testing methodologies, patterns, and coverage strategies. Use when: test, testing, coverage, unit test, integration test.
---

# Testing Strategies Skill

## Testing Pyramid

```
      /\-----\      E2E Tests (Few)
     /--------\     Integration Tests (Some)
    /----------\    Unit Tests (Many)
```

## Quick Start

### Unit Test Template
```python
def test_function_name():
    # Arrange
    input_data = setup_test_data()
    
    # Act
    result = function_under_test(input_data)
    
    # Assert
    assert result == expected_output
```

### Test Categories

**Unit Tests**: Test individual functions
**Integration Tests**: Test component interaction
**E2E Tests**: Test full user workflows
**Performance Tests**: Test speed/load
**Security Tests**: Test vulnerabilities

## Coverage Goals

- Aim for 80%+ code coverage
- 100% coverage for critical paths
- Focus on business logic
- Test edge cases and errors

## Testing Patterns

### Test Data Builders
Create reusable test data factories.

### Mocking External Dependencies
Mock APIs, databases, file systems.

### Parameterized Tests
Test multiple inputs with one test function.

### Snapshot Testing
Verify output hasn't changed unexpectedly.

## Guidelines

- Test one thing per test
- Keep tests fast (<1s each)
- Make tests deterministic
- Use descriptive test names
- Clean up after tests

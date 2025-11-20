---
name: api-patterns
description: REST API design patterns, best practices, and implementation guidelines. Use when: API, REST, endpoint, route, HTTP.
---

# API Patterns Skill

## Quick Start

### RESTful Route Design
```
GET    /api/resources       # List all
GET    /api/resources/:id   # Get one
POST   /api/resources       # Create
PUT    /api/resources/:id   # Update
DELETE /api/resources/:id   # Delete
```

### Response Structure
```json
{
  "success": true,
  "data": {...},
  "meta": {
    "timestamp": "ISO-8601",
    "version": "v1"
  }
}
```

### Error Handling
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {...}
  }
}
```

## Patterns

### Authentication Middleware
Always verify tokens before processing requests.

### Input Validation  
Validate all inputs against schema before processing.

### Rate Limiting
Implement per-user or per-IP rate limits.

### Versioning
Use URL versioning: `/api/v1/`, `/api/v2/`

## Guidelines

- Use proper HTTP status codes (200, 201, 400, 401, 404, 500)
- Return consistent response formats
- Document all endpoints with examples
- Implement pagination for list endpoints
- Use HTTPS only in production

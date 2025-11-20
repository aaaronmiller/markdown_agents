---
name: database-optimization
description: Database query optimization, indexing strategies, and performance tuning. Use when: database, query, SQL, index, performance.
---

# Database Optimization Skill

## Quick Wins

### Add Indexes
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);
```

### Query Optimization
```sql
-- Bad: SELECT *
SELECT * FROM users WHERE email = 'user@example.com';

-- Good: Select only needed columns
SELECT id, name, email FROM users WHERE email = 'user@example.com';
```

### Use EXPLAIN
```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;
```

## Optimization Strategies

### Indexing
- Index foreign keys
- Index columns in WHERE clauses
- Index columns in ORDER BY
- Consider composite indexes
- Avoid over-indexing (writes slower)

### Query Patterns
- Avoid SELECT *
- Use LIMIT for large result sets
- Use JOINs instead of subqueries
- Batch inserts when possible
- Use prepared statements

### N+1 Query Problem
**Bad**: Load users, then load posts for each user (N+1 queries)
**Good**: Load users with posts in one query (JOIN or eager loading)

### Connection Pooling
Reuse database connections instead of creating new ones.

### Caching
Cache frequently accessed, rarely changed data.

## Monitoring

- Track slow queries (>1s)
- Monitor connection pool usage
- Check index usage statistics
- Watch for table locks
- Monitor disk I/O

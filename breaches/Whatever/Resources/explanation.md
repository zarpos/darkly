# 🔓 Flag: Whatever — Default Admin Panel Access

## Vulnerability Type
**Security Misconfiguration** — Exposed Admin Panel + Weak Credentials

## Description

This flag is a direct continuation of the **Robots.txt** breach. The `/whatever` path exposed via `robots.txt` contained a file with these credentials:

```
root:437394baff5aa33daa618be47b75cb49
```

Decoding the MD5 hash:

| Hash | Decoded |
|------|---------|
| `437394baff5aa33daa618be47b75cb49` | `qwerty123@` |

The site also exposes a standard admin panel at `/admin` — a predictable path commonly used in CMS platforms like WordPress.

## Exploit

1. Navigate to `http://[IP]/admin`.
2. Enter the credentials found via `robots.txt`:

| Field | Value |
|-------|-------|
| Username | `root` |
| Password | `qwerty123@` |

3. The flag is revealed upon successful login.

## How It Works

Two vulnerabilities chain together to make this trivial:

1. **Information Disclosure via `robots.txt`** — The `/whatever` path (exposed in `robots.txt`) contained plaintext credentials in MD5 format.
2. **Weak Password Hashing** — MD5 is a cryptographically broken algorithm. A password like `qwerty123@` can be reversed in milliseconds using any online MD5 lookup table.
3. **Predictable Admin URL** — The admin panel lives at the default `/admin` path with no additional protection.

## Mitigation

- **Never store credentials in publicly accessible files**.
- **Never use MD5 for password storage** — use `bcrypt`, `argon2`, or `scrypt`.
- Protect admin panels with additional layers: IP allowlisting, VPN access, or MFA.
- Use unpredictable admin URLs or move the admin panel off the public-facing web server entirely.

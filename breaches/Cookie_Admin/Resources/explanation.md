# 🍪 Flag: Cookie Admin — Cookie Tampering

## Vulnerability Type
**Insecure Client-Side Authorization** — Cookie Manipulation

## Description

While inspecting the browser's developer tools (DevTools → Application → Cookies), a cookie named `I_Am_Admin` is visible. Its value is an **MD5 hash** that decodes to the string `false`:

| Cookie Name | MD5 Value | Decoded Value |
|-------------|-----------|---------------|
| `I_Am_Admin` | `68934a3e9455fa72420237eb05902327` | `false` |

The server uses this cookie to decide whether the current user has admin privileges — a classic example of broken access control based on client-supplied data.

## Exploit

1. Open DevTools → **Application** tab → **Cookies**.
2. Find the cookie `I_Am_Admin`.
3. Replace its value with the MD5 hash of the string `true`:

```
MD5("true") = b326b5062b2f0e69046810717534cb09
```

4. Reload the page — the flag is revealed immediately.

Alternatively, you can modify it directly from the browser console:

```javascript
document.cookie = "I_Am_Admin=b326b5062b2f0e69046810717534cb09";
location.reload();
```

## How It Works

The server reads the `I_Am_Admin` cookie, computes nothing, and simply checks whether the value equals the MD5 of `"true"`. Because cookies are stored on the client and can be freely edited, any user can escalate themselves to admin.

## Mitigation

- **Never store authorization state in client-side cookies** without cryptographic signing (e.g., HMAC).
- Use **server-side sessions** where privilege levels are stored on the server and referenced by an opaque, unpredictable session ID.
- If cookies must carry data, use a framework-provided signed/encrypted cookie mechanism (e.g., JWT with signature verification, Flask's `itsdangerous`, etc.).

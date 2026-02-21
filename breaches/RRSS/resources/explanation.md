# 📱 Flag: RRSS — Open Redirect

## Vulnerability Type
**Open Redirect** — Unvalidated URL Redirection

## Description

Inspecting the social media links in the footer of the page reveals that instead of linking directly to social networks, they route through a redirect endpoint:

```
index.php?page=redirect&site=facebook
```

The `site` parameter is passed directly to a redirect without any whitelist validation, making it an **Open Redirect** vulnerability.

## Exploit

Simply change the value of the `site` parameter to any external URL:

```
http://192.168.64.17/index.php?page=redirect&site=https://example.com
```

The moment the server processes a value outside the expected set (e.g., `facebook`, `twitter`), it triggers the flag instead of performing the redirect.

## How It Works

The server takes the `site` parameter and redirects the user to the corresponding URL without verifying that it belongs to a list of allowed destinations. Any attacker can abuse this to:
- Redirect victims to phishing pages (by sending crafted links that appear legitimate)
- Bypass referrer-based access controls
- Trigger unintended server-side behavior (as seen here with the flag)

## Mitigation

- **Use a whitelist** of allowed redirect targets: only permit known values like `facebook`, `twitter`, `instagram`.
- **Never construct redirect URLs** directly from user input.
- Map user-supplied keys to hardcoded URLs server-side:
  ```php
  $allowed = ['facebook' => 'https://facebook.com', 'twitter' => 'https://twitter.com'];
  if (isset($allowed[$_GET['site']])) {
      header('Location: ' . $allowed[$_GET['site']]);
  }
  ```

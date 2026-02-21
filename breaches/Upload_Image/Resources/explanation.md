# 📤 Flag: Upload Image — File Upload Validation Bypass

## Vulnerability Type
**Unrestricted File Upload** — Extension-Only Validation Bypass via MIME-type Spoofing

## Description

The image upload endpoint validates files by only checking the **final file extension** and/or the `Content-Type` header sent by the client. Since both of these are entirely controlled by the attacker, the validation can be trivially bypassed to upload a PHP script disguised as an image.

## Exploit Walkthrough

### Step 1 — Direct upload fails

Uploading a file named `image.php` (containing just `a`, 2 bytes) is rejected:
```
Your image was not uploaded.
```

### Step 2 — Extension stacking succeeds

Renaming the file to `image.php.jpg` (adding `.jpg` as the final extension) tricks the validator:
```
/tmp/image.php.jpg successfully uploaded.
```

This reveals that the server only checks the **last extension** — a very weak validation.

### Step 3 — Intercept and modify the POST request

Using DevTools (Network tab → Copy as Fetch) or a proxy (Burp Suite), intercept the upload POST request and modify two fields:

| Field | Original | Modified |
|-------|----------|---------|
| `filename` | `image.php.jpg` | `test.php` |
| `Content-Type` | `image/jpeg` | `image/jpeg` (unchanged) |

By keeping `Content-Type: image/jpeg` while sending a `.php` filename, we bypass both checks simultaneously — the server sees an image content type but stores a PHP file.

### Step 4 — Flag

The server accepts the file and reveals the flag.

## How It Works

The server performs two weak checks:
1. **Extension check** — only looks at the last extension (easily bypassed with double extensions).
2. **Content-Type check** — reads the `Content-Type` header from the HTTP request, which is set by the client and can be set to anything.

Neither check reliably identifies the true nature of the uploaded file.

## Mitigation

- **Check the actual file content** (magic bytes / file signature), not just the extension or Content-Type header.
- **Rename uploaded files** to a random, server-generated name with a safe extension — never preserve the original filename.
- **Store uploads outside the web root** so even if a PHP file is uploaded, it cannot be executed via URL.
- Validate against a strict whitelist of allowed MIME types using server-side inspection (e.g., `finfo_file()` in PHP).
- Disable script execution in the upload directory via web server configuration.

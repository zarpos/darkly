# 🤖 Flag: Robots.txt — Information Disclosure via robots.txt

## Vulnerability Type
**Information Disclosure** — `robots.txt` Enumeration + Hidden Directory Traversal

## Description

The `robots.txt` file is a standard web convention that instructs search engine crawlers which paths to skip. However, it is publicly accessible and frequently **reveals sensitive or hidden directories** to attackers — the opposite of its intended effect.

Accessing `http://[IP]/robots.txt` returns:

```
User-agent: *
Disallow: /whatever
Disallow: /.hidden
```

Both disallowed paths exist and contain exploitable content.

## Path 1 — `/whatever`

Navigating to `http://[IP]/whatever` exposes a single file containing:

```
root:437394baff5aa33daa618be47b75cb49
```

This is a `user:MD5hash` pair. Decoding the MD5:

| Hash | MD5 Decoded |
|------|-------------|
| `437394baff5aa33daa618be47b75cb49` | `qwerty123@` |

These credentials (`root` / `qwerty123@`) are later used in the **Whatever** flag to log into the `/admin` panel.

## Path 2 — `/.hidden`

Navigating to `http://[IP]/.hidden` reveals a deep directory tree with hundreds of subdirectories, most containing `README` files with decoy messages in French:

```
Tu veux de l'aide ? Moi aussi !
Toujours pas...
Non plus
```

One specific `README` contains the actual flag.

### Exploit

Use `wget` to recursively download only `README` files from the entire hidden directory structure:

```bash
wget -r -l 0 -np -nd -A "README" http://[IP]/.hidden/
```

| Flag | Meaning |
|------|---------|
| `-r` | Recursive — traverse all subdirectories |
| `-l 0` | No depth limit |
| `-np` | No Parent — don't go above `/.hidden/` |
| `-nd` | No Directories — save all files flat in the current directory |
| `-A "README"` | Accept only files named `README` |

Then filter out the decoy messages to find the real flag:

```bash
grep -vE "Moi aussi|Toujours pas|Tu veux de l'aide|Non plus" README*
```

Or search within the downloaded directory tree:

```bash
find . -name "README" -exec cat {} + | grep -vE "Moi aussi|Toujours pas|Tu veux de l'aide|Non plus|voisin|toujours pas"
```

## Mitigation

- **Do not list sensitive paths in `robots.txt`**. Security through obscurity is not security, but advertising hidden directories in `robots.txt` is even worse.
- Protect sensitive directories with authentication, not just by hiding them.
- Regularly audit directory listings and ensure web servers do not expose directory indexes.

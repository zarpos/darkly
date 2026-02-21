# 📊 Flag: Survey — Parameter Tampering / Integer Overflow

## Vulnerability Type
**Improper Input Validation** — Client-Side Constraint Bypass / Parameter Tampering

## Description

The Survey page allows users to cast a vote on a scale from **1 to 10**. While the UI enforces this range through a dropdown menu, the server performs **no validation** on the submitted value. An attacker can override the UI-enforced limit and send any arbitrary number directly via the HTTP request.

## Exploit

### Step 1 — Cast a legitimate vote

Submit any vote (e.g., `5`) and observe the network activity in the DevTools **Network** tab. A POST request is sent to `?survey`.

### Step 2 — Copy the request as Fetch

Right-click the request in the Network tab → **Copy as Fetch**. This gives you the raw HTTP request as JavaScript.

### Step 3 — Modify the payload

Change the vote value from the valid range to an overflow value like `100`:

```javascript
fetch("/index.php?page=survey", {
  method: "POST",
  headers: { "Content-Type": "application/x-www-form-urlencoded" },
  body: "sujet=2&valeur=100"   // valeur is the vote field
});
```

Run this in the browser console.

### Step 4 — Check the response

In the **Preview** of the response, the flag is visible.

## How It Works

The server stores or processes the vote as an integer without clamping it to the allowed range (1–10). Sending `100` (or any value outside the expected bounds) causes an **integer overflow** or unexpected state in the application logic, which triggers the flag as an error/boundary condition.

## Mitigation

- **Always validate user input server-side**, even when the UI already enforces constraints.
- Client-side validation (dropdowns, min/max attributes, JavaScript) is purely for UX — it provides **zero security**.
- Sanitize numeric inputs: check that the value is within the expected range before processing.

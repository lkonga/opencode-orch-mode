# Local Gemini (gemini-2.5-pro) — Quick Fix & Notes

This project uses a local Gemini (Google Generative AI) proxy running at http://localhost:8001. During setup I experienced requests being redirected (307 -> 405) by the proxy when opencode called the provider. The issue was caused by the AI SDK constructing a path that did not include the `v1beta` prefix expected by the proxy.

What I changed

- Edited `.opencode_global/opencode.json` and updated the Google provider `baseURL` to include `/v1beta`:

```json
"google": {
  "name": "Google Gemini (local)",
  "options": {
    "baseURL": "http://localhost:8001/v1beta",
    "apiKey": "dev-token",
    "debug": true
  },
  "models": {
    "gemini-2.5-pro": { ... }
  }
}
```

Why this fixes it

- The Google AI SDK composes requests using `{baseURL}/{modelPath}:streamGenerateContent?alt=sse` (and similar endpoints). When `baseURL` didn't include `/v1beta`, the resulting request path was `/models/...:streamGenerateContent` which the proxy flagged as unauthorized and redirected to `/`, resulting in a 405.
- Including `/v1beta` ensures the SDK calls `/v1beta/models/<model>:...` which matches the proxy routing and authentication enforcement.

How to validate

1. Start or restart opencode (server) so it loads the updated config.
2. Tail the proxy logs and opencode logs. Trigger a session or prompt in opencode that uses `google/gemini-2.5-pro`.

Look for these lines in the proxy logs (indicative of success):

- `ProxyEnforcementMiddleware: path=/v1beta/models/gemini-2.5-pro:streamGenerateContent`
- `dev-token mapped to outbound_api_key=...`
- `POST /v1beta/models/gemini-2.5-pro%3AstreamGenerateContent?alt=sse HTTP/1.1" 200`
- `Streaming completed successfully`

Notes and next steps

- I kept `debug: true` in the provider options temporarily to help troubleshooting. Remove it once you're satisfied.
- Grounding (web search) — next: I will analyze upstream `sst/opencode` and `vercel/ai` to find the correct parameter or tool to enable grounding (Google Search) when calling Gemini via opencode. I'll update this README with the exact param once confirmed.

Contact / Troubleshooting

If you still see 307 → 405 after this change, verify:
- The proxy is listening on `http://localhost:8001` and expects `/v1beta` prefix.
- `dev-token` is being sent via header `x-goog-api-key` (or whichever header your proxy expects).
- No other reverse-proxy in front (NGINX, Cloudflare) is rewriting paths.


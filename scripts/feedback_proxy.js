/**
 * NoteKar Secure Feedback Proxy (Cloudflare Workers template)
 * 
 * Securely forwards in-app bug reports and feature requests to GitHub Issues
 * without leaking your GitHub Personal Access Token (PAT).
 * 
 * Setup:
 * 1. Deploy this script as a Cloudflare Worker.
 * 2. Set environment secrets inside your Cloudflare Worker Dashboard:
 *    - GITHUB_TOKEN: A GitHub PAT with write permission to your repository's issues.
 *    - NOTEKAR_API_KEY: A secret header string shared with the app client (to prevent direct bot spam).
 */

export default {
  async fetch(request, env, ctx) {
    // 1. CORS Preflight handle
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, X-Notekar-API-Key",
        }
      });
    }

    if (request.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    try {
      // 2. Validate API Key header
      const clientApiKey = request.headers.get("X-Notekar-API-Key");
      if (!clientApiKey || clientApiKey !== env.NOTEKAR_API_KEY) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), {
          status: 401,
          headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
        });
      }

      const payload = await request.json();
      const { title, body, labels } = payload;

      if (!title || !body) {
        return new Response(JSON.stringify({ error: "Title and Body are required" }), {
          status: 400,
          headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
        });
      }

      // 3. Post to GitHub Issues API
      const repoOwner = "dheeraz101";
      const repoName = "Notekar-Android";
      const githubUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/issues`;

      const ghResponse = await fetch(githubUrl, {
        method: "POST",
        headers: {
          "Authorization": `token ${env.GITHUB_TOKEN}`,
          "User-Agent": "NoteKar-Feedback-Proxy",
          "Accept": "application/vnd.github.v3+json",
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          title: title,
          body: body,
          labels: labels || []
        })
      });

      if (!ghResponse.ok) {
        const errText = await ghResponse.text();
        return new Response(JSON.stringify({ error: `GitHub API error: ${errText}` }), {
          status: ghResponse.status,
          headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
        });
      }

      const issueData = await ghResponse.json();
      return new Response(JSON.stringify({ success: true, url: issueData.html_url }), {
        status: 201,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });

    } catch (err) {
      return new Response(JSON.stringify({ error: err.message }), {
        status: 500,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }
  }
};

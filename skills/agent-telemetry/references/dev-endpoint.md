# Dev Log Endpoint

Implementation patterns for a development-only HTTP endpoint that agents can query for log entries.

## Table of Contents

- [Next.js App Router](#nextjs-app-router)
- [Express](#express)
- [Rails](#rails)
- [Security](#security)

## Next.js App Router

```ts
// app/api/__dev/logs/route.ts
import { NextRequest, NextResponse } from "next/server";
import { readFileSync } from "fs";

// Only available in development
if (process.env.NODE_ENV !== "development") {
  throw new Error("Dev log endpoint must not be loaded in production");
}

const LOG_FILE = process.env.LOG_FILE || "logs/app.json";
const MAX_ENTRIES = 500;

export async function GET(req: NextRequest) {
  const params = req.nextUrl.searchParams;
  const level = params.get("level");
  const path = params.get("path");
  const requestId = params.get("requestId");
  const last = Math.min(parseInt(params.get("last") || "100"), MAX_ENTRIES);
  const since = params.get("since"); // ISO timestamp

  let lines: string[];
  try {
    lines = readFileSync(LOG_FILE, "utf-8").trim().split("\n");
  } catch {
    return NextResponse.json({ error: "Log file not found", path: LOG_FILE }, { status: 404 });
  }

  let entries = lines
    .map((line) => { try { return JSON.parse(line); } catch { return null; } })
    .filter(Boolean);

  if (level) entries = entries.filter((e) => e.level === level);
  if (path) entries = entries.filter((e) => e.path?.includes(path));
  if (requestId) entries = entries.filter((e) => e.requestId === requestId);
  if (since) entries = entries.filter((e) => new Date(e.timestamp) >= new Date(since));

  entries = entries.slice(-last);

  return NextResponse.json(entries);
}
```

## Express

```ts
// routes/dev-logs.ts
import { Router, Request, Response } from "express";
import { readFileSync } from "fs";

const router = Router();
const LOG_FILE = process.env.LOG_FILE || "logs/app.json";
const MAX_ENTRIES = 500;

router.get("/__dev/logs", (req: Request, res: Response) => {
  const { level, path, requestId, last = "100", since } = req.query;
  const limit = Math.min(parseInt(last as string), MAX_ENTRIES);

  let lines: string[];
  try {
    lines = readFileSync(LOG_FILE, "utf-8").trim().split("\n");
  } catch {
    return res.status(404).json({ error: "Log file not found", path: LOG_FILE });
  }

  let entries = lines
    .map((line) => { try { return JSON.parse(line); } catch { return null; } })
    .filter(Boolean);

  if (level) entries = entries.filter((e) => e.level === level);
  if (path) entries = entries.filter((e) => e.path?.includes(path as string));
  if (requestId) entries = entries.filter((e) => e.requestId === requestId);
  if (since) entries = entries.filter((e) => new Date(e.timestamp) >= new Date(since as string));

  res.json(entries.slice(-limit));
});

export default router;

// app.ts — only register in development
if (process.env.NODE_ENV === "development") {
  app.use(devLogsRouter);
}
```

## Rails

```ruby
# config/routes.rb
if Rails.env.development?
  get '__dev/logs', to: 'dev/logs#index'
end

# app/controllers/dev/logs_controller.rb
module Dev
  class LogsController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    MAX_ENTRIES = 500

    def index
      log_path = Rails.root.join('log', 'structured.json')
      unless File.exist?(log_path)
        return render json: { error: 'Log file not found', path: log_path.to_s }, status: :not_found
      end

      lines = File.readlines(log_path).last([params.fetch(:last, 100).to_i, MAX_ENTRIES].min)
      entries = lines.filter_map { |line| JSON.parse(line) rescue nil }

      entries = entries.select { |e| e['level'] == params[:level] } if params[:level]
      entries = entries.select { |e| e['path']&.include?(params[:path]) } if params[:path]
      entries = entries.select { |e| e['request_id'] == params[:request_id] } if params[:request_id]

      if params[:since]
        cutoff = Time.parse(params[:since])
        entries = entries.select { |e| Time.parse(e['timestamp']) >= cutoff }
      end

      render json: entries
    end
  end
end
```

## Security

**The dev endpoint MUST:**
- Be disabled in production (compile-time or startup check, not runtime)
- Not require authentication (agents need unauthenticated access in dev)
- Not expose sensitive fields (redact tokens, passwords, PII before logging)
- Limit response size to prevent memory issues

**Recommended approach — fail loudly if misconfigured:**

```ts
// Startup check, not runtime check
if (process.env.NODE_ENV === "production") {
  throw new Error("FATAL: Dev log endpoint loaded in production");
}
```

This is safer than `if (env !== "development") return 403` because it prevents the route from existing at all in production.

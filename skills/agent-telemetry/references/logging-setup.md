# Logging Setup by Framework

Framework-specific patterns for adding structured JSON logging.

## Table of Contents

- [Next.js / Node.js (pino)](#nextjs--nodejs-pino)
- [Express (pino-http)](#express-pino-http)
- [Rails (lograge)](#rails-lograge)
- [Django (structlog)](#django-structlog)
- [General Principles](#general-principles)

## Next.js / Node.js (pino)

Install: `npm install pino pino-pretty`

```ts
// lib/logger.ts
import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL || "info",
  transport:
    process.env.NODE_ENV === "development"
      ? { target: "pino-pretty", options: { colorize: true } }
      : undefined,
  // Write structured JSON to file for agent access
  ...(process.env.LOG_FILE && {
    transport: { target: "pino/file", options: { destination: process.env.LOG_FILE } },
  }),
});
```

For API routes, create a wrapper that adds request context:

```ts
// lib/with-logging.ts
import { NextRequest, NextResponse } from "next/server";
import { logger } from "./logger";
import { randomUUID } from "crypto";

export function withLogging(
  handler: (req: NextRequest, ctx: { requestId: string; log: typeof logger }) => Promise<NextResponse>
) {
  return async (req: NextRequest) => {
    const requestId = req.headers.get("x-request-id") || randomUUID();
    const log = logger.child({ requestId, method: req.method, path: req.nextUrl.pathname });
    const start = Date.now();

    try {
      log.info("request started");
      const res = await handler(req, { requestId, log });
      log.info({ statusCode: res.status, duration: Date.now() - start }, "request completed");
      return res;
    } catch (error) {
      log.error({ error, duration: Date.now() - start }, "request failed");
      throw error;
    }
  };
}
```

Usage:

```ts
// app/api/users/route.ts
import { withLogging } from "@/lib/with-logging";

export const GET = withLogging(async (req, { log }) => {
  const users = await db.users.findMany();
  log.info({ count: users.length }, "fetched users");
  return NextResponse.json(users);
});
```

## Express (pino-http)

Install: `npm install pino pino-http pino-pretty`

```ts
// middleware/logger.ts
import pino from "pino";
import pinoHttp from "pino-http";
import { randomUUID } from "crypto";

export const logger = pino({
  level: process.env.LOG_LEVEL || "info",
});

export const httpLogger = pinoHttp({
  logger,
  genReqId: (req) => req.headers["x-request-id"] || randomUUID(),
  serializers: {
    req: (req) => ({ method: req.method, url: req.url, params: req.params }),
    res: (res) => ({ statusCode: res.statusCode }),
  },
});

// app.ts
app.use(httpLogger);
```

## Rails (lograge)

Add to Gemfile: `gem 'lograge'`

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:request_id],
      user_id: event.payload[:user_id],
      params: event.payload[:params].except('controller', 'action', 'format')
    }
  end

  # Write to file for agent access in development
  if Rails.env.development?
    config.lograge.logger = ActiveSupport::Logger.new(Rails.root.join('log', 'structured.json'))
  end
end
```

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.request_id
    payload[:user_id] = current_user&.id
  end
end
```

## Django (structlog)

Install: `pip install structlog`

```python
# settings.py
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.dev.ConsoleRenderer() if DEBUG else structlog.processors.JSONRenderer(),
    ],
    logger_factory=structlog.PrintLoggerFactory(),
)

LOGGING = {
    "version": 1,
    "handlers": {
        "structured_file": {
            "class": "logging.FileHandler",
            "filename": BASE_DIR / "logs" / "structured.json",
        },
    },
    "root": {"handlers": ["structured_file"], "level": "INFO"},
}
```

```python
# middleware.py
import structlog
import uuid

logger = structlog.get_logger()

class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(
            request_id=request_id,
            method=request.method,
            path=request.path,
        )

        import time
        start = time.monotonic()
        response = self.get_response(request)
        duration = round((time.monotonic() - start) * 1000)

        logger.info("request completed", status_code=response.status_code, duration=duration)
        return response
```

## General Principles

**Standard field names across all frameworks:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `timestamp` | ISO-8601 | Yes | When the event occurred |
| `level` | string | Yes | info, warn, error |
| `message` | string | Yes | Human-readable description |
| `requestId` | UUID | Yes | Correlation ID for the request |
| `method` | string | For HTTP | HTTP method |
| `path` | string | For HTTP | Request path |
| `statusCode` | number | For HTTP | Response status |
| `duration` | number | For HTTP | Response time in ms |
| `userId` | string | If authed | Current user identifier |
| `error` | object | If error | Error name, message, stack |

**Log file location convention:**

```
logs/
├── app.json          # All structured logs (primary agent target)
├── app.error.json    # Error-level only (quick error scanning)
└── .gitkeep
```

Add `logs/*.json` to `.gitignore`. Add `logs/.gitkeep` to track the directory.

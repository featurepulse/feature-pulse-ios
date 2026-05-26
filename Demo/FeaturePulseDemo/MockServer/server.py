#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime, timezone
import json
import sys
from urllib.parse import parse_qs, urlparse


REQUESTS = [
    {
        "id": "mock-request-1",
        "title": "Dark mode for dashboard",
        "description": "Let users switch the full dashboard into a darker theme for late-night planning.",
        "status": "planned",
        "vote_count": 124,
        "has_voted": False,
        "is_owner": False,
        "created_at": "2026-05-24T10:00:00Z",
    },
    {
        "id": "mock-request-2",
        "title": "CSV export",
        "description": "Export feature requests, votes, and MRR impact to CSV for internal reporting.",
        "status": "in_progress",
        "vote_count": 83,
        "has_voted": True,
        "is_owner": False,
        "created_at": "2026-05-25T11:30:00Z",
    },
    {
        "id": "mock-request-3",
        "title": "Custom status colors",
        "description": "Configure roadmap status labels and colors from the dashboard.",
        "status": "completed",
        "vote_count": 46,
        "has_voted": False,
        "is_owner": True,
        "created_at": "2026-05-26T12:00:00Z",
    },
]

SETTINGS = {
    "show_status": True,
    "show_translation": False,
}


def feature_requests_payload(requests=None):
    return {
        "success": True,
        "data": requests or list(REQUESTS),
        "show_status": SETTINGS["show_status"],
        "show_translation": SETTINGS["show_translation"],
        "show_watermark": False,
        "permissions": {"can_create_feature_request": True},
        "status_config": {
            "pending": {"color": "#EAB308", "icon": "hourglass.bottomhalf.filled"},
            "approved": {"color": "#3B82F6", "icon": "checkmark.seal.fill"},
            "planned": {"color": "#EC4899", "icon": "calendar"},
            "in_progress": {"color": "#06B6D4", "icon": "clock.fill"},
            "completed": {"color": "#22C55E", "icon": "checkmark.circle.fill"},
            "rejected": {"color": "#EF4444", "icon": "xmark.circle.fill"},
        },
    }


def sorted_feature_requests(query):
    params = parse_qs(query)
    sort = first_query_value(params, "sort", "order", "sort_by")
    requests = list(REQUESTS)

    if sort in ("top", "votes", "vote_count", "popular"):
        return sorted(requests, key=lambda request: request["vote_count"], reverse=True)

    if sort in ("newest", "created_at", "created"):
        return sorted(requests, key=lambda request: request["created_at"], reverse=True)

    return requests


def first_query_value(params, *names):
    for name in names:
        values = params.get(name)
        if values:
            return values[0].lower()
    return None


def now_iso8601():
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        if url.path == "/api/sdk/feature-requests":
            self.respond(feature_requests_payload(sorted_feature_requests(url.query)))
        elif url.path == "/api/mock/settings":
            self.respond({"success": True, **SETTINGS})
        else:
            self.respond({"success": False, "message": f"No mock for GET {url.path}"}, status=404)

    def do_POST(self):
        path = urlparse(self.path).path
        body = self.read_json_body()

        if path == "/api/mock/settings":
            if "show_status" in body:
                SETTINGS["show_status"] = bool(body["show_status"])
            if "show_translation" in body:
                SETTINGS["show_translation"] = bool(body["show_translation"])
            self.respond({"success": True, **SETTINGS})
        elif path == "/api/sdk/feature-requests":
            REQUESTS.insert(
                0,
                {
                    "id": f"mock-request-{len(REQUESTS) + 1}",
                    "title": body.get("title") or "Submitted from demo",
                    "description": body.get("description") or "This request was created in the mocked demo.",
                    "status": "pending",
                    "vote_count": 1,
                    "has_voted": True,
                    "is_owner": True,
                    "created_at": now_iso8601(),
                },
            )
            self.respond({"success": True, "message": "created"})
        elif path in ("/api/sdk/activity", "/api/sdk/user"):
            self.respond({"success": True, "message": "ok"})
        elif path.startswith("/api/sdk/feature-requests/") and path.endswith("/vote"):
            self.update_vote(path, True)
            self.respond({"success": True, "message": "voted"})
        else:
            self.respond({"success": False, "message": f"No mock for POST {path}"}, status=404)

    def do_DELETE(self):
        path = urlparse(self.path).path
        if path.startswith("/api/sdk/feature-requests/") and path.endswith("/vote"):
            self.update_vote(path, False)
            self.respond({"success": True, "message": "unvoted"})
        else:
            self.respond({"success": False, "message": f"No mock for DELETE {path}"}, status=404)

    def read_json_body(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length == 0:
            return {}
        try:
            return json.loads(self.rfile.read(length))
        except json.JSONDecodeError:
            return {}

    def update_vote(self, path, has_voted):
        request_id = path.replace("/api/sdk/feature-requests/", "").replace("/vote", "")
        for request in REQUESTS:
            if request["id"] == request_id:
                if request["has_voted"] != has_voted:
                    request["vote_count"] = max(0, request["vote_count"] + (1 if has_voted else -1))
                    request["has_voted"] = has_voted
                return

    def respond(self, payload, status=200):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        sys.stdout.write("%s - %s\n" % (self.address_string(), format % args))


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    server = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"FeaturePulse demo mock server running at http://127.0.0.1:{port}", flush=True)
    server.serve_forever()

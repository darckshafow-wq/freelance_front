#!/usr/bin/env python3
import argparse
import os
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse


class CORSProxyHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, backend_url=None, **kwargs):
        self.backend_url = backend_url
        super().__init__(*args, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header(
            "Access-Control-Allow-Methods",
            "GET, POST, PUT, PATCH, DELETE, OPTIONS",
        )
        self.send_header(
            "Access-Control-Allow-Headers",
            "Content-Type, Authorization, X-Requested-With",
        )
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_GET(self):
        self._dispatch_request()

    def do_POST(self):
        self._dispatch_request()

    def do_PUT(self):
        self._dispatch_request()

    def do_PATCH(self):
        self._dispatch_request()

    def do_DELETE(self):
        self._dispatch_request()

    def _dispatch_request(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith("/api/") or parsed.path.startswith("/ws/"):
            self._proxy_request()
            return
        super().do_GET()

    def _proxy_request(self):
        target_url = self.backend_url + self.path
        body = None
        headers = {}
        content_length = int(self.headers.get("Content-Length", "0"))
        if content_length > 0:
            body = self.rfile.read(content_length)

        for key, value in self.headers.items():
            if key.lower() in {"host", "origin", "content-length", "connection"}:
                continue
            headers[key] = value

        request = urllib.request.Request(target_url, data=body, headers=headers, method=self.command)
        try:
            with urllib.request.urlopen(request, timeout=10) as response:
                status = response.getcode()
                response_body = response.read()
                self.send_response(status)
                self.send_header("Content-Type", response.headers.get("Content-Type", "application/json"))
                self.send_header("Content-Length", str(len(response_body)))
                self.end_headers()
                self.wfile.write(response_body)
        except Exception as exc:
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            body_bytes = str(exc).encode("utf-8")
            self.send_header("Content-Length", str(len(body_bytes)))
            self.end_headers()
            self.wfile.write(body_bytes)


def main():
    parser = argparse.ArgumentParser(description="Serve Flutter web assets and proxy API requests with CORS")
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--directory", default=".")
    parser.add_argument("--backend-url", default=os.environ.get("BACKEND_TARGET_URL", "http://127.0.0.1:8000"))
    args = parser.parse_args()

    os.chdir(args.directory)
    server = ThreadingHTTPServer((args.host, args.port), lambda *a, **kw: CORSProxyHandler(*a, backend_url=args.backend_url, directory=args.directory, **kw))
    print(f"Serving {args.directory} on http://{args.host}:{args.port} with backend {args.backend_url}")
    server.serve_forever()


if __name__ == "__main__":
    main()

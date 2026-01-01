#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx

cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Service Status</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <meta name="description" content="Service status page served via Application Load Balancer" />
  <meta name="robots" content="noindex, nofollow" />

  <style>
    :root {
      --bg: #f8fafc;
      --text: #0f172a;
      --muted: #64748b;
      --border: #e2e8f0;
      --ok: #16a34a;
    }

    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI",
                   Roboto, Helvetica, Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
    }

    .container {
      max-width: 820px;
      margin: 60px auto;
      padding: 0 20px;
    }

    header {
      margin-bottom: 32px;
    }

    h1 {
      font-size: 1.75rem;
      margin: 0 0 8px 0;
      font-weight: 600;
    }

    .subtitle {
      color: var(--muted);
      font-size: 0.95rem;
    }

    .card {
      background: #ffffff;
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 24px;
      margin-bottom: 24px;
    }

    .row {
      display: flex;
      justify-content: space-between;
      padding: 10px 0;
      border-bottom: 1px solid var(--border);
      font-size: 0.95rem;
    }

    .row:last-child {
      border-bottom: none;
    }

    .label {
      color: var(--muted);
    }

    .value {
      font-weight: 500;
    }

    .status {
      color: var(--ok);
      font-weight: 600;
    }

    footer {
      margin-top: 40px;
      font-size: 0.8rem;
      color: var(--muted);
    }
  </style>
</head>

<body>
  <div class="container">

    <header>
      <h1>Application Service Status</h1>
      <div class="subtitle">
        Production traffic routed through Application Load Balancer
      </div>
    </header>

    <section class="card">
      <div class="row">
        <div class="label">Service Health</div>
        <div class="value status">Operational</div>
      </div>

      <div class="row">
        <div class="label">Request Served By</div>
        <div class="value" id="hostname">Resolving…</div>
      </div>

      <div class="row">
        <div class="label">Protocol</div>
        <div class="value" id="protocol"></div>
      </div>

      <div class="row">
        <div class="label">Request Timestamp</div>
        <div class="value" id="timestamp"></div>
      </div>
    </section>

    <section class="card">
      <div class="row">
        <div class="label">Architecture</div>
        <div class="value">ALB → Auto Scaling Group → EC2</div>
      </div>

      <div class="row">
        <div class="label">Security</div>
        <div class="value">AWS WAF enabled</div>
      </div>

      <div class="row">
        <div class="label">Health Check Path</div>
        <div class="value">/</div>
      </div>
    </section>

    <footer>
      <p>
        This endpoint is intended for infrastructure validation and internal
        monitoring only.
      </p>
    </footer>

  </div>

  <script>
    document.getElementById("hostname").textContent =
      window.location.hostname;

    document.getElementById("protocol").textContent =
      window.location.protocol.replace(":", "").toUpperCase();

    document.getElementById("timestamp").textContent =
      new Date().toISOString();
  </script>
</body>
</html>
EOF


chown -R www-data:www-data /var/www/html
chmod 644 /var/www/html/index.html

systemctl enable nginx
systemctl restart nginx

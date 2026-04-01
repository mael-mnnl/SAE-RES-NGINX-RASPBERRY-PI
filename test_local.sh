#!/bin/bash
# ============================================================
#  Test local TEK-IT-IZY avec Docker
#
#  Usage :
#    ./test_local.sh          → démarre l'environnement
#    ./test_local.sh --stop   → arrête et nettoie
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RASPI_NUM="215"
RASPI_IP="10.192.51.215"
HTTP_PORT="8080"
INTRANET_PORT="2025"
ENV_DIR="${SCRIPT_DIR}/test-env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

# Compatibilité docker compose / docker-compose
dc() {
    if docker compose version &>/dev/null 2>&1; then
        docker compose -f "${SCRIPT_DIR}/docker-compose.yml" "$@"
    else
        docker-compose -f "${SCRIPT_DIR}/docker-compose.yml" "$@"
    fi
}

# ─────────────────────────────────────────────
# Option --stop : arrêt et nettoyage
# ─────────────────────────────────────────────
if [ "${1}" = "--stop" ]; then
    echo -e "${YELLOW}[↓] Arrêt des conteneurs...${NC}"
    dc down
    echo -e "${YELLOW}[↓] Suppression des entrées /etc/hosts...${NC}"
    sudo sed -i \
        '/# TEK-IT-IZY test local/d;/raspb'"${RASPI_NUM}"'\.univ-lr\.fr/d;/www\.tek-it-izy\.org/d;/intranet\.tek-it-izy\.org/d' \
        /etc/hosts
    echo -e "${GREEN}Environnement arrêté et nettoyé.${NC}"
    exit 0
fi

# ─────────────────────────────────────────────
# Vérifications préalables
# ─────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
    echo -e "${RED}Erreur : Docker n'est pas installé.${NC}"
    echo "Installez Docker : https://docs.docker.com/engine/install/"
    exit 1
fi

echo "========================================="
echo "  Test local TEK-IT-IZY (Docker)"
echo "========================================="

# ─────────────────────────────────────────────
# 1. Arborescence
# ─────────────────────────────────────────────
echo "[1/5] Création de l'arborescence..."
mkdir -p "${ENV_DIR}/www/public"
mkdir -p "${ENV_DIR}/www/log/acces"
mkdir -p "${ENV_DIR}/www/log/erreur"
mkdir -p "${ENV_DIR}/www/pageserreurs"
mkdir -p "${ENV_DIR}/www/intranet/pageserreurs"
mkdir -p "${ENV_DIR}/www/intranetlog/acces"
mkdir -p "${ENV_DIR}/www/intranetlog/erreur"
mkdir -p "${ENV_DIR}/var-www-html"
mkdir -p "${ENV_DIR}/nginx/conf.d"
mkdir -p "${ENV_DIR}/nginx/auth"

# ─────────────────────────────────────────────
# 2. Pages HTML + Favicons
# ─────────────────────────────────────────────
echo "[2/5] Création des pages HTML et favicons..."

# ══════════════════════════════════════════════
#  SITE PAR DÉFAUT — raspb215.univ-lr.fr
# ══════════════════════════════════════════════

cat > "${ENV_DIR}/var-www-html/favicon.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#003087"/><stop offset="1" stop-color="#0055b3"/>
    </linearGradient>
  </defs>
  <rect width="32" height="32" rx="8" fill="url(#g)"/>
  <text x="16" y="22" font-size="16" text-anchor="middle" fill="white" font-family="system-ui,sans-serif" font-weight="800">R</text>
</svg>
EOF

# Heredoc sans quotes : ${RASPI_NUM} et ${RASPI_IP} sont substitués
cat > "${ENV_DIR}/var-www-html/index.html" <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>raspb${RASPI_NUM} · Université de La Rochelle</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#f0f4fb;color:#1a1a2e;min-height:100vh;display:flex;flex-direction:column}
    nav{background:#003087;color:white;display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:56px;box-shadow:0 2px 10px rgba(0,0,0,.3)}
    nav .brand{font-weight:700;font-size:1.05rem;letter-spacing:.02em}
    nav .brand em{color:#ffd100;font-style:normal}
    nav a{color:rgba(255,255,255,.75);text-decoration:none;font-size:.85rem;transition:color .2s}
    nav a:hover{color:#ffd100}
    .hero{background:linear-gradient(135deg,#003087 0%,#0055b3 100%);color:white;padding:3.5rem 2rem 5rem;text-align:center;position:relative;overflow:hidden}
    .hero::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse at 70% 0%,rgba(255,209,0,.12) 0%,transparent 60%)}
    .hero::after{content:'';position:absolute;bottom:-1px;left:0;right:0;height:55px;background:#f0f4fb;clip-path:ellipse(65% 100% at 50% 100%)}
    .badge{display:inline-flex;align-items:center;gap:.4rem;background:rgba(255,209,0,.15);border:1px solid rgba(255,209,0,.4);color:#ffd100;border-radius:20px;padding:.25rem .8rem;font-size:.78rem;margin-bottom:1.2rem;position:relative}
    .dot{display:inline-block;width:7px;height:7px;border-radius:50%;background:#22c55e;box-shadow:0 0 5px #22c55e;animation:pulse 2s infinite}
    @keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}
    .hero h1{font-size:clamp(1.8rem,5vw,2.8rem);font-weight:800;letter-spacing:-.02em;margin-bottom:.4rem;position:relative}
    .hero h1 em{color:#ffd100;font-style:normal}
    .hero p{color:rgba(255,255,255,.65);font-size:.95rem;position:relative}
    main{max-width:860px;margin:0 auto;padding:2.5rem 1.5rem;width:100%;flex:1}
    .section-title{display:flex;align-items:center;gap:.6rem;font-size:.8rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7c99;margin-bottom:1rem}
    .section-title::after{content:'';flex:1;height:1px;background:#dde6f5}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1rem;margin-bottom:2.5rem}
    .card{background:white;border-radius:12px;padding:1.4rem;box-shadow:0 2px 10px rgba(0,48,135,.07);border:1px solid #e4ecf7;transition:transform .18s,box-shadow .18s;text-decoration:none;color:inherit;display:block}
    .card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,48,135,.12);border-color:#b8ccee}
    .card-row{display:flex;align-items:center;gap:.7rem;margin-bottom:.6rem}
    .ico{width:38px;height:38px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0}
    .ico-blue{background:#e8f0fe} .ico-gold{background:#fff8e1} .ico-green{background:#e6f4ea}
    .card h3{font-size:.95rem;font-weight:600}
    .card p{font-size:.82rem;color:#6b7c99;line-height:1.5;margin-bottom:.4rem}
    code{background:#f0f4fb;color:#003087;padding:.15rem .45rem;border-radius:5px;font-size:.8rem;font-family:'SF Mono',Consolas,monospace}
    table{width:100%;background:white;border-radius:12px;overflow:hidden;box-shadow:0 2px 10px rgba(0,48,135,.07);border:1px solid #e4ecf7;border-collapse:collapse}
    tr:not(:last-child){border-bottom:1px solid #f0f4fb}
    td{padding:.8rem 1.1rem;font-size:.85rem}
    td:first-child{font-weight:600;color:#6b7c99;width:42%}
    td:last-child{color:#1a1a2e;font-family:'SF Mono',Consolas,monospace;font-size:.82rem}
    footer{text-align:center;padding:1.5rem;color:#a0aec0;font-size:.8rem;border-top:1px solid #e4ecf7;margin-top:auto}
  </style>
</head>
<body>
  <nav>
    <div class="brand">raspb<em>${RASPI_NUM}</em>.univ-lr.fr</div>
    <a href="https://www.univ-larochelle.fr" target="_blank" rel="noopener">Université de La Rochelle ↗</a>
  </nav>
  <div class="hero">
    <div class="badge"><span class="dot"></span> Serveur actif</div>
    <h1>Raspberry Pi <em>${RASPI_NUM}</em></h1>
    <p>SAE 2.04 — Administration Système &amp; Réseaux</p>
  </div>
  <main>
    <p class="section-title">Sites hébergés</p>
    <div class="grid">
      <a class="card" href="http://www.tek-it-izy.org:8080">
        <div class="card-row"><div class="ico ico-blue">🌐</div><h3>Site public</h3></div>
        <p>Ouvert à tous, port standard</p>
        <code>www.tek-it-izy.org</code>
      </a>
      <a class="card" href="http://intranet.tek-it-izy.org:2025">
        <div class="card-row"><div class="ico ico-gold">🔒</div><h3>Intranet</h3></div>
        <p>Accès restreint par mot de passe</p>
        <code>intranet.tek-it-izy.org:2025</code>
      </a>
      <div class="card">
        <div class="card-row"><div class="ico ico-green">👤</div><h3>Pages personnelles</h3></div>
        <p>Répertoire public de chaque utilisateur Linux</p>
        <code>/~login/</code>
      </div>
    </div>
    <p class="section-title">Informations serveur</p>
    <table>
      <tr><td>Hôte</td><td>raspb${RASPI_NUM}.univ-lr.fr</td></tr>
      <tr><td>Adresse IP</td><td>${RASPI_IP}</td></tr>
      <tr><td>Serveur web</td><td>nginx + PHP-FPM 8.1</td></tr>
      <tr><td>Pages perso</td><td>~/public_html/</td></tr>
      <tr><td>OS</td><td>Ubuntu Server 25.10 (Raspberry Pi)</td></tr>
    </table>
  </main>
  <footer>SAE 2.04 · IUT La Rochelle · 2024–2025</footer>
</body>
</html>
EOF

# ══════════════════════════════════════════════
#  SITE PUBLIC — www.tek-it-izy.org
# ══════════════════════════════════════════════

cat > "${ENV_DIR}/www/public/favicon.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#16213e"/><stop offset="1" stop-color="#0f3460"/>
    </linearGradient>
  </defs>
  <rect width="32" height="32" rx="8" fill="url(#g)"/>
  <text x="16" y="22" font-size="16" text-anchor="middle" fill="#3fb950" font-family="system-ui,sans-serif" font-weight="800">T</text>
</svg>
EOF

cat > "${ENV_DIR}/www/public/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>TEK-IT-IZY — Solutions Tech</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0d1117;--surface:#161b22;--border:#21262d;--green:#3fb950;--blue:#58a6ff;--text:#e6edf3;--muted:#8b949e}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;flex-direction:column}
    nav{background:rgba(13,17,23,.9);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);position:sticky;top:0;z-index:10;display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:60px}
    .logo{font-weight:800;font-size:1.1rem;letter-spacing:-.01em;background:linear-gradient(90deg,var(--green),var(--blue));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
    nav ul{list-style:none;display:flex;gap:1.5rem}
    nav a{color:var(--muted);text-decoration:none;font-size:.875rem;transition:color .2s}
    nav a:hover{color:var(--text)}
    .hero{padding:6rem 2rem 5rem;text-align:center;position:relative;overflow:hidden;background:radial-gradient(ellipse 80% 60% at 50% -10%,rgba(63,185,80,.12) 0%,transparent 70%)}
    .hero-tag{display:inline-flex;align-items:center;gap:.4rem;background:rgba(63,185,80,.08);border:1px solid rgba(63,185,80,.25);border-radius:20px;padding:.3rem .9rem;font-size:.78rem;color:var(--green);margin-bottom:1.5rem}
    .pulse{display:inline-block;width:6px;height:6px;border-radius:50%;background:var(--green);animation:p 2s infinite}
    @keyframes p{0%,100%{opacity:1;box-shadow:0 0 0 0 rgba(63,185,80,.4)}50%{opacity:.7;box-shadow:0 0 0 4px rgba(63,185,80,0)}}
    h1{font-size:clamp(2.8rem,8vw,5.5rem);font-weight:900;letter-spacing:-.04em;line-height:1;margin-bottom:1.2rem}
    h1 .grad{background:linear-gradient(135deg,var(--green) 0%,var(--blue) 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
    .hero p{font-size:1.15rem;color:var(--muted);max-width:500px;margin:0 auto 2.5rem;line-height:1.6}
    .cta{display:flex;gap:1rem;justify-content:center;flex-wrap:wrap}
    .btn{padding:.75rem 1.8rem;border-radius:8px;font-size:.95rem;font-weight:600;text-decoration:none;transition:all .2s;display:inline-block}
    .btn-g{background:var(--green);color:#0d1117}.btn-g:hover{background:#56d364;transform:translateY(-1px)}
    .btn-o{background:transparent;color:var(--text);border:1px solid var(--border)}.btn-o:hover{background:var(--surface)}
    .features{padding:5rem 2rem;max-width:1080px;margin:0 auto;width:100%}
    .features-head{text-align:center;margin-bottom:3rem}
    .features-head h2{font-size:2rem;font-weight:700;margin-bottom:.5rem}
    .features-head p{color:var(--muted)}
    .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:1.2rem}
    .card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:1.8rem;transition:border-color .2s,transform .2s}
    .card:hover{border-color:var(--green);transform:translateY(-3px)}
    .card-ico{font-size:2rem;margin-bottom:1rem}
    .card h3{font-size:1.05rem;font-weight:600;margin-bottom:.5rem}
    .card p{color:var(--muted);font-size:.875rem;line-height:1.6}
    .stats{background:var(--surface);border-top:1px solid var(--border);border-bottom:1px solid var(--border);padding:3rem 2rem;display:flex;justify-content:center;gap:4rem;flex-wrap:wrap;text-align:center}
    .stat-val{font-size:2.2rem;font-weight:800;color:var(--green)}
    .stat-label{font-size:.8rem;color:var(--muted);margin-top:.2rem}
    footer{margin-top:auto;padding:2rem;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem;font-size:.82rem;color:var(--muted)}
    footer .logo-f{font-weight:700;color:var(--text)}
  </style>
</head>
<body>
  <nav>
    <span class="logo">TEK-IT-IZY</span>
    <ul>
      <li><a href="/accueil.html">À propos</a></li>
      <li><a href="#services">Services</a></li>
      <li><a href="http://intranet.tek-it-izy.org:2025">Intranet →</a></li>
    </ul>
  </nav>
  <section class="hero">
    <div class="hero-tag"><span class="pulse"></span> Disponible 24/7</div>
    <h1><span class="grad">TEK-IT-IZY</span></h1>
    <p>Solutions technologiques innovantes pour votre transformation numérique.</p>
    <div class="cta">
      <a href="/accueil.html" class="btn btn-g">Découvrir →</a>
      <a href="#services" class="btn btn-o">Nos services</a>
    </div>
  </section>
  <div class="stats">
    <div><div class="stat-val">3</div><div class="stat-label">Sites hébergés</div></div>
    <div><div class="stat-val">99.9%</div><div class="stat-label">Disponibilité</div></div>
    <div><div class="stat-val">PHP 8.1</div><div class="stat-label">Stack moderne</div></div>
  </div>
  <section class="features" id="services">
    <div class="features-head">
      <h2>Ce que nous proposons</h2>
      <p>Des solutions adaptées à chaque besoin</p>
    </div>
    <div class="cards">
      <div class="card"><div class="card-ico">🌐</div><h3>Développement Web</h3><p>Applications web modernes, performantes et sécurisées, conçues sur-mesure pour vos besoins.</p></div>
      <div class="card"><div class="card-ico">☁️</div><h3>Infrastructure Cloud</h3><p>Hébergement scalable, haute disponibilité et monitoring en temps réel de vos services.</p></div>
      <div class="card"><div class="card-ico">🔒</div><h3>Cybersécurité</h3><p>Audit, protection et surveillance proactive de vos systèmes contre les menaces.</p></div>
    </div>
  </section>
  <footer><span class="logo-f">TEK-IT-IZY</span><span>© 2025 — Tous droits réservés</span></footer>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/public/accueil.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>À propos — TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0d1117;--surface:#161b22;--border:#21262d;--green:#3fb950;--blue:#58a6ff;--text:#e6edf3;--muted:#8b949e}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;flex-direction:column}
    nav{background:rgba(13,17,23,.9);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:60px;position:sticky;top:0;z-index:10}
    .logo{font-weight:800;font-size:1.1rem;background:linear-gradient(90deg,var(--green),var(--blue));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;text-decoration:none}
    nav a{color:var(--muted);text-decoration:none;font-size:.875rem;transition:color .2s}
    nav a:hover{color:var(--text)}
    .page-header{padding:4rem 2rem;text-align:center;border-bottom:1px solid var(--border)}
    .page-header h1{font-size:2.5rem;font-weight:800;letter-spacing:-.03em;margin-bottom:.6rem}
    .page-header p{color:var(--muted);font-size:1.05rem;max-width:480px;margin:0 auto}
    main{max-width:900px;margin:0 auto;padding:3rem 2rem;width:100%;flex:1}
    .about-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:2rem;margin-bottom:3rem}
    h2{font-size:1.3rem;font-weight:700;margin-bottom:.8rem;color:var(--green)}
    p{color:var(--muted);line-height:1.7;font-size:.9rem}
    .team,.values{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:2rem}
    .member{display:flex;align-items:center;gap:1rem;padding:.8rem 0;border-bottom:1px solid var(--border)}
    .member:last-child{border-bottom:none}
    .avatar{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,var(--green),var(--blue));display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0}
    .member-info strong{display:block;font-size:.9rem;color:var(--text)}
    .member-info span{font-size:.8rem;color:var(--muted)}
    .value-item{display:flex;gap:.8rem;margin-bottom:1.2rem}
    .value-item:last-child{margin-bottom:0}
    .value-icon{font-size:1.3rem;flex-shrink:0;margin-top:.1rem}
    .value-item strong{display:block;font-size:.9rem;color:var(--text);margin-bottom:.2rem}
    footer{margin-top:auto;padding:2rem;border-top:1px solid var(--border);text-align:center;font-size:.82rem;color:var(--muted)}
    footer a{color:var(--green);text-decoration:none}
  </style>
</head>
<body>
  <nav><a href="/" class="logo">TEK-IT-IZY</a><a href="/">← Retour à l'accueil</a></nav>
  <div class="page-header">
    <h1>À propos de nous</h1>
    <p>Une équipe passionnée au service de vos projets technologiques.</p>
  </div>
  <main>
    <div class="about-grid">
      <div class="values">
        <h2>Nos valeurs</h2>
        <div class="value-item"><div class="value-icon">⚡</div><div><strong>Performance</strong><p>Chaque solution est optimisée pour offrir la meilleure expérience possible.</p></div></div>
        <div class="value-item"><div class="value-icon">🔐</div><div><strong>Sécurité</strong><p>La protection de vos données est au cœur de chacune de nos décisions.</p></div></div>
        <div class="value-item"><div class="value-icon">🤝</div><div><strong>Fiabilité</strong><p>Des engagements tenus, une infrastructure disponible en permanence.</p></div></div>
      </div>
      <div class="team">
        <h2>L'équipe</h2>
        <div class="member"><div class="avatar">👩‍💻</div><div class="member-info"><strong>Équipe Dev</strong><span>Développement &amp; intégration web</span></div></div>
        <div class="member"><div class="avatar">🛠️</div><div class="member-info"><strong>Équipe Infra</strong><span>Systèmes, réseaux &amp; déploiement</span></div></div>
        <div class="member"><div class="avatar">🔒</div><div class="member-info"><strong>Équipe Sécu</strong><span>Cybersécurité &amp; conformité</span></div></div>
      </div>
    </div>
  </main>
  <footer><a href="/">TEK-IT-IZY</a> — © 2025 Tous droits réservés</footer>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/pageserreurs/404.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>404 — TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0d1117;color:#e6edf3;min-height:100vh;display:flex;align-items:center;justify-content:center;flex-direction:column;text-align:center;padding:2rem;gap:1rem}
    .code{font-size:clamp(6rem,20vw,10rem);font-weight:900;line-height:1;background:linear-gradient(135deg,#3fb950,#58a6ff);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;letter-spacing:-.05em}
    h1{font-size:1.4rem;font-weight:600}
    p{color:#8b949e;font-size:.9rem;max-width:360px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#238636;color:white;padding:.65rem 1.6rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.9rem;transition:background .2s}
    a:hover{background:#2ea043}
  </style>
</head>
<body>
  <div class="code">404</div>
  <h1>Page introuvable</h1>
  <p>La ressource demandée n'existe pas sur ce serveur.</p>
  <a href="/">← Retour à l'accueil</a>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/pageserreurs/403.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>403 — TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0d1117;color:#e6edf3;min-height:100vh;display:flex;align-items:center;justify-content:center;flex-direction:column;text-align:center;padding:2rem;gap:1rem}
    .code{font-size:clamp(6rem,20vw,10rem);font-weight:900;line-height:1;background:linear-gradient(135deg,#f78166,#ff7b72);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;letter-spacing:-.05em}
    h1{font-size:1.4rem;font-weight:600}
    p{color:#8b949e;font-size:.9rem;max-width:360px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#238636;color:white;padding:.65rem 1.6rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.9rem;transition:background .2s}
    a:hover{background:#2ea043}
  </style>
</head>
<body>
  <div class="code">403</div>
  <h1>Accès refusé</h1>
  <p>Vous n'avez pas les droits nécessaires pour accéder à cette ressource.</p>
  <a href="/">← Retour à l'accueil</a>
</body>
</html>
EOF

# ══════════════════════════════════════════════
#  SITE INTRANET — intranet.tek-it-izy.org
# ══════════════════════════════════════════════

cat > "${ENV_DIR}/www/intranet/favicon.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#1a0505"/><stop offset="1" stop-color="#2c0a0a"/>
    </linearGradient>
  </defs>
  <rect width="32" height="32" rx="8" fill="url(#g)"/>
  <text x="16" y="22" font-size="16" text-anchor="middle" fill="#e74c3c" font-family="system-ui,sans-serif" font-weight="800">I</text>
</svg>
EOF

cat > "${ENV_DIR}/www/intranet/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Intranet — TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0a0a0a;--surface:#111;--surface2:#181818;--border:#2a2a2a;--red:#e74c3c;--red-dim:#c0392b;--text:#e0e0e0;--muted:#707070}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;flex-direction:column}
    nav{background:var(--surface);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:58px}
    .logo{display:flex;align-items:center;gap:.6rem;font-weight:700;font-size:1rem}
    .logo-dot{width:8px;height:8px;border-radius:50%;background:var(--red);box-shadow:0 0 6px var(--red);animation:blink 3s infinite}
    @keyframes blink{0%,90%,100%{opacity:1}95%{opacity:.3}}
    .badge-restricted{background:rgba(231,76,60,.1);border:1px solid rgba(231,76,60,.3);color:var(--red);border-radius:6px;padding:.2rem .65rem;font-size:.72rem;font-weight:600;letter-spacing:.05em;text-transform:uppercase}
    .hero{padding:4rem 2rem;text-align:center;background:radial-gradient(ellipse 70% 50% at 50% 0%,rgba(231,76,60,.08) 0%,transparent 70%);border-bottom:1px solid var(--border)}
    .shield{font-size:3.5rem;margin-bottom:1rem;display:block;filter:drop-shadow(0 0 12px rgba(231,76,60,.4))}
    h1{font-size:clamp(1.6rem,4vw,2.5rem);font-weight:800;letter-spacing:-.02em;margin-bottom:.4rem}
    h1 span{color:var(--red)}
    .hero p{color:var(--muted);font-size:.9rem}
    main{max-width:860px;margin:0 auto;padding:2.5rem 1.5rem;width:100%;flex:1;display:flex;flex-direction:column;gap:1.5rem}
    .section-title{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.1em;color:var(--muted);display:flex;align-items:center;gap:.5rem}
    .section-title::after{content:'';flex:1;height:1px;background:var(--border)}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:1rem}
    .card{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:1.4rem;text-decoration:none;color:var(--text);transition:border-color .2s,transform .15s;display:block}
    .card:hover{border-color:var(--red);transform:translateY(-2px)}
    .card-ico{font-size:1.5rem;margin-bottom:.7rem}
    .card h3{font-size:.92rem;font-weight:600;margin-bottom:.35rem}
    .card p{font-size:.8rem;color:var(--muted);line-height:1.5}
    .info-bar{background:var(--surface);border:1px solid var(--border);border-left:3px solid var(--red);border-radius:8px;padding:1rem 1.2rem;display:flex;align-items:center;gap:.8rem;font-size:.82rem;color:var(--muted)}
    .info-bar strong{color:var(--text)}
    footer{margin-top:auto;padding:1.5rem;border-top:1px solid var(--border);text-align:center;font-size:.78rem;color:var(--muted)}
  </style>
</head>
<body>
  <nav>
    <div class="logo"><span class="logo-dot"></span> TEK-IT-IZY — Intranet</div>
    <span class="badge-restricted">🔒 Accès restreint</span>
  </nav>
  <div class="hero">
    <span class="shield">🛡️</span>
    <h1>Espace <span>Intranet</span></h1>
    <p>Plateforme collaborative réservée aux membres de l'organisation.</p>
  </div>
  <main>
    <p class="section-title">Accès rapide</p>
    <div class="grid">
      <a href="/intranet.html" class="card"><div class="card-ico">📋</div><h3>Page Intranet</h3><p>Tableau de bord et ressources internes de l'organisation.</p></a>
      <div class="card">
        <div class="card-ico">👤</div>
        <h3>Pages personnelles</h3>
        <p>Accéder à l'espace d'un collaborateur</p>
        <form style="display:flex;gap:.4rem;margin-top:.8rem" onsubmit="event.preventDefault();var u=this.u.value.trim();if(u)location.href='/~'+u+'/'">
          <input name="u" placeholder="login" style="flex:1;background:#1a1a1a;border:1px solid #333;color:#e0e0e0;border-radius:6px;padding:.4rem .7rem;font-size:.82rem;outline:none">
          <button type="submit" style="background:#c0392b;color:white;border:none;border-radius:6px;padding:.4rem .9rem;cursor:pointer;font-size:.9rem" onmouseover="this.style.background='#e74c3c'" onmouseout="this.style.background='#c0392b'">→</button>
        </form>
      </div>
      <div class="card"><div class="card-ico">📁</div><h3>Répertoire</h3><p>Parcourir les ressources disponibles sur ce serveur intranet.</p></div>
    </div>
    <div class="info-bar">ℹ️ <span>Connexion chiffrée · Port <strong>2025</strong> · Authentification requise pour toutes les pages</span></div>
  </main>
  <footer>TEK-IT-IZY Intranet · Usage interne uniquement · © 2025</footer>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/intranet/intranet.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Tableau de bord — Intranet TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0a0a0a;--surface:#111;--border:#2a2a2a;--red:#e74c3c;--text:#e0e0e0;--muted:#707070;--green:#2ecc71}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex;flex-direction:column}
    nav{background:var(--surface);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:58px}
    .logo{font-weight:700;font-size:1rem;display:flex;align-items:center;gap:.5rem}
    .dot-r{width:7px;height:7px;border-radius:50%;background:var(--red);box-shadow:0 0 5px var(--red)}
    nav a{color:var(--muted);text-decoration:none;font-size:.85rem;transition:color .2s}
    nav a:hover{color:var(--text)}
    .page-title{padding:2rem;border-bottom:1px solid var(--border)}
    .page-title h1{font-size:1.5rem;font-weight:700;margin-bottom:.2rem}
    .page-title p{color:var(--muted);font-size:.85rem}
    main{max-width:980px;margin:0 auto;padding:2rem 1.5rem;width:100%;flex:1;display:grid;grid-template-columns:1fr 1fr;gap:1.5rem}
    @media(max-width:640px){main{grid-template-columns:1fr}}
    .widget{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:1.4rem}
    .widget-header{display:flex;align-items:center;gap:.5rem;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:1.1rem;padding-bottom:.8rem;border-bottom:1px solid var(--border)}
    .stat-row{display:flex;align-items:baseline;gap:.5rem;margin-bottom:.8rem}
    .stat-val{font-size:1.8rem;font-weight:800;color:var(--red)}
    .stat-sub{font-size:.8rem;color:var(--muted)}
    .status-row{display:flex;align-items:center;justify-content:space-between;padding:.55rem 0;border-bottom:1px solid var(--border);font-size:.82rem}
    .status-row:last-child{border-bottom:none}
    .status-on{color:var(--green);font-weight:600;font-size:.75rem}
    .list-item{display:flex;align-items:center;gap:.7rem;padding:.6rem 0;border-bottom:1px solid var(--border);font-size:.85rem}
    .list-item:last-child{border-bottom:none}
    .list-item span{color:var(--muted);font-size:.78rem;margin-left:auto}
    footer{padding:1.5rem;border-top:1px solid var(--border);text-align:center;font-size:.78rem;color:var(--muted);margin-top:auto}
  </style>
</head>
<body>
  <nav>
    <div class="logo"><span class="dot-r"></span> TEK-IT-IZY — Intranet</div>
    <a href="/index.html">← Accueil</a>
  </nav>
  <div class="page-title"><h1>Tableau de bord</h1><p>Vue d'ensemble des ressources et services internes.</p></div>
  <main>
    <div class="widget">
      <div class="widget-header">📊 Ressources</div>
      <div class="stat-row"><span class="stat-val">3</span><span class="stat-sub">Sites actifs</span></div>
      <div class="stat-row"><span class="stat-val">2025</span><span class="stat-sub">Port intranet</span></div>
      <div class="stat-row"><span class="stat-val">PHP 8.1</span><span class="stat-sub">Moteur dynamique</span></div>
    </div>
    <div class="widget">
      <div class="widget-header">🔧 Services</div>
      <div class="status-row"><span>nginx</span><span class="status-on">● Actif</span></div>
      <div class="status-row"><span>PHP-FPM</span><span class="status-on">● Actif</span></div>
      <div class="status-row"><span>Auth HTTP</span><span class="status-on">● Activée</span></div>
      <div class="status-row"><span>Logs accès</span><span class="status-on">● Activés</span></div>
    </div>
    <div class="widget" style="grid-column:span 2">
      <div class="widget-header">🔗 Liens rapides</div>
      <div class="list-item">🌐 Site public TEK-IT-IZY<span>www.tek-it-izy.org</span></div>
      <div class="list-item">🖥️ Serveur Raspberry Pi<span>raspb215.univ-lr.fr</span></div>
      <div class="list-item">👤 Pages personnelles<span>/~login/pages_personnelles/</span></div>
    </div>
  </main>
  <footer>TEK-IT-IZY Intranet · Usage interne uniquement · © 2025</footer>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/intranet/pageserreurs/404.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>404 — Intranet TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0a0a0a;color:#e0e0e0;min-height:100vh;display:flex;align-items:center;justify-content:center;flex-direction:column;text-align:center;padding:2rem;gap:1rem}
    .code{font-size:clamp(6rem,20vw,10rem);font-weight:900;line-height:1;color:#e74c3c;letter-spacing:-.05em;text-shadow:0 0 40px rgba(231,76,60,.3)}
    h1{font-size:1.4rem;font-weight:600}p{color:#707070;font-size:.9rem;max-width:360px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#c0392b;color:white;padding:.65rem 1.6rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.9rem;transition:background .2s}
    a:hover{background:#e74c3c}
  </style>
</head>
<body>
  <div class="code">404</div>
  <h1>Page introuvable</h1>
  <p>La ressource demandée n'existe pas dans l'espace intranet.</p>
  <a href="/">← Retour à l'intranet</a>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/intranet/pageserreurs/403.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>403 — Intranet TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0a0a0a;color:#e0e0e0;min-height:100vh;display:flex;align-items:center;justify-content:center;flex-direction:column;text-align:center;padding:2rem;gap:1rem}
    .code{font-size:clamp(6rem,20vw,10rem);font-weight:900;line-height:1;color:#e74c3c;letter-spacing:-.05em;text-shadow:0 0 40px rgba(231,76,60,.3)}
    h1{font-size:1.4rem;font-weight:600}p{color:#707070;font-size:.9rem;max-width:360px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#c0392b;color:white;padding:.65rem 1.6rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.9rem;transition:background .2s}
    a:hover{background:#e74c3c}
  </style>
</head>
<body>
  <div class="code">403</div>
  <h1>Accès refusé</h1>
  <p>Vous ne disposez pas des autorisations nécessaires pour accéder à cette zone.</p>
  <a href="/">← Retour à l'intranet</a>
</body>
</html>
EOF

cat > "${ENV_DIR}/www/intranet/pageserreurs/401.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>401 — Authentification requise</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0a0a0a;color:#e0e0e0;min-height:100vh;display:flex;align-items:center;justify-content:center;flex-direction:column;text-align:center;padding:2rem;gap:.8rem}
    .icon{font-size:4rem;filter:drop-shadow(0 0 12px rgba(231,76,60,.4))}
    .code{font-size:clamp(5rem,15vw,8rem);font-weight:900;line-height:1;color:#e74c3c;letter-spacing:-.05em;text-shadow:0 0 40px rgba(231,76,60,.3)}
    h1{font-size:1.4rem;font-weight:600}p{color:#707070;font-size:.9rem;max-width:380px;line-height:1.6}
    .hint{background:#181818;border:1px solid #2a2a2a;border-left:3px solid #e74c3c;border-radius:8px;padding:.8rem 1.2rem;font-size:.82rem;color:#9a9a9a;max-width:380px;text-align:left;margin-top:.3rem}
  </style>
</head>
<body>
  <div class="icon">🔐</div>
  <div class="code">401</div>
  <h1>Authentification requise</h1>
  <p>Vous devez vous identifier pour accéder à l'espace intranet TEK-IT-IZY.</p>
  <div class="hint">💡 Utilisez vos identifiants intranet fournis par votre administrateur.</div>
</body>
</html>
EOF

# ─────────────────────────────────────────────
# 3. Configuration Nginx pour Docker
# ─────────────────────────────────────────────
echo "[3/5] Configuration Nginx..."

cat > "${ENV_DIR}/nginx/fastcgi-php.conf" <<'EOF'
fastcgi_split_path_info ^(.+\.php)(/.*)$;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param PATH_INFO       $fastcgi_path_info;
fastcgi_index index.php;
include fastcgi_params;
EOF

# Site par défaut raspb215 — ${RASPI_NUM} substitué, variables nginx échappées
cat > "${ENV_DIR}/nginx/conf.d/raspb${RASPI_NUM}.conf" <<EOF
server {
    listen 80;
    server_name raspb${RASPI_NUM}.univ-lr.fr;

    root /var/www/html;
    index index.html perso.html;

    location ~ ^/~([^/]+)(/.*)?$ {
        alias /home/\$1/public_html\$2;
        index index.html perso.html;
        autoindex off;
        location ~ \.php$ {
            include /etc/nginx/fastcgi-php.conf;
            fastcgi_pass php-fpm:9000;
        }
    }
    location ~ \.php$ {
        include /etc/nginx/fastcgi-php.conf;
        fastcgi_pass php-fpm:9000;
    }
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

cat > "${ENV_DIR}/nginx/conf.d/www.tek-it-izy.org.conf" <<'EOF'
server {
    listen 80;
    server_name www.tek-it-izy.org;
    root /www/public;
    index index.html accueil.html;
    access_log /www/log/acces/access.log;
    error_log  /www/log/erreur/error.log;
    autoindex on;
    error_page 404 /pageserreurs/404.html;
    error_page 403 /pageserreurs/403.html;
    location /pageserreurs/ { root /www; internal; }
    location / { try_files $uri $uri/ =404; }
}
EOF

cat > "${ENV_DIR}/nginx/conf.d/intranet.tek-it-izy.org.conf" <<'EOF'
server {
    listen 2025;
    server_name intranet.tek-it-izy.org;
    root /www/intranet;
    index index.html intranet.html;
    access_log /www/intranetlog/acces/access.log;
    error_log  /www/intranetlog/erreur/error.log;
    autoindex off;
    error_page 404 /pageserreurs/404.html;
    error_page 403 /pageserreurs/403.html;
    error_page 401 /pageserreurs/401.html;
    location /pageserreurs/ { root /www/intranet; internal; }
    auth_basic "Accès Intranet TEK-IT-IZY";
    auth_basic_user_file /etc/nginx/auth/.htpasswd_intranet;
    location ~ ^/~([^/]+)(/.*)?$ {
        alias /home/$1/pages_personnelles$2;
        index index.html intranet.html;
        autoindex off;
        auth_basic "Accès personnel";
        auth_basic_user_file /home/$1/.htpasswd;
    }
    location / { try_files $uri $uri/ =404; }
}
EOF

# ─────────────────────────────────────────────
# 4. Fichier htpasswd
# ─────────────────────────────────────────────
echo "[4/5] Création du fichier htpasswd..."
if command -v htpasswd &>/dev/null; then
    echo "T&k!t!zY" | htpasswd -i -c "${ENV_DIR}/nginx/auth/.htpasswd_intranet" intranet
elif command -v openssl &>/dev/null; then
    echo "intranet:$(openssl passwd -apr1 'T&k!t!zY')" \
        > "${ENV_DIR}/nginx/auth/.htpasswd_intranet"
else
    echo -e "${RED}Erreur : ni htpasswd ni openssl disponible.${NC}"
    exit 1
fi
chmod 644 "${ENV_DIR}/nginx/auth/.htpasswd_intranet"  # 644 en local : nginx user du container n'est pas www-data

# ─────────────────────────────────────────────
# 5. Mise à jour /etc/hosts
# ─────────────────────────────────────────────
echo "[5/5] Mise à jour de /etc/hosts..."
sudo sed -i \
    '/# TEK-IT-IZY test local/d;/raspb'"${RASPI_NUM}"'\.univ-lr\.fr/d;/www\.tek-it-izy\.org/d;/intranet\.tek-it-izy\.org/d' \
    /etc/hosts
{
    echo "# TEK-IT-IZY test local"
    echo "127.0.0.1   raspb${RASPI_NUM}.univ-lr.fr"
    echo "127.0.0.1   www.tek-it-izy.org"
    echo "127.0.0.1   intranet.tek-it-izy.org"
} | sudo tee -a /etc/hosts > /dev/null

# ─────────────────────────────────────────────
# Redémarrage Docker Compose (recharge les fichiers)
# ─────────────────────────────────────────────
echo ""
echo "Rechargement des conteneurs Docker..."
dc up -d --force-recreate

echo ""
echo "========================================="
echo "  Environnement de test prêt !"
echo "========================================="
echo ""
echo "  URLs de test :"
echo "  - http://raspb${RASPI_NUM}.univ-lr.fr:${HTTP_PORT}/"
echo "  - http://www.tek-it-izy.org:${HTTP_PORT}/"
echo "  - http://intranet.tek-it-izy.org:${INTRANET_PORT}/"
echo "    (login: intranet / mdp: T&k!t!zY)"
echo ""
echo "  Logs en direct : docker compose logs -f nginx"
echo "  Pour arrêter   : ./test_local.sh --stop"

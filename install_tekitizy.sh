#!/bin/bash
# ============================================================
#  SAE2.04 - Script d'installation TEK-IT-IZY
#  Raspberry Pi : raspb215.univ-lr.fr (10.192.51.215)
# ============================================================

set -e

RASPI_IP="10.192.51.215"
RASPI_NUM="215"

echo "========================================="
echo "  Installation TEK-IT-IZY - raspb${RASPI_NUM}"
echo "========================================="

# ─────────────────────────────────────────────
# 1. Installation Nginx + PHP-FPM
# ─────────────────────────────────────────────
echo "[1/6] Installation de Nginx et PHP-FPM..."
sudo apt update
sudo apt install -y nginx php8.1-fpm php8.1-cli apache2-utils

sudo systemctl enable nginx
sudo systemctl enable php8.1-fpm
sudo systemctl start nginx
sudo systemctl start php8.1-fpm

# ─────────────────────────────────────────────
# 2. Création de l'arborescence des sites
# ─────────────────────────────────────────────
echo "[2/6] Création de l'arborescence..."

sudo mkdir -p /www/public
sudo mkdir -p /www/log/acces
sudo mkdir -p /www/log/erreur
sudo mkdir -p /www/pageserreurs

sudo mkdir -p /www/intranet
sudo mkdir -p /www/intranet/pageserreurs
sudo mkdir -p /www/intranetlog/acces
sudo mkdir -p /www/intranetlog/erreur

sudo chown -R www-data:www-data /www
sudo chmod -R 755 /www

# ─────────────────────────────────────────────
# 3. Pages HTML, pages d'erreur et favicons
# ─────────────────────────────────────────────
echo "[3/6] Création des pages HTML et favicons..."

# ══════════════════════════════════════════════
#  SITE PAR DÉFAUT — raspb215.univ-lr.fr
# ══════════════════════════════════════════════

sudo tee /var/www/html/favicon.svg > /dev/null <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#003087"/><stop offset="1" stop-color="#0055b3"/>
  </linearGradient></defs>
  <rect width="32" height="32" rx="8" fill="url(#g)"/>
  <text x="16" y="22" font-size="16" text-anchor="middle" fill="white" font-family="system-ui,sans-serif" font-weight="800">R</text>
</svg>
EOF

sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>raspb${RASPI_NUM} — Université de La Rochelle</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#f0f4fb;color:#1a1a2e;min-height:100vh;display:flex;flex-direction:column}
    nav{background:#003087;color:white;display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:56px;box-shadow:0 2px 10px rgba(0,0,0,.3);gap:1rem}
    nav .brand{font-weight:700;font-size:1rem;white-space:nowrap}
    nav .brand em{color:#ffd100;font-style:normal}
    .ss{display:flex;gap:.2rem;background:rgba(255,255,255,.1);border-radius:7px;padding:.2rem;flex-shrink:0}
    .ss a{color:rgba(255,255,255,.65);text-decoration:none;font-size:.78rem;padding:.28rem .7rem;border-radius:5px;transition:all .15s;font-weight:500;white-space:nowrap}
    .ss a:hover{color:white;background:rgba(255,255,255,.1)}
    .ss a.cur{color:white;background:rgba(255,255,255,.2)}
    .hero{background:linear-gradient(135deg,#003087 0%,#0055b3 100%);color:white;padding:3.5rem 2rem 5rem;text-align:center;position:relative;overflow:hidden}
    .hero::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse at 70% 0%,rgba(255,209,0,.1) 0%,transparent 60%)}
    .hero::after{content:'';position:absolute;bottom:-1px;left:0;right:0;height:55px;background:#f0f4fb;clip-path:ellipse(65% 100% at 50% 100%)}
    .badge{display:inline-flex;align-items:center;gap:.4rem;background:rgba(255,209,0,.15);border:1px solid rgba(255,209,0,.4);color:#ffd100;border-radius:20px;padding:.25rem .8rem;font-size:.78rem;margin-bottom:1.2rem;position:relative}
    .dot{display:inline-block;width:7px;height:7px;border-radius:50%;background:#22c55e;box-shadow:0 0 5px #22c55e;animation:pulse 2s infinite}
    @keyframes pulse{0%,100%{opacity:1}50%{opacity:.4}}
    .hero h1{font-size:clamp(1.8rem,5vw,2.8rem);font-weight:800;letter-spacing:-.02em;margin-bottom:.4rem;position:relative}
    .hero h1 em{color:#ffd100;font-style:normal}
    .hero p{color:rgba(255,255,255,.65);font-size:.9rem;position:relative}
    main{max-width:860px;margin:0 auto;padding:2.5rem 1.5rem;width:100%;flex:1}
    .sec{display:flex;align-items:center;gap:.6rem;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7c99;margin-bottom:1rem}
    .sec::after{content:'';flex:1;height:1px;background:#dde6f5}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1rem;margin-bottom:2.5rem}
    .card{background:white;border-radius:12px;padding:1.4rem;box-shadow:0 2px 10px rgba(0,48,135,.07);border:1px solid #e4ecf7;transition:transform .18s,box-shadow .18s;text-decoration:none;color:inherit;display:block}
    .card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,48,135,.12);border-color:#b8ccee}
    .card-row{display:flex;align-items:center;gap:.7rem;margin-bottom:.6rem}
    .ico{width:36px;height:36px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.8rem;flex-shrink:0}
    .ico-b{background:#e8f0fe;color:#003087}
    .ico-g{background:#fff8e1;color:#b45309}
    .ico-v{background:#e6f4ea;color:#15803d}
    .card h3{font-size:.92rem;font-weight:600}
    .card p{font-size:.82rem;color:#6b7c99;line-height:1.5;margin-bottom:.4rem}
    code{background:#f0f4fb;color:#003087;padding:.15rem .45rem;border-radius:5px;font-size:.78rem;font-family:'SF Mono',Consolas,monospace}
    table{width:100%;background:white;border-radius:12px;overflow:hidden;box-shadow:0 2px 10px rgba(0,48,135,.07);border:1px solid #e4ecf7;border-collapse:collapse}
    tr:not(:last-child){border-bottom:1px solid #f0f4fb}
    td{padding:.8rem 1.1rem;font-size:.85rem}
    td:first-child{font-weight:600;color:#6b7c99;width:42%}
    td:last-child{color:#1a1a2e;font-family:'SF Mono',Consolas,monospace;font-size:.8rem}
    footer{text-align:center;padding:1.5rem;color:#a0aec0;font-size:.78rem;border-top:1px solid #e4ecf7;margin-top:auto}
  </style>
</head>
<body>
  <nav>
    <div class="brand">raspb<em>${RASPI_NUM}</em>.univ-lr.fr</div>
    <div class="ss">
      <a href="http://raspb${RASPI_NUM}.univ-lr.fr" class="cur">Serveur</a>
      <a href="http://www.tek-it-izy.org">Public</a>
      <a href="http://intranet.tek-it-izy.org:2025">Intranet</a>
    </div>
  </nav>

  <div class="hero">
    <div class="badge"><span class="dot"></span> Serveur actif</div>
    <h1>Raspberry Pi <em>${RASPI_NUM}</em></h1>
    <p>SAE 2.04 — Administration Système &amp; Réseaux</p>
  </div>

  <main>
    <p class="sec">Sites hébergés</p>
    <div class="grid">
      <a class="card" href="http://www.tek-it-izy.org">
        <div class="card-row"><div class="ico ico-b">PUB</div><h3>Site public</h3></div>
        <p>Ouvert à tous — port standard</p>
        <code>www.tek-it-izy.org</code>
      </a>
      <a class="card" href="http://intranet.tek-it-izy.org:2025">
        <div class="card-row"><div class="ico ico-g">INT</div><h3>Intranet</h3></div>
        <p>Accès restreint par mot de passe</p>
        <code>intranet.tek-it-izy.org:2025</code>
      </a>
      <div class="card">
        <div class="card-row"><div class="ico ico-v">USR</div><h3>Pages personnelles</h3></div>
        <p>Répertoire public de chaque utilisateur</p>
        <form style="display:flex;gap:.4rem;margin-top:.6rem" onsubmit="event.preventDefault();var u=this.u.value.trim();if(u)location.href='/~'+u+'/'">
          <input name="u" placeholder="login" style="flex:1;background:#f0f4fb;border:1px solid #dde6f5;color:#1a1a2e;border-radius:6px;padding:.35rem .6rem;font-size:.8rem;outline:none">
          <button type="submit" style="background:#003087;color:white;border:none;border-radius:6px;padding:.35rem .8rem;cursor:pointer;font-size:.85rem;font-weight:600">></button>
        </form>
      </div>
    </div>

    <p class="sec">Informations serveur</p>
    <table>
      <tr><td>Hôte</td><td>raspb${RASPI_NUM}.univ-lr.fr</td></tr>
      <tr><td>Adresse IP</td><td>${RASPI_IP}</td></tr>
      <tr><td>Serveur web</td><td>nginx + PHP-FPM 8.1</td></tr>
      <tr><td>Pages perso</td><td>~/public_html/</td></tr>
      <tr><td>OS</td><td>Ubuntu Server 25.10 (Raspberry Pi)</td></tr>
    </table>
  </main>

  <footer>SAE 2.04 — IUT La Rochelle — 2024-2025</footer>
</body>
</html>
EOF

# ══════════════════════════════════════════════
#  SITE PUBLIC — www.tek-it-izy.org
# ══════════════════════════════════════════════

sudo tee /www/public/favicon.svg > /dev/null <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#16213e"/><stop offset="1" stop-color="#0f3460"/>
  </linearGradient></defs>
  <rect width="32" height="32" rx="8" fill="url(#g)"/>
  <text x="16" y="22" font-size="16" text-anchor="middle" fill="#3fb950" font-family="system-ui,sans-serif" font-weight="800">T</text>
</svg>
EOF

sudo tee /www/public/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>TEK-IT-IZY — Solutions Tech</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0d1117;--sf:#161b22;--bd:#21262d;--gr:#3fb950;--bl:#58a6ff;--tx:#e6edf3;--mu:#8b949e}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--tx);min-height:100vh;display:flex;flex-direction:column}
    nav{background:rgba(13,17,23,.95);backdrop-filter:blur(12px);border-bottom:1px solid var(--bd);position:sticky;top:0;z-index:10;display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:58px;gap:1rem}
    .logo{font-weight:800;font-size:1.05rem;background:linear-gradient(90deg,var(--gr),var(--bl));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;white-space:nowrap}
    .ss{display:flex;gap:.2rem;background:rgba(255,255,255,.04);border:1px solid var(--bd);border-radius:7px;padding:.2rem;flex-shrink:0}
    .ss a{color:var(--mu);text-decoration:none;font-size:.78rem;padding:.28rem .7rem;border-radius:5px;transition:all .15s;font-weight:500;white-space:nowrap}
    .ss a:hover{color:var(--tx);background:rgba(255,255,255,.05)}
    .ss a.cur{color:var(--tx);background:rgba(255,255,255,.08)}
    .hero{padding:6rem 2rem 5rem;text-align:center;background:radial-gradient(ellipse 80% 60% at 50% -10%,rgba(63,185,80,.1) 0%,transparent 70%)}
    .htag{display:inline-flex;align-items:center;gap:.4rem;background:rgba(63,185,80,.08);border:1px solid rgba(63,185,80,.25);border-radius:20px;padding:.28rem .9rem;font-size:.78rem;color:var(--gr);margin-bottom:1.5rem}
    .pd{display:inline-block;width:6px;height:6px;border-radius:50%;background:var(--gr);animation:p 2s infinite}
    @keyframes p{0%,100%{opacity:1;box-shadow:0 0 0 0 rgba(63,185,80,.4)}50%{opacity:.7;box-shadow:0 0 0 4px rgba(63,185,80,0)}}
    h1{font-size:clamp(2.8rem,8vw,5.5rem);font-weight:900;letter-spacing:-.04em;line-height:1;margin-bottom:1.2rem}
    .gr{background:linear-gradient(135deg,var(--gr) 0%,var(--bl) 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
    .hero p{font-size:1.1rem;color:var(--mu);max-width:500px;margin:0 auto 2.5rem;line-height:1.6}
    .cta{display:flex;gap:1rem;justify-content:center;flex-wrap:wrap}
    .btn{padding:.72rem 1.8rem;border-radius:8px;font-size:.92rem;font-weight:600;text-decoration:none;transition:all .2s;display:inline-block}
    .btn-g{background:var(--gr);color:#0d1117}.btn-g:hover{background:#56d364;transform:translateY(-1px)}
    .btn-o{background:transparent;color:var(--tx);border:1px solid var(--bd)}.btn-o:hover{background:var(--sf)}
    .stats{background:var(--sf);border-top:1px solid var(--bd);border-bottom:1px solid var(--bd);padding:2.5rem 2rem;display:flex;justify-content:center;gap:4rem;flex-wrap:wrap;text-align:center}
    .sv{font-size:2rem;font-weight:800;color:var(--gr)}
    .sl{font-size:.78rem;color:var(--mu);margin-top:.2rem}
    .features{padding:5rem 2rem;max-width:1080px;margin:0 auto;width:100%}
    .fh{text-align:center;margin-bottom:3rem}
    .fh h2{font-size:1.9rem;font-weight:700;margin-bottom:.4rem}
    .fh p{color:var(--mu)}
    .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:1.2rem}
    .card{background:var(--sf);border:1px solid var(--bd);border-radius:14px;padding:1.8rem;transition:border-color .2s,transform .2s}
    .card:hover{border-color:var(--gr);transform:translateY(-3px)}
    .cico{width:36px;height:36px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.78rem;margin-bottom:1rem}
    .cico-g{background:rgba(63,185,80,.15);color:#3fb950}
    .cico-b{background:rgba(88,166,255,.15);color:#58a6ff}
    .cico-r{background:rgba(247,129,102,.15);color:#f78166}
    .card h3{font-size:1rem;font-weight:600;margin-bottom:.5rem}
    .card p{color:var(--mu);font-size:.875rem;line-height:1.6}
    footer{margin-top:auto;padding:1.8rem 2rem;border-top:1px solid var(--bd);display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem;font-size:.8rem;color:var(--mu)}
    .lf{font-weight:700;color:var(--tx)}
  </style>
</head>
<body>
  <nav>
    <span class="logo">TEK-IT-IZY</span>
    <div class="ss">
      <a href="http://raspb215.univ-lr.fr">Serveur</a>
      <a href="http://www.tek-it-izy.org" class="cur">Public</a>
      <a href="http://intranet.tek-it-izy.org:2025">Intranet</a>
    </div>
  </nav>

  <section class="hero">
    <div class="htag"><span class="pd"></span> Disponible 24/7</div>
    <h1><span class="gr">TEK-IT-IZY</span></h1>
    <p>Solutions technologiques innovantes pour votre transformation numérique.</p>
    <div class="cta">
      <a href="/accueil.html" class="btn btn-g">Découvrir</a>
      <a href="#services" class="btn btn-o">Nos services</a>
    </div>
  </section>

  <div class="stats">
    <div><div class="sv">3</div><div class="sl">Sites hébergés</div></div>
    <div><div class="sv">99.9%</div><div class="sl">Disponibilité</div></div>
    <div><div class="sv">PHP 8.1</div><div class="sl">Stack moderne</div></div>
  </div>

  <section class="features" id="services">
    <div class="fh"><h2>Ce que nous proposons</h2><p>Des solutions adaptées à chaque besoin</p></div>
    <div class="cards">
      <div class="card"><div class="cico cico-g">WEB</div><h3>Développement Web</h3><p>Applications web modernes, performantes et sécurisées, conçues sur-mesure pour vos besoins.</p></div>
      <div class="card"><div class="cico cico-b">CLO</div><h3>Infrastructure Cloud</h3><p>Hébergement scalable, haute disponibilité et monitoring en temps réel de vos services.</p></div>
      <div class="card"><div class="cico cico-r">SEC</div><h3>Cybersécurité</h3><p>Audit, protection et surveillance proactive de vos systèmes contre les menaces.</p></div>
    </div>
  </section>

  <footer><span class="lf">TEK-IT-IZY</span><span>© 2025 — Tous droits réservés</span></footer>
</body>
</html>
EOF

sudo tee /www/public/accueil.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>A propos — TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0d1117;--sf:#161b22;--bd:#21262d;--gr:#3fb950;--bl:#58a6ff;--tx:#e6edf3;--mu:#8b949e}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--tx);min-height:100vh;display:flex;flex-direction:column}
    nav{background:rgba(13,17,23,.95);backdrop-filter:blur(12px);border-bottom:1px solid var(--bd);display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:58px;gap:1rem;position:sticky;top:0;z-index:10}
    .logo{font-weight:800;font-size:1.05rem;background:linear-gradient(90deg,var(--gr),var(--bl));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;text-decoration:none;white-space:nowrap}
    .ss{display:flex;gap:.2rem;background:rgba(255,255,255,.04);border:1px solid var(--bd);border-radius:7px;padding:.2rem;flex-shrink:0}
    .ss a{color:var(--mu);text-decoration:none;font-size:.78rem;padding:.28rem .7rem;border-radius:5px;transition:all .15s;font-weight:500;white-space:nowrap}
    .ss a:hover{color:var(--tx);background:rgba(255,255,255,.05)}
    .ss a.cur{color:var(--tx);background:rgba(255,255,255,.08)}
    .ph{padding:4rem 2rem;text-align:center;border-bottom:1px solid var(--bd)}
    .ph h1{font-size:2.4rem;font-weight:800;letter-spacing:-.03em;margin-bottom:.5rem}
    .ph p{color:var(--mu);font-size:1rem;max-width:460px;margin:0 auto}
    main{max-width:900px;margin:0 auto;padding:3rem 2rem;width:100%;flex:1}
    .ag{display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:2rem}
    h2{font-size:1.2rem;font-weight:700;margin-bottom:1rem;color:var(--gr)}
    .box{background:var(--sf);border:1px solid var(--bd);border-radius:14px;padding:2rem}
    .vi{display:flex;gap:.8rem;margin-bottom:1.2rem}
    .vi:last-child{margin-bottom:0}
    .vb{width:32px;height:32px;border-radius:7px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.72rem;flex-shrink:0;margin-top:.1rem}
    .vb-y{background:rgba(255,209,0,.15);color:#ffd100}
    .vb-r{background:rgba(247,129,102,.15);color:#f78166}
    .vb-g{background:rgba(63,185,80,.15);color:#3fb950}
    .vi strong{display:block;font-size:.9rem;color:var(--tx);margin-bottom:.2rem}
    .vi p{color:var(--mu);line-height:1.6;font-size:.85rem}
    .mb{display:flex;align-items:center;gap:1rem;padding:.8rem 0;border-bottom:1px solid var(--bd)}
    .mb:last-child{border-bottom:none}
    .av{width:38px;height:38px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.78rem;flex-shrink:0}
    .av-1{background:linear-gradient(135deg,#3fb950,#58a6ff);color:white}
    .av-2{background:linear-gradient(135deg,#f78166,#ff7b72);color:white}
    .av-3{background:linear-gradient(135deg,#d2a8ff,#a371f7);color:white}
    .mi strong{display:block;font-size:.88rem;color:var(--tx)}
    .mi span{font-size:.78rem;color:var(--mu)}
    footer{margin-top:auto;padding:1.8rem;border-top:1px solid var(--bd);text-align:center;font-size:.8rem;color:var(--mu)}
    footer a{color:var(--gr);text-decoration:none}
  </style>
</head>
<body>
  <nav>
    <a href="/" class="logo">TEK-IT-IZY</a>
    <div class="ss">
      <a href="http://raspb215.univ-lr.fr">Serveur</a>
      <a href="http://www.tek-it-izy.org" class="cur">Public</a>
      <a href="http://intranet.tek-it-izy.org:2025">Intranet</a>
    </div>
  </nav>

  <div class="ph">
    <h1>A propos de nous</h1>
    <p>Une équipe passionnée au service de vos projets technologiques.</p>
  </div>

  <main>
    <div class="ag">
      <div class="box">
        <h2>Nos valeurs</h2>
        <div class="vi"><div class="vb vb-y">PERF</div><div><strong>Performance</strong><p>Chaque solution est optimisée pour offrir la meilleure expérience possible.</p></div></div>
        <div class="vi"><div class="vb vb-r">SEC</div><div><strong>Sécurité</strong><p>La protection de vos données est au coeur de chacune de nos décisions.</p></div></div>
        <div class="vi"><div class="vb vb-g">REL</div><div><strong>Fiabilité</strong><p>Des engagements tenus, une infrastructure disponible en permanence.</p></div></div>
      </div>
      <div class="box">
        <h2>L'équipe</h2>
        <div class="mb"><div class="av av-1">DEV</div><div class="mi"><strong>Equipe Dev</strong><span>Développement &amp; intégration web</span></div></div>
        <div class="mb"><div class="av av-2">INF</div><div class="mi"><strong>Equipe Infra</strong><span>Systèmes, réseaux &amp; déploiement</span></div></div>
        <div class="mb"><div class="av av-3">SEC</div><div class="mi"><strong>Equipe Sécu</strong><span>Cybersécurité &amp; conformité</span></div></div>
      </div>
    </div>
  </main>

  <footer><a href="/">TEK-IT-IZY</a> — © 2025 Tous droits réservés</footer>
</body>
</html>
EOF

sudo tee /www/pageserreurs/404.html > /dev/null <<'EOF'
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
    h1{font-size:1.3rem;font-weight:600}
    p{color:#8b949e;font-size:.88rem;max-width:340px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#238636;color:white;padding:.62rem 1.5rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.88rem;transition:background .2s}
    a:hover{background:#2ea043}
  </style>
</head>
<body>
  <div class="code">404</div>
  <h1>Page introuvable</h1>
  <p>La ressource demandée n'existe pas sur ce serveur.</p>
  <a href="/">Retour a l'accueil</a>
</body>
</html>
EOF

sudo tee /www/pageserreurs/403.html > /dev/null <<'EOF'
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
    h1{font-size:1.3rem;font-weight:600}
    p{color:#8b949e;font-size:.88rem;max-width:340px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#238636;color:white;padding:.62rem 1.5rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.88rem;transition:background .2s}
    a:hover{background:#2ea043}
  </style>
</head>
<body>
  <div class="code">403</div>
  <h1>Acces refusé</h1>
  <p>Vous n'avez pas les droits nécessaires pour accéder à cette ressource.</p>
  <a href="/">Retour a l'accueil</a>
</body>
</html>
EOF

# ══════════════════════════════════════════════
#  SITE INTRANET — intranet.tek-it-izy.org
# ══════════════════════════════════════════════

sudo tee /www/intranet/favicon.svg > /dev/null <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#1a0505"/><stop offset="1" stop-color="#2c0a0a"/>
  </linearGradient></defs>
  <rect width="32" height="32" rx="8" fill="url(#g)"/>
  <text x="16" y="22" font-size="16" text-anchor="middle" fill="#e74c3c" font-family="system-ui,sans-serif" font-weight="800">I</text>
</svg>
EOF

sudo tee /www/intranet/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Intranet — TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0a0a0a;--sf:#111;--bd:#2a2a2a;--rd:#e74c3c;--tx:#e0e0e0;--mu:#707070}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--tx);min-height:100vh;display:flex;flex-direction:column}
    nav{background:var(--sf);border-bottom:1px solid var(--bd);display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:58px;gap:1rem}
    .brand{display:flex;align-items:center;gap:.5rem;font-weight:700;font-size:.95rem;white-space:nowrap}
    .rdot{width:7px;height:7px;border-radius:50%;background:var(--rd);box-shadow:0 0 5px var(--rd);flex-shrink:0;animation:blink 3s infinite}
    @keyframes blink{0%,88%,100%{opacity:1}94%{opacity:.2}}
    .ss{display:flex;gap:.2rem;background:rgba(255,255,255,.03);border:1px solid var(--bd);border-radius:7px;padding:.2rem;flex-shrink:0}
    .ss a{color:var(--mu);text-decoration:none;font-size:.78rem;padding:.28rem .7rem;border-radius:5px;transition:all .15s;font-weight:500;white-space:nowrap}
    .ss a:hover{color:var(--tx);background:rgba(255,255,255,.05)}
    .ss a.cur{color:var(--rd);background:rgba(231,76,60,.08)}
    .hero{padding:4rem 2rem;text-align:center;background:radial-gradient(ellipse 70% 50% at 50% 0%,rgba(231,76,60,.07) 0%,transparent 70%);border-bottom:1px solid var(--bd)}
    .badge-r{display:inline-block;background:rgba(231,76,60,.1);border:1px solid rgba(231,76,60,.3);color:var(--rd);border-radius:6px;padding:.22rem .65rem;font-size:.72rem;font-weight:700;letter-spacing:.06em;text-transform:uppercase;margin-bottom:1.4rem}
    h1{font-size:clamp(1.6rem,4vw,2.4rem);font-weight:800;letter-spacing:-.02em;margin-bottom:.4rem}
    h1 span{color:var(--rd)}
    .hero p{color:var(--mu);font-size:.88rem}
    main{max-width:860px;margin:0 auto;padding:2.5rem 1.5rem;width:100%;flex:1;display:flex;flex-direction:column;gap:1.5rem}
    .sec{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.1em;color:var(--mu);display:flex;align-items:center;gap:.5rem}
    .sec::after{content:'';flex:1;height:1px;background:var(--bd)}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:1rem}
    .card{background:var(--sf);border:1px solid var(--bd);border-radius:12px;padding:1.4rem;text-decoration:none;color:var(--tx);transition:border-color .2s,transform .15s;display:block}
    .card:hover{border-color:var(--rd);transform:translateY(-2px)}
    .cico{width:34px;height:34px;border-radius:7px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.72rem;margin-bottom:.7rem}
    .ci-r{background:rgba(231,76,60,.12);color:var(--rd)}
    .ci-g{background:rgba(46,204,113,.12);color:#2ecc71}
    .ci-b{background:rgba(88,166,255,.12);color:#58a6ff}
    .card h3{font-size:.9rem;font-weight:600;margin-bottom:.3rem}
    .card p{font-size:.8rem;color:var(--mu);line-height:1.5}
    .info-bar{background:var(--sf);border:1px solid var(--bd);border-left:3px solid var(--rd);border-radius:8px;padding:.9rem 1.2rem;font-size:.82rem;color:var(--mu);display:flex;gap:.6rem;align-items:center}
    .info-bar strong{color:var(--tx)}
    footer{margin-top:auto;padding:1.5rem;border-top:1px solid var(--bd);text-align:center;font-size:.78rem;color:var(--mu)}
  </style>
</head>
<body>
  <nav>
    <div class="brand"><span class="rdot"></span> TEK-IT-IZY — Intranet</div>
    <div class="ss">
      <a href="http://raspb215.univ-lr.fr">Serveur</a>
      <a href="http://www.tek-it-izy.org">Public</a>
      <a href="http://intranet.tek-it-izy.org:2025" class="cur">Intranet</a>
    </div>
  </nav>

  <div class="hero">
    <div class="badge-r">Acces restreint</div>
    <h1>Espace <span>Intranet</span></h1>
    <p>Plateforme collaborative réservée aux membres de l'organisation.</p>
  </div>

  <main>
    <p class="sec">Acces rapide</p>
    <div class="grid">
      <a href="/intranet.html" class="card">
        <div class="cico ci-r">TDB</div>
        <h3>Tableau de bord</h3>
        <p>Ressources et services internes de l'organisation.</p>
      </a>
      <div class="card">
        <div class="cico ci-g">USR</div>
        <h3>Pages personnelles</h3>
        <p>Accéder à l'espace d'un collaborateur</p>
        <form style="display:flex;gap:.4rem;margin-top:.7rem" onsubmit="event.preventDefault();var u=this.u.value.trim();if(u)location.href='/~'+u+'/'">
          <input name="u" placeholder="login" style="flex:1;background:#1a1a1a;border:1px solid #333;color:#e0e0e0;border-radius:6px;padding:.38rem .65rem;font-size:.8rem;outline:none">
          <button type="submit" style="background:#c0392b;color:white;border:none;border-radius:6px;padding:.38rem .85rem;cursor:pointer;font-size:.88rem;font-weight:600;transition:background .2s" onmouseover="this.style.background='#e74c3c'" onmouseout="this.style.background='#c0392b'">></button>
        </form>
      </div>
      <div class="card">
        <div class="cico ci-b">DIR</div>
        <h3>Répertoire</h3>
        <p>Parcourir les ressources disponibles sur ce serveur intranet.</p>
      </div>
    </div>

    <div class="info-bar">
      Port <strong>2025</strong> — Authentification requise pour toutes les pages
    </div>
  </main>

  <footer>TEK-IT-IZY Intranet — Usage interne uniquement — © 2025</footer>
</body>
</html>
EOF

sudo tee /www/intranet/intranet.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Tableau de bord — Intranet TEK-IT-IZY</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    :root{--bg:#0a0a0a;--sf:#111;--bd:#2a2a2a;--rd:#e74c3c;--tx:#e0e0e0;--mu:#707070;--gn:#2ecc71}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:var(--bg);color:var(--tx);min-height:100vh;display:flex;flex-direction:column}
    nav{background:var(--sf);border-bottom:1px solid var(--bd);display:flex;align-items:center;justify-content:space-between;padding:0 2rem;height:58px;gap:1rem}
    .brand{display:flex;align-items:center;gap:.5rem;font-weight:700;font-size:.95rem;white-space:nowrap}
    .rdot{width:7px;height:7px;border-radius:50%;background:var(--rd);box-shadow:0 0 5px var(--rd);flex-shrink:0}
    .ss{display:flex;gap:.2rem;background:rgba(255,255,255,.03);border:1px solid var(--bd);border-radius:7px;padding:.2rem;flex-shrink:0}
    .ss a{color:var(--mu);text-decoration:none;font-size:.78rem;padding:.28rem .7rem;border-radius:5px;transition:all .15s;font-weight:500;white-space:nowrap}
    .ss a:hover{color:var(--tx);background:rgba(255,255,255,.05)}
    .ss a.cur{color:var(--rd);background:rgba(231,76,60,.08)}
    .ph{padding:2rem;border-bottom:1px solid var(--bd);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:1rem}
    .ph h1{font-size:1.4rem;font-weight:700}
    .ph p{color:var(--mu);font-size:.82rem}
    .bc{font-size:.8rem;color:var(--mu)}
    .bc a{color:var(--rd);text-decoration:none}
    main{max-width:980px;margin:0 auto;padding:2rem 1.5rem;width:100%;flex:1;display:grid;grid-template-columns:1fr 1fr;gap:1.2rem}
    @media(max-width:640px){main{grid-template-columns:1fr}}
    .w{background:var(--sf);border:1px solid var(--bd);border-radius:12px;padding:1.4rem}
    .wh{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:var(--mu);margin-bottom:1rem;padding-bottom:.75rem;border-bottom:1px solid var(--bd)}
    .sr{display:flex;align-items:baseline;gap:.5rem;margin-bottom:.75rem}
    .sv{font-size:1.7rem;font-weight:800;color:var(--rd)}
    .ss2{font-size:.78rem;color:var(--mu)}
    .str{display:flex;align-items:center;justify-content:space-between;padding:.5rem 0;border-bottom:1px solid var(--bd);font-size:.82rem}
    .str:last-child{border-bottom:none}
    .son{color:var(--gn);font-weight:600;font-size:.75rem}
    .lr{display:flex;align-items:center;gap:.7rem;padding:.55rem 0;border-bottom:1px solid var(--bd);font-size:.82rem}
    .lr:last-child{border-bottom:none}
    .lrb{width:28px;height:28px;border-radius:6px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.65rem;flex-shrink:0}
    .lb1{background:rgba(63,185,80,.12);color:#3fb950}
    .lb2{background:rgba(88,166,255,.12);color:#58a6ff}
    .lb3{background:rgba(231,76,60,.12);color:var(--rd)}
    .lr span{color:var(--mu);font-size:.76rem;margin-left:auto}
    footer{padding:1.5rem;border-top:1px solid var(--bd);text-align:center;font-size:.78rem;color:var(--mu);margin-top:auto}
  </style>
</head>
<body>
  <nav>
    <div class="brand"><span class="rdot"></span> TEK-IT-IZY — Intranet</div>
    <div class="ss">
      <a href="http://raspb215.univ-lr.fr">Serveur</a>
      <a href="http://www.tek-it-izy.org">Public</a>
      <a href="http://intranet.tek-it-izy.org:2025" class="cur">Intranet</a>
    </div>
  </nav>

  <div class="ph">
    <div><h1>Tableau de bord</h1><p>Vue d'ensemble des ressources internes.</p></div>
    <div class="bc"><a href="/">Accueil</a> / Tableau de bord</div>
  </div>

  <main>
    <div class="w">
      <div class="wh">Ressources</div>
      <div class="sr"><span class="sv">3</span><span class="ss2">Sites actifs</span></div>
      <div class="sr"><span class="sv">2025</span><span class="ss2">Port intranet</span></div>
      <div class="sr"><span class="sv">PHP 8.1</span><span class="ss2">Moteur dynamique</span></div>
    </div>
    <div class="w">
      <div class="wh">Services</div>
      <div class="str"><span>nginx</span><span class="son">actif</span></div>
      <div class="str"><span>PHP-FPM</span><span class="son">actif</span></div>
      <div class="str"><span>Auth HTTP</span><span class="son">activée</span></div>
      <div class="str"><span>Logs accès</span><span class="son">activés</span></div>
    </div>
    <div class="w" style="grid-column:span 2">
      <div class="wh">Liens rapides</div>
      <div class="lr"><div class="lrb lb1">PUB</div> Site public TEK-IT-IZY<span>www.tek-it-izy.org</span></div>
      <div class="lr"><div class="lrb lb2">SRV</div> Serveur Raspberry Pi<span>raspb215.univ-lr.fr</span></div>
      <div class="lr"><div class="lrb lb3">USR</div> Pages personnelles<span>/~login/pages_personnelles/</span></div>
    </div>
  </main>

  <footer>TEK-IT-IZY Intranet — Usage interne uniquement — © 2025</footer>
</body>
</html>
EOF

sudo tee /www/intranet/pageserreurs/404.html > /dev/null <<'EOF'
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
    .code{font-size:clamp(6rem,20vw,10rem);font-weight:900;line-height:1;color:#e74c3c;letter-spacing:-.05em;text-shadow:0 0 40px rgba(231,76,60,.25)}
    h1{font-size:1.3rem;font-weight:600}
    p{color:#707070;font-size:.88rem;max-width:340px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#c0392b;color:white;padding:.62rem 1.5rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.88rem;transition:background .2s}
    a:hover{background:#e74c3c}
  </style>
</head>
<body>
  <div class="code">404</div>
  <h1>Page introuvable</h1>
  <p>La ressource demandée n'existe pas dans l'espace intranet.</p>
  <a href="/">Retour a l'intranet</a>
</body>
</html>
EOF

sudo tee /www/intranet/pageserreurs/403.html > /dev/null <<'EOF'
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
    .code{font-size:clamp(6rem,20vw,10rem);font-weight:900;line-height:1;color:#e74c3c;letter-spacing:-.05em;text-shadow:0 0 40px rgba(231,76,60,.25)}
    h1{font-size:1.3rem;font-weight:600}
    p{color:#707070;font-size:.88rem;max-width:340px;line-height:1.6}
    a{display:inline-block;margin-top:.5rem;background:#c0392b;color:white;padding:.62rem 1.5rem;border-radius:8px;text-decoration:none;font-weight:600;font-size:.88rem;transition:background .2s}
    a:hover{background:#e74c3c}
  </style>
</head>
<body>
  <div class="code">403</div>
  <h1>Acces refusé</h1>
  <p>Vous ne disposez pas des autorisations nécessaires pour accéder à cette zone.</p>
  <a href="/">Retour a l'intranet</a>
</body>
</html>
EOF

sudo tee /www/intranet/pageserreurs/401.html > /dev/null <<'EOF'
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
    .code{font-size:clamp(5rem,15vw,8rem);font-weight:900;line-height:1;color:#e74c3c;letter-spacing:-.05em;text-shadow:0 0 40px rgba(231,76,60,.25)}
    h1{font-size:1.3rem;font-weight:600}
    p{color:#707070;font-size:.88rem;max-width:360px;line-height:1.6}
    .hint{background:#181818;border:1px solid #2a2a2a;border-left:3px solid #e74c3c;border-radius:8px;padding:.8rem 1.2rem;font-size:.8rem;color:#9a9a9a;max-width:360px;text-align:left;margin-top:.3rem}
  </style>
</head>
<body>
  <div class="code">401</div>
  <h1>Authentification requise</h1>
  <p>Vous devez vous identifier pour accéder à l'espace intranet TEK-IT-IZY.</p>
  <div class="hint">Utilisez vos identifiants intranet fournis par votre administrateur.</div>
</body>
</html>
EOF

sudo chown -R www-data:www-data /www

# ─────────────────────────────────────────────
# 4. Fichier .htpasswd pour l'intranet
# ─────────────────────────────────────────────
echo "[4/6] Création du fichier d'authentification..."
sudo mkdir -p /etc/nginx/auth
echo "T&k!t!zY" | sudo htpasswd -i -c /etc/nginx/auth/.htpasswd_intranet intranet
sudo chmod 640 /etc/nginx/auth/.htpasswd_intranet
sudo chown root:www-data /etc/nginx/auth/.htpasswd_intranet

# ─────────────────────────────────────────────
# 5. Configuration Nginx - Server Blocks
# ─────────────────────────────────────────────
echo "[5/6] Configuration des server blocks Nginx..."

sudo tee /etc/nginx/sites-available/raspb${RASPI_NUM}.univ-lr.fr > /dev/null <<NGINXEOF
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
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        }
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINXEOF

sudo tee /etc/nginx/sites-available/www.tek-it-izy.org > /dev/null <<'NGINXEOF'
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

    location /pageserreurs/ {
        root /www;
        internal;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINXEOF

sudo tee /etc/nginx/sites-available/intranet.tek-it-izy.org > /dev/null <<'NGINXEOF'
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

    location /pageserreurs/ {
        root /www/intranet;
        internal;
    }

    auth_basic "Acces Intranet TEK-IT-IZY";
    auth_basic_user_file /etc/nginx/auth/.htpasswd_intranet;

    location ~ ^/~([^/]+)(/.*)?$ {
        alias /home/$1/pages_personnelles$2;
        index index.html intranet.html;
        autoindex off;

        auth_basic "Acces personnel";
        auth_basic_user_file /home/$1/.htpasswd;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINXEOF

sudo ln -sf /etc/nginx/sites-available/raspb${RASPI_NUM}.univ-lr.fr /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/www.tek-it-izy.org            /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/intranet.tek-it-izy.org       /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# ─────────────────────────────────────────────
# 6. Test et redémarrage Nginx
# ─────────────────────────────────────────────
echo "[6/6] Test de la configuration Nginx..."
sudo nginx -t

echo ""
echo "Redémarrage des services..."
sudo systemctl restart php8.1-fpm
sudo systemctl restart nginx

echo ""
echo "========================================="
echo "  Installation terminée avec succès !"
echo "========================================="
echo ""
echo "  Sites configurés :"
echo "  - http://raspb${RASPI_NUM}.univ-lr.fr        (port 80)"
echo "  - http://www.tek-it-izy.org           (port 80)"
echo "  - http://intranet.tek-it-izy.org:2025 (port 2025)"
echo ""
echo "  Authentification intranet :"
echo "  - login : intranet"
echo "  - mdp   : T&k!t!zY"
echo ""
echo "  N'oublie pas de configurer /etc/hosts sur les VMs clientes !"
echo "  10.192.51.${RASPI_NUM}   raspb${RASPI_NUM}.univ-lr.fr"
echo "  10.192.51.${RASPI_NUM}   www.tek-it-izy.org"
echo "  10.192.51.${RASPI_NUM}   intranet.tek-it-izy.org"

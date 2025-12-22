#!/bin/bash
echo "=== FINAL SITEMAP STATUS ==="
echo "Date: $(date)"
echo ""

# File status
echo "1. File Status:"
[ -f "layouts/sitemap.xml" ] && echo "  ✅ layouts/sitemap.xml exists" || echo "  ❌ Missing template"
[ ! -f "layouts/sitimap.xml" ] && echo "  ✅ No typo files" || echo "  ❌ Typo file exists"
[ ! -f "static/sitemap.xml" ] && echo "  ✅ No static sitemap" || echo "  ⚠️  Static sitemap exists"

# Config status
echo ""
echo "2. Config Status:"
grep -q "enableGitInfo = true" config.toml && echo "  ✅ Git info enabled" || echo "  ❌ Git info disabled"
grep -q "\[sitemap\]" config.toml && echo "  ✅ Sitemap config exists" || echo "  ❌ Missing sitemap config"
grep -q "disableKinds" config.toml && echo "  ✅ disableKinds configured" || echo "  ⚠️  disableKinds not found"

# Build test
echo ""
echo "3. Build Test:"
rm -rf public/
hugo 2>&1 | tail -10
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    if [ -f "public/sitemap.xml" ]; then
        URL_COUNT=$(grep -c '<loc>' public/sitemap.xml)
        echo "  ✅ Build successful"
        echo "  ✅ Sitemap generated"
        echo "  URL count: $URL_COUNT"
        
        echo ""
        echo "  All URLs:"
        grep "<loc>" public/sitemap.xml | sed 's/.*<loc>//;s/<\/loc>.*//' | nl
        
        if [ "$URL_COUNT" -eq 9 ]; then
            echo ""
            echo "  🎉 Perfect! All 9 pages included."
        else
            echo ""
            echo "  ⚠️  Expected 9, got $URL_COUNT URLs"
        fi
    else
        echo "  ❌ No sitemap generated"
    fi
else
    echo "  ❌ Build failed"
fi

# Summary
echo ""
echo "=== SUMMARY ==="
if [ -f "layouts/sitemap.xml" ] && [ ! -f "static/sitemap.xml" ] && [ -f "public/sitemap.xml" ]; then
    URL_COUNT=$(grep -c '<loc>' public/sitemap.xml 2>/dev/null || echo "0")
    if [ "$URL_COUNT" -eq 9 ]; then
        echo "✅ Dynamic sitemap setup is complete and perfect!"
        echo "Next: git commit && git push"
    else
        echo "⚠️  Setup complete but wrong URL count ($URL_COUNT instead of 9)"
    fi
else
    echo "⚠️  Setup incomplete"
    echo "Issues to fix:"
    [ ! -f "layouts/sitemap.xml" ] && echo "  - Create layouts/sitemap.xml"
    [ -f "static/sitemap.xml" ] && echo "  - Remove static/sitemap.xml"
    [ ! -f "public/sitemap.xml" ] && echo "  - Fix build errors"
fi

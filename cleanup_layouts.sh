#!/bin/bash

echo "=== Cleaning up layouts/ folder ==="
echo ""

# 1. Remove typo file
if [ -f "layouts/sitimap.xml" ]; then
    echo "❌ Found typo: layouts/sitimap.xml"
    echo "   Removing misspelled file..."
    rm layouts/sitimap.xml
    echo "✅ Removed"
else
    echo "✅ No typo files found"
fi

# 2. Check for correct sitemap.xml
if [ -f "layouts/sitemap.xml" ]; then
    echo "✅ Correct file: layouts/sitemap.xml"
    echo "   Size: $(wc -l < layouts/sitemap.xml) lines"
    
    # Check if it's a valid XML template
    if head -1 layouts/sitemap.xml | grep -q "<?xml"; then
        echo "✅ Valid XML template"
    else
        echo "⚠️  Doesn't start with XML declaration"
    fi
else
    echo "❌ Missing: layouts/sitemap.xml"
fi

# 3. Remove backup/old files
echo ""
echo "=== Cleaning backups ==="
find layouts -name "*.backup" -o -name "*.old" -o -name "*.bak" 2>/dev/null | while read file; do
    echo "Removing: $file"
    rm "$file"
done

# 4. Final layout
echo ""
echo "=== Final layouts structure ==="
ls -la layouts/ | grep -E "sitemap|total"

# 5. Test the template
echo ""
echo "=== Testing Template ==="
hugo -q
if [ -f "public/sitemap.xml" ]; then
    echo "✅ Generated: public/sitemap.xml"
    echo "   URLs: $(grep -c '<loc>' public/sitemap.xml)"
    
    # Check domain
    echo ""
    echo "=== Domain Check ==="
    if grep -q "ahbeefabrication.com.au" public/sitemap.xml; then
        echo "✅ Correct domain in URLs"
    else
        echo "⚠️  Using localhost/dev domain"
        grep -o "http[^<]*" public/sitemap.xml | head -3
    fi
else
    echo "❌ Failed to generate sitemap"
fi

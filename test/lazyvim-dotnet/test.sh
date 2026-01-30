#!/bin/bash
set -e

echo "Testing LazyVim .NET feature..."

# Test dotnet CLI
if command -v dotnet >/dev/null 2>&1; then
    echo "✓ dotnet CLI available"
    echo "  SDKs: $(dotnet --list-sdks | wc -l) installed"
else
    echo "✗ dotnet not found"
    exit 1
fi

# Test dotnet-ef
if dotnet tool list -g | grep -q "dotnet-ef"; then
    echo "✓ dotnet-ef installed"
else
    echo "✗ dotnet-ef not found"
    exit 1
fi

# Test dotnet-outdated
if dotnet tool list -g | grep -q "dotnet-outdated-tool"; then
    echo "✓ dotnet-outdated-tool installed"
else
    echo "✗ dotnet-outdated-tool not found"
    exit 1
fi

# Test EasyDotnet
if dotnet tool list -g | grep -q "easydotnet"; then
    echo "✓ EasyDotnet installed"
else
    echo "✗ EasyDotnet not found"
    exit 1
fi

echo ""
echo "All .NET tests passed!"
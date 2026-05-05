import os, re
colors = set()
for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(r'AppTheme\.(\w+)', content)
                colors.update(matches)
print(", ".join(colors))

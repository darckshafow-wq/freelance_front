import os
import re

def normalize_imports(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()

                # Find all import lines
                def replace_import(match):
                    import_path = match.group(1)
                    if import_path.startswith('.'): # Relative import
                        # Calculate absolute path relative to lib
                        dir_path = os.path.dirname(filepath)
                        abs_import_path = os.path.normpath(os.path.join(dir_path, import_path))
                        # Convert to package import
                        # abs_import_path looks like lib/features/auth/models/user_model.dart
                        if abs_import_path.startswith('lib/'):
                            pkg_path = abs_import_path[4:] # remove lib/
                            return f"import 'package:freelance_front/{pkg_path}';"
                    return match.group(0)

                new_content = re.sub(r"import\s+'([^']+)'\s*;", replace_import, content)
                
                if new_content != content:
                    with open(filepath, 'w') as f:
                        f.write(new_content)
                    print(f"Updated {filepath}")

if __name__ == "__main__":
    normalize_imports('lib')

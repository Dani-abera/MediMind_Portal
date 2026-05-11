import os
import re
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the _onRefreshed signature
    # Pattern to match: Future<void> _onRefreshed(Event event, Emitter<State> emit) async {
    pattern = r"Future<void>\s+_onRefreshed\s*\(\s*[a-zA-Z0-9_]+\s+[a-zA-Z0-9_]+\s*,\s*Emitter<([a-zA-Z0-9_]+)>\s+emit\s*,?\s*\)\s*async\s*\{"
    
    match = re.search(pattern, content)
    if not match:
        return False
        
    state_class = match.group(1)
    # The loading state is usually state_class but replacing 'State' with 'Loading'
    # Or just taking the base prefix and adding Loading.
    if state_class.endswith("State"):
        loading_state = state_class[:-5] + "Loading"
    else:
        loading_state = state_class + "Loading"
        
    # Check if this loading state exists in the file (or we assume it exists in the part file)
    # Actually, let's just insert it.
    
    # Check if it already emits Loading at the start of the method
    # Find the block after the match
    start_idx = match.end()
    
    # Look at the first few lines of the method body
    body_snippet = content[start_idx:start_idx+100]
    if "emit(const " + loading_state + "())" in body_snippet or "emit(" + loading_state + "())" in body_snippet:
        return False # Already has it
        
    # Insert emit
    injection = f"\n    emit(const {loading_state}());"
    
    new_content = content[:start_idx] + injection + content[start_idx:]
    
    with open(filepath, 'w') as f:
        f.write(new_content)
        
    print(f"Updated {filepath} with {loading_state}")
    return True


files = glob.glob('lib/features/**/bloc/**/*.dart', recursive=True)
count = 0
for f in files:
    if process_file(f):
        count += 1
print(f"Total files updated: {count}")

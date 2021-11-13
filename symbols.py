import re
start = False

out = []

with open('build/out.txt', 'r') as f:
    lines = f.readlines()
    for line in lines:
        if line.startswith('Symbols:'):
            start = True
        if start and '=0x' in line and not 'UNUSED' in line:
            match = re.search(r'^(\w+)\s.+=0x([a-f0-9]+)\)', line)
            if match:
                symbol = match.groups()[0]
                addr = match.groups()[1]
                if addr:
                    out.append('al C:' + str(addr).zfill(4) + ' ' + symbol)

with open('out/main.labels', 'w') as f:
    f.write('\n'.join(out))
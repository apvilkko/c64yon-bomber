import math

g = 9.81
timescale = 0.5
m = 200 # projectile mass
Cd = 5 # drag coefficient
Cw = Cd # wind drag coefficient
gamma = 0 # wind direction
vw = 0 # wind speed

times = [x*timescale for x in range(0, 10)]
tstep = (max(times)-min(times))/len(times)

def calculate_speed_table(vx0, vy0):
    out = []
    vy = vy0
    vx = vx0
    for t in times:
        vx = (1/Cd)*(math.exp((-Cd/m)*t) * (Cw*vw*math.cos(gamma) + Cd*vx) - Cw*vw*math.cos(gamma))
        vy = (1/Cd)*math.exp((-Cd/m)*t) * (Cd*vy+m*g) - m*g/Cd
        out.append((vx, vy))
    return out

clamp_to = 0.25

def clamp(value):
    x0 = value / clamp_to
    x = math.floor(x0)
    diff1 = x0 - x
    diff2 = abs(x0 - (x+1))
    ret = (x+1)
    if diff1 < diff2:
        ret = x
    return ret

# divide value evenly in a array, e.g. 10 = [3,2,3,2]
def get_arr_value(x):
    out = [0,0,0,0]
    i = 0
    j = 0
    while sum(out) < x:
        out[i] = out[i] + 1
        i = i + 2
        if i > 3:
            if j % 2:
                i = 0
            else:
                i = 1
            j = j + 1
    return out

def encode_value(value):
    ret = get_arr_value(value)
    return ret

out = []

GROUND = 102
SPACE = 32
def translate_block(x):
    if x == '#':
        return GROUND
    elif x == ' ' or x == '0':
        return SPACE
    elif ord(x) >= ord('A') and ord(x) <= ord('Z'):
        return ord(x) - ord('A') + 1
    return x

def read_level():
    out.append('Level:')
    with open('src/level.txt', 'r') as f:
        lines = f.readlines()
        for line in lines:
            data = [str(translate_block(x)) for x in line.strip()]
            if len(line) < 10:
                data = [str(SPACE)] * 40
            joined = ','.join(data)
            out.append(f'\tdb {joined}')

yspeed = -10

speeds = [(30,yspeed),(60,yspeed),(90,yspeed)]
# normalize velocities so that max speed equals 3
max_speed = max([x[0] for x in speeds])
coef = max_speed / 3.0
count = 1
for speed in speeds:
    res = calculate_speed_table(speed[0], speed[1])
    # flip y sign also
    res = [(x[0]/coef, -x[1]/coef) for x in res]
    clamped = [(clamp(x[0]), clamp(x[1])) for x in res]
    encoded = [(encode_value(x[0]), encode_value(x[1])) for x in clamped]
    
    out.append('; speed ' + str(speed))
    out.append('Speed' + str(count) + ':')
    count = count + 1
    for r in encoded:
        out.append('\tdb ' + ','.join([str(x) for x in r[0]]) + ',' + ','.join([str(y) for y in r[1]]))
read_level()

with open('src/generated.asm', 'w') as f:
    f.write('\n'.join(out))
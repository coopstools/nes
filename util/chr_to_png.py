import png


def pull_rows():
    contents = pull_data()
    rows = []
    for i in range(0, len(contents)+1, 16):
        s, m, e = i-16, i-8, i
        for low, high in zip(contents[s:m], contents[m:e]):
            row = comb_low_and_high(low, high)
            rows += [row]
        rows += [tuple(24*[0])]
    return rows


def pull_data():
    with open("background/mario.chr", mode="rb") as f:
        return f.read()


def comb_low_and_high(low, high):
    total = []
    for _ in range(8):
        lb, hb = low % 2, high % 2
        total += [lb + 2*hb]
        low >>= 1
        high >>= 1
    return value_to_rgb(total[::-1])


color_lookup = {0: (255, 255, 255), 1: (255, 0, 0), 2: (0, 255, 0), 3: (0, 0, 255)}


def value_to_rgb(row):
    values = ()
    for entry in map(lambda v: color_lookup[v], row):
        values += entry
    return values


def save_to_png(rows):
    with open('background/mario.png', 'wb') as f:
        w = png.Writer(8, len(rows), greyscale=False)
        w.write(f, rows)


if __name__ == "__main__":
    rows = pull_rows()
    save_to_png(rows)

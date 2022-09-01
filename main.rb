require 'dxopal'
include DXOpal
Window.load_resources do
    Window.bgcolor = C_BLACK

    class UnionFind
        def initialize(n)
            @parents = Array.new(n, -1)
        end
        
        # 根を返す
        def find_root(x)
            return x if @parents[x] < 0
            return @parents[x] = find_root(@parents[x])
        end

        # サイズを返す
        def size(x)
            return -@parents[find_root(x)]
        end

        # 木を併合
        def unite(x, y)
            x = find_root(x)
            y = find_root(y)
            return false if x == y
            # サイズver.
            if size(x) < size(y)
                x, y = y, x
            end
            @parents[x] += @parents[y]
            @parents[y] = x
            return true
        end

        # 同じ木か？
        def same?(x, y)
            return find_root(x) == find_root(y)
        end
    end

    def draw_map(map)
        # 色
        block = Image.new(20, 20, C_BLACK)
        road = Image.new(20, 20, C_WHITE)
        red = Image.new(20, 20, C_RED)
        green = Image.new(20, 20, C_GREEN)
        blue = Image.new(20, 20, C_BLUE)
        yellow = Image.new(20, 20, C_YELLOW)
        cyan = Image.new(20, 20, C_CYAN)
        magenta = Image.new(20, 20, C_MAGENTA)
        (0...10).each do |i|
            (0...10).each do |j|
                Window.draw(j * 20, i * 20, road) if map[i][j] == 0
                Window.draw(j * 20, i * 20, block) if map[i][j] == 1
                Window.draw(j * 20, i * 20, red) if map[i][j] == 2
                Window.draw(j * 20, i * 20, green) if map[i][j] == 3
                Window.draw(j * 20, i * 20, blue) if map[i][j] == 4
                Window.draw(j * 20, i * 20, yellow) if map[i][j] == 5
                Window.draw(j * 20, i * 20, cyan) if map[i][j] == 6
            end
        end
    end

    def draw_color(map, uni)
        parent = {}
        cnt = 2
        (0...10).each do |x|
            (0...10).each do |y|
                if map[x][y] == 0
                    n = uni.find_root(y + x * 10)
                    unless parent[n]
                        parent[n] = cnt
                        cnt += 1
                    end
                    map[x][y] = parent[n]
                end
            end
        end
    end

    map = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 1, 1, 0, 0, 1, 1],
        [1, 0, 0, 1, 0, 1, 1, 0, 1, 1],
        [1, 1, 1, 1, 0, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 1, 1, 0, 1, 1],
        [1, 1, 1, 1, 1, 1, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 0, 0, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]

    Window.width = 200
    Window.height = 240

    black = Image.new(30, 80, C_BLACK)
    red = Image.new(20, 20, C_RED)
    font = Font.new(30, "MS ゴシック", :weight=>true)

    uni = UnionFind.new(100)
    (0...10).each do |x|
        (0...10).each do |y|
            dx = [1, -1, 0, 0]
            dy = [0, 0, 1, -1]
            if map[x][y] == 0
                4.times do |i|
                    newx = x + dx[i]
                    newy = y + dy[i]
                    next if newx < 0 || newx >= 10
                    next if newy < 0 || newy >= 10
                    uni.unite(y + x * 10, newy + newx * 10) if map[newx][newy] == 0
                end
            end
        end
    end

    # チェック用
    query = [[1, 1, 2, 4], [1, 8, 4, 7], [1, 6, 8, 6], [1, 1, 8, 1]]
    q = 0

    # 0:チェック, 1:色分け
    status = 0

    Window.loop do
        case status
        when 0
            draw_map(map)
            xa, ya, xb, yb = query[q]
            Window.draw(ya * 20, xa * 20, red)
            Window.draw(yb * 20, xb * 20, red)
            if map[xa][ya] == 0 && map[xb][yb] == 0 && uni.same?(ya + xa * 10, yb + xb * 10)
                Window.draw_font(10, 200, "Yes", font)
            else
                Window.draw_font(10, 200, "No", font)
            end
            q += 1
            status += 1 if q >= 4
        when 1
            sleep(1)
            draw_color(map, uni)
            draw_map(map)
            Window.draw_font(10, 200, "グループ分け", font)
        end
        sleep(1)
    end
end

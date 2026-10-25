"""把本目录的 *.svg 渲染成同名 2 倍 PNG（推广文章要上传图片文件，平台不收 SVG）。
用法：python3 docs/promo/img/render.py [文件名.svg ...]   不给参数就全部渲染。需要 Google Chrome。"""
import glob, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# 和 docs/demo/make_panel_png.py 一样：固定的配置目录，起之前确认禁止下载本地 AI 模型的策略在
if subprocess.run(["defaults", "read", "com.google.Chrome", "GenAILocalFoundationalModelSettings"],
                  capture_output=True, text=True).stdout.strip() != "1":
    raise SystemExit("先设 Chrome 策略：defaults write com.google.Chrome GenAILocalFoundationalModelSettings -int 1")
PROFILE = os.path.join(os.environ.get("TMPDIR", "/tmp"), "claude-tmux-render-chrome")
os.makedirs(PROFILE, exist_ok=True)

files = [os.path.join(HERE, f) for f in sys.argv[1:]] or sorted(glob.glob(os.path.join(HERE, "*.svg")))
for svg in files:
    head = open(svg, encoding="utf-8").read(400)
    size = re.search(r'width="(\d+)" height="(\d+)"', head)
    if not size: raise SystemExit(f"{svg}: <svg> 开头要写 width=\"…\" height=\"…\"")
    w, h = int(size.group(1)), int(size.group(2))
    out = svg[:-4] + ".png"
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", f"--user-data-dir={PROFILE}", "--hide-scrollbars",
                    "--force-device-scale-factor=2", f"--window-size={w},{h}", "--virtual-time-budget=1000",
                    f"--screenshot={out}", "file://" + svg], check=True, stderr=subprocess.DEVNULL)
    print(out)

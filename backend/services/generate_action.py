
from PIL import Image, ImageDraw
from io import BytesIO

def generate_action_image(image,size=(500, 500), color="red", bg_color="white"):
    """
    生成一張愛心圖片
    """
    print(f"size: {size}, type: {type(size)}")
    print(f"bg_color: {bg_color}, type: {type(bg_color)}")
    img = Image.new("RGB", size, bg_color)
    draw = ImageDraw.Draw(img)

    # 愛心形狀 (兩個圓 + 三角形)
    w, h = size
    radius = w // 4

    # 左圓
    draw.ellipse(
        [(w//2 - radius*2, h//4 - radius), (w//2, h//4 + radius)],
        fill=color
    )

    # 右圓
    draw.ellipse(
        [(w//2, h//4 - radius), (w//2 + radius*2, h//4 + radius)],
        fill=color
    )

    # 底部三角形
    draw.polygon(
        [(w//2 - radius*2, h//4 + radius//2),
         (w//2 + radius*2, h//4 + radius//2),
         (w//2, h)],
        fill=color
    )

    buf = BytesIO()
    img.save(buf, format="JPEG")
    buf.seek(0)
    return buf
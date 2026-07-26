from PIL import Image

input_path = "/Users/azimabdulla/StudioProjects/Gemini_Generated_Image_zfgfv1zfgfv1zfgf.png"
img = Image.open(input_path).convert("RGBA")

# 1. Standard Launcher Icon (1024x1024 with 10% safe margin)
canvas_size = 1024
padded_img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))

# Resize original image to fit within 82% of the canvas size
target_size = int(canvas_size * 0.82)
resized_img = img.resize((target_size, target_size), Image.LANCZOS)

offset = (canvas_size - target_size) // 2
padded_img.paste(resized_img, (offset, offset), resized_img)
padded_img.save("assets/icon/app_icon.png")

# 2. Android Adaptive Icon Foreground (1024x1024 with Android 66% safe zone)
adaptive_canvas = 1024
adaptive_img = Image.new("RGBA", (adaptive_canvas, adaptive_canvas), (0, 0, 0, 0))

safe_target = int(adaptive_canvas * 0.68)
resized_safe = img.resize((safe_target, safe_target), Image.LANCZOS)
safe_offset = (adaptive_canvas - safe_target) // 2

adaptive_img.paste(resized_safe, (safe_offset, safe_offset), resized_safe)
adaptive_img.save("assets/icon/adaptive_foreground.png")

print("App icons formatted successfully!")

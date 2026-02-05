
import os
import shutil
import json
import glob
from PIL import Image

# Configuration
ASSETS_PATH = "/Users/blargou/Desktop/removebgpro/removebgpro/Assets.xcassets"
ARTIFACTS_PATH = "/Users/blargou/.gemini/antigravity/brain/8a478e64-a799-43f5-8ef4-eb0613226b07"
STICKER_NAMES = [
    "sticker_cool_text",
    "sticker_fire_flame",
    "sticker_pixel_heart",
    "sticker_wow_bubble",
    "sticker_omg_text",
    "sticker_100_score"
]

def make_transparent(img):
    datas = img.getdata()
    newData = []
    for item in datas:
        # Check if pixel is near white (adjust tolerance as needed)
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            newData.append((255, 255, 255, 0)) # Transparent
        else:
            newData.append(item)
    img.putdata(newData)
    return img

def import_sticker(name):
    print(f"Processing {name}...")
    
    # 1. Find the artifact file
    pattern = os.path.join(ARTIFACTS_PATH, f"{name}*.png")
    matches = glob.glob(pattern)
    
    if not matches:
        print(f"Error: Could not find generated image for {name}")
        return
        
    source_file = matches[0] # Take the first match
    
    # 2. Open and Process Image
    try:
        img = Image.open(source_file)
        img = img.convert("RGBA")
        img = make_transparent(img)
        
        # 3. Create Destination Directory
        dest_dir = os.path.join(ASSETS_PATH, f"{name}.imageset")
        if os.path.exists(dest_dir):
            shutil.rmtree(dest_dir)
        os.makedirs(dest_dir)
        
        # 4. Save Processed Image
        dest_file = os.path.join(dest_dir, f"{name}.png")
        img.save(dest_file, "PNG")
        
        # 5. Create Contents.json
        contents = {
            "images": [
                {
                    "filename": f"{name}.png",
                    "idiom": "universal",
                    "scale": "1x"
                },
                 {
                    "idiom": "universal",
                    "scale": "2x"
                },
                 {
                    "idiom": "universal",
                    "scale": "3x"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
        
        with open(os.path.join(dest_dir, "Contents.json"), "w") as f:
            json.dump(contents, f, indent=4)
            
        print(f"Successfully imported and processed {name}")
        
    except Exception as e:
        print(f"Failed to process {name}: {e}")

# Main execution
if __name__ == "__main__":
    if not os.path.exists(ASSETS_PATH):
        print(f"Error: Assets path not found at {ASSETS_PATH}")
    else:
        for name in STICKER_NAMES:
            import_sticker(name)
        print("Done.")

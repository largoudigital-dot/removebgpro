
import os
import shutil
import json
import glob

# Configuration
ASSETS_PATH = "/Users/blargou/Desktop/removebgpro/removebgpro/Assets.xcassets"
ARTIFACTS_PATH = "/Users/blargou/.gemini/antigravity/brain/8a478e64-a799-43f5-8ef4-eb0613226b07"
STICKER_NAMES = [
    "sticker_cool_text",
    "sticker_fire_flame",
    "sticker_pixel_heart",
    "sticker_wow_bubble"
]

def import_sticker(name):
    print(f"Importing {name}...")
    
    # 1. Find the artifact file (generated with timestamp suffix)
    pattern = os.path.join(ARTIFACTS_PATH, f"{name}*.png")
    matches = glob.glob(pattern)
    
    if not matches:
        print(f"Error: Could not find generated image for {name}")
        return
        
    source_file = matches[0] # Take the first match
    
    # 2. Create Destination Directory
    dest_dir = os.path.join(ASSETS_PATH, f"{name}.imageset")
    if os.path.exists(dest_dir):
        shutil.rmtree(dest_dir) # Clean replace
    os.makedirs(dest_dir)
    
    # 3. Copy Image
    dest_file = os.path.join(dest_dir, f"{name}.png")
    shutil.copy2(source_file, dest_file)
    
    # 4. Create Contents.json
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
        
    print(f"Successfully imported {name}")

# Main execution
if __name__ == "__main__":
    if not os.path.exists(ASSETS_PATH):
        print(f"Error: Assets path not found at {ASSETS_PATH}")
    else:
        for name in STICKER_NAMES:
            import_sticker(name)
        print("Done.")

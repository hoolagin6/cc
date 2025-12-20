import cv2
import numpy as np
import sys
import os
import glob

# --- Default Settings ---
DEFAULT_W = 57 
DEFAULT_H = 67
FRAME_SKIP = 2
GAMMA_CORRECTION = 1.2 

# --- Palette Setup ---
PALETTE_RGB = np.array([
    [240, 240, 240], [242, 178, 51],  [229, 127, 216], [153, 178, 242],
    [222, 222, 108], [127, 204, 25],  [242, 178, 204], [76,  76,  76],
    [153, 153, 153], [76,  153, 178], [178, 102, 229], [51,  102, 204],
    [127, 102, 76],  [87,  166, 78],  [204, 76,  76],  [25,  25,  25]
])
PALETTE_HEX = "0123456789abcdef"

def get_closest_color_index(pixel):
    distances = np.sum((PALETTE_RGB - pixel) ** 2, axis=1)
    return np.argmin(distances)

def calculate_resolution(w_blocks, h_blocks):
    # Width increments: 21, 21, 22, 21, 21, 22, 21...
    w_inc = [21, 21, 22, 21, 21, 22, 21]
    target_w = 15
    for i in range(min(w_blocks - 1, len(w_inc))):
        target_w += w_inc[i]
    if w_blocks > 8: target_w += (w_blocks - 8) * 21
        
    # Height increments: 14, 14, 14, 15, 14...
    h_inc = [14, 14, 14, 15, 14]
    target_h = 10
    for i in range(min(h_blocks - 1, len(h_inc))):
        target_h += h_inc[i]
    if h_blocks > 6: target_h += (h_blocks - 6) * 14
        
    return target_w, target_h

def convert_video(input_file, target_w, target_h):
    base_name = os.path.splitext(input_file)[0]
    output_file = base_name + ".vid"
    
    print(f"Converting '{input_file}' ({target_w}x{target_h})...")
    
    cap = cv2.VideoCapture(input_file)
    if not cap.isOpened():
        print(f"Error opening video stream for {input_file}.")
        return

    with open(output_file, "w") as f:
        f.write(f"{target_w},{target_h}\n")
        
        frame_count = 0
        frames_written = 0

        while True:
            ret, frame = cap.read()
            if not ret: break

            if frame_count % FRAME_SKIP == 0:
                resized = cv2.resize(frame, (target_w, target_h), interpolation=cv2.INTER_AREA)
                resized = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)

                if GAMMA_CORRECTION != 1.0:
                    invGamma = 1.0 / GAMMA_CORRECTION
                    table = np.array([((i / 255.0) ** invGamma) * 255
                        for i in np.arange(0, 256)]).astype("uint8")
                    resized = cv2.LUT(resized, table)

                f_img = resized.astype(float)
                
                for y in range(target_h):
                    line_hex = ""
                    for x in range(target_w):
                        old_pixel = f_img[y, x].copy()
                        idx = get_closest_color_index(old_pixel)
                        new_pixel = PALETTE_RGB[idx]
                        line_hex += PALETTE_HEX[idx]
                        
                        quant_error = old_pixel - new_pixel
                        if x + 1 < target_w:
                            f_img[y, x + 1] += quant_error * 7 / 16
                        if x - 1 >= 0 and y + 1 < target_h:
                            f_img[y + 1, x - 1] += quant_error * 3 / 16
                        if y + 1 < target_h:
                            f_img[y + 1, x] += quant_error * 5 / 16
                        if x + 1 < target_w and y + 1 < target_h:
                            f_img[y + 1, x + 1] += quant_error * 1 / 16
                    
                    f.write(line_hex + "\n")
                
                frames_written += 1
                if frames_written % 10 == 0:
                    sys.stdout.write(f"\r  Frames written: {frames_written}")
                    sys.stdout.flush()

            frame_count += 1
            
    cap.release()
    print(f"\nFinished '{output_file}'.")

def main():
    print("--- Bulk Video Converter ---")
    
    mp4_files = glob.glob("*.mp4")
    if not mp4_files:
        print("No .mp4 files found.")
        return

    # Prompt for blocks
    try:
        bw = int(input("Monitor Width in BLOCKS (e.g. 3): ") or 1)
        bh = int(input("Monitor Height in BLOCKS (e.g. 1): ") or 1)
        tw, th = calculate_resolution(bw, bh)
        print(f"Calculated Resolution: {tw}x{th}")
    except ValueError:
        print("Invalid input. Using 1x1 default.")
        tw, th = 15, 10

    for mp4 in mp4_files:
        convert_video(mp4, tw, th)
        
    print("\nAll done!")

if __name__ == "__main__":
    main()
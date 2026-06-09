import os
import shutil

# Root directories that contain base subfolders
BASE_ASSET_DIRS = [
    "assets/preload",
    "assets/shared",
    "assets/impostor",
    "assets/exclude",
    "assets/secrets"  # Added secrets folder here
]

# Root directories that contain custom mod/modpack subfolders
MOD_ROOT_DIRS = [
    "example_mods",
    "example_modpack"
]

def get_all_target_directories():
    targets = []
    
    # 1. Add standard asset paths if they exist
    for folder in BASE_ASSET_DIRS:
        if os.path.exists(folder):
            targets.append(folder)
            
    # 2. Automatically find week folders inside 'assets' (week2, week3, etc.)
    if os.path.exists("assets"):
        for item in os.listdir("assets"):
            item_path = os.path.join("assets", item)
            if os.path.isdir(item_path) and item.lower().startswith("week"):
                targets.append(item_path)
            
    # 3. Automatically find all individual mod folders (Paul, mr Dweller, silly singles, etc.)
    for mod_root in MOD_ROOT_DIRS:
        if os.path.exists(mod_root):
            for item in os.listdir(mod_root):
                item_path = os.path.join(mod_root, item)
                if os.path.isdir(item_path):
                    targets.append(item_path)
                    
    return targets

def sort_folder(base_path):
    # Check if a generic 'images' folder exists first
    png_dir = os.path.join(base_path, "images")
    
    # If generic 'images' doesn't exist, check for the pre-existing 'images-png' folder
    if not os.path.exists(png_dir):
        png_dir = os.path.join(base_path, "images-png")
        if not os.path.exists(png_dir):
            print(f"Skipping {base_path}: No images or images-png folder found.")
            return None

    astc_dir = os.path.join(base_path, "images-astc")

    # --- PRE-SCAN FOR ASTC FILES ---
    # Look through the source folder first. If zero .astc files exist, completely skip.
    has_astc = False
    for root, dirs, files in os.walk(png_dir):
        if any(file.endswith(".astc") for file in files):
            has_astc = True
            break

    if not has_astc:
        print(f"Skipping {base_path}: No .astc files found in source folder.")
        # Fallback rename check for consistency even if skipped
        if png_dir == os.path.join(base_path, "images"):
            os.rename(png_dir, os.path.join(base_path, "images-png"))
        return None

    # Clean up old temp folders safely if they linger
    old_temp = os.path.join(base_path, "images-astc_TEMP")
    if os.path.exists(old_temp):
        shutil.rmtree(old_temp)

    # Safely create target directory without wiping any old files out
    os.makedirs(astc_dir, exist_ok=True)

    print(f"Scanning and sorting files from {png_dir}...")

    # Dynamic counters for this specific folder
    folder_counts = {"png": 0, "astc": 0, "metadata_other": 0}

    # Scan through your source png directory
    for root, dirs, files in os.walk(png_dir):
        for file in files:
            file_path = os.path.join(root, file)
            rel_path = os.path.relpath(file_path, png_dir)
            dest = os.path.join(astc_dir, rel_path)
            
            # 1. Move ASTC files directly into the final images-astc folder if it doesn't exist yet
            if file.endswith(".astc"):
                if os.path.exists(dest):
                    folder_counts["astc"] += 1
                    continue
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.move(file_path, dest)
                folder_counts["astc"] += 1
                
            # 2. Leave PNGs exactly where they are
            elif file.endswith(".png"):
                folder_counts["png"] += 1
                
            # 3. Copy EVERYTHING ELSE (json, xml, txt, etc.) if it doesn't already exist in target
            else:
                if os.path.exists(dest):
                    folder_counts["metadata_other"] += 1
                    continue
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.copy2(file_path, dest)
                folder_counts["metadata_other"] += 1

    # Force change generic 'images' folders to 'images-png' to match your Project.xml layout rules
    if png_dir == os.path.join(base_path, "images"):
        os.rename(png_dir, os.path.join(base_path, "images-png"))
    
    total_folder_files = sum(folder_counts.values())
    print(f" -> Done with {base_path}! Processed {total_folder_files} files.\n")
    
    return folder_counts

if __name__ == "__main__":
    total_counts = {"png": 0, "astc": 0, "metadata_other": 0}
    folders_processed = 0

    print("=========================================")
    print("   ASTC EXTRACTION (SAFE SKIP VERSION)   ")
    print("=========================================\n")

    # Get the complete list of target paths automatically
    TARGET_DIRS = get_all_target_directories()

    for folder in TARGET_DIRS:
        if os.path.exists(folder):
            counts = sort_folder(folder)
            if counts:
                folders_processed += 1
                total_counts["png"] += counts["png"]
                total_counts["astc"] += counts["astc"]
                total_counts["metadata_other"] += counts["metadata_other"]
                
    grand_total = sum(total_counts.values())

    print("=========================================")
    print("      FINAL SUMMARY BREAKDOWN            ")
    print("=========================================")
    print(f"Folders organized:     {folders_processed}")
    print(f"PNG files preserved:   {total_counts['png']}")
    print(f"ASTC files extracted:  {total_counts['astc']}")
    print(f"Metadata files copied: {total_counts['metadata_other']}")
    print("-----------------------------------------")
    print("Process complete! Ready for your compiler build.")
    print("=========================================")
    print("\n" + "="*41)
    input("Press ENTER to close this window...")
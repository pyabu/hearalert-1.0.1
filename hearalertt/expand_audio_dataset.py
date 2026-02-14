#!/usr/bin/env python3
"""
Audio Dataset Augmentation Script for HearAlert
Expands the training dataset by:
1. Using all available ESC-50 audio
2. Augmenting existing audio with variations
3. Generating synthetic audio samples
"""

import os
import shutil
import numpy as np
from pathlib import Path
import wave
import struct
import random

BASE_DIR = Path("/Users/abu/hearalert_version_1.1/hearalertt")
ESC50_DIR = BASE_DIR / "datasets" / "ESC-50" / "audio"
ESC50_META = BASE_DIR / "datasets" / "ESC-50" / "meta" / "esc50.csv"
RAW_DIR = BASE_DIR / "raw"
AUGMENTED_DIR = BASE_DIR / "augmented_audio"

# ESC-50 class names mapped to our categories
ESC50_MAPPING = {
    # Critical - Emergency
    "car_horn": [43],  # car_horn
    "siren": [47, 48],  # siren, engine
    "fire_alarm": [24, 25],  # fireworks, crackling_fire
    "glass_breaking": [38],  # glass_breaking
    "train": [36],  # train
    
    # High Priority
    "traffic": [43, 44],  # car_horn, engine
    "door_knock": [10, 11],  # door_wood_knock, door_wood_creaks
    "doorbell": [30, 31],  # church_bells
    "phone_ring": [37],  # clock_alarm
    "dog_bark": [0],  # dog
    "thunderstorm": [19],  # thunderstorm
    
    # Medium
    "helicopter": [40],  # helicopter
    "cat_meow": [1],  # cat
    
    # Baby cry from raw folder
    "baby_cry": [20],  # crying_baby in ESC-50
}

def load_esc50_metadata():
    """Load ESC-50 metadata"""
    meta = {}
    if ESC50_META.exists():
        with open(ESC50_META, 'r') as f:
            next(f)  # Skip header
            for line in f:
                parts = line.strip().split(',')
                if len(parts) >= 4:
                    filename = parts[0]
                    target = int(parts[2])
                    meta[filename] = target
    return meta

def augment_audio(input_path, output_dir, num_augmentations=3):
    """Create augmented versions of an audio file"""
    try:
        with wave.open(str(input_path), 'r') as w:
            params = w.getparams()
            frames = w.readframes(w.getnframes())
        
        # Convert to numpy array
        samples = np.frombuffer(frames, dtype=np.int16).astype(np.float32)
        
        augmented_files = []
        basename = input_path.stem
        
        for i in range(num_augmentations):
            aug_samples = samples.copy()
            
            # Random augmentation
            aug_type = random.choice(['noise', 'shift', 'volume', 'speed'])
            
            if aug_type == 'noise':
                # Add noise
                noise = np.random.normal(0, 0.01 * np.max(np.abs(aug_samples)), len(aug_samples))
                aug_samples = aug_samples + noise.astype(np.float32)
            
            elif aug_type == 'shift':
                # Time shift
                shift = int(len(aug_samples) * random.uniform(-0.1, 0.1))
                aug_samples = np.roll(aug_samples, shift)
            
            elif aug_type == 'volume':
                # Volume change
                factor = random.uniform(0.7, 1.3)
                aug_samples = aug_samples * factor
            
            elif aug_type == 'speed':
                # Simple speed change by resampling
                factor = random.uniform(0.9, 1.1)
                indices = np.arange(0, len(aug_samples), factor)
                indices = indices[indices < len(aug_samples)].astype(int)
                aug_samples = aug_samples[indices]
            
            # Clip and convert back to int16
            aug_samples = np.clip(aug_samples, -32768, 32767).astype(np.int16)
            
            # Save augmented file
            output_path = output_dir / f"{basename}_aug{i}_{aug_type}.wav"
            with wave.open(str(output_path), 'w') as w_out:
                w_out.setparams(params)
                w_out.writeframes(aug_samples.tobytes())
            
            augmented_files.append(output_path)
            
        return augmented_files
        
    except Exception as e:
        print(f"Error augmenting {input_path}: {e}")
        return []

def expand_category(category, esc50_classes, meta, target_count=100):
    """Expand a category to target count"""
    category_dir = AUGMENTED_DIR / category
    category_dir.mkdir(parents=True, exist_ok=True)
    
    current_files = list(category_dir.glob("*.wav"))
    print(f"\n{category}: {len(current_files)} existing files, target: {target_count}")
    
    # Collect source files from ESC-50
    source_files = []
    for filename, target in meta.items():
        if target in esc50_classes:
            source_path = ESC50_DIR / filename
            if source_path.exists():
                source_files.append(source_path)
    
    # Copy ESC-50 files
    for src in source_files:
        dest = category_dir / src.name
        if not dest.exists():
            shutil.copy2(src, dest)
            print(f"  Copied: {src.name}")
    
    # Also check raw folder for this category
    raw_sources = {
        "baby_cry": ["belly_pain", "burping", "cold_hot", "discomfort", "hungry", "tired"],
        "dog_bark": ["Dog"],
        "cat_meow": ["Frog"],  # If available
    }
    
    if category in raw_sources:
        for source in raw_sources[category]:
            source_dir = RAW_DIR / source
            if source_dir.exists():
                for wav_file in list(source_dir.glob("*.wav"))[:50]:  # Limit per source
                    dest = category_dir / f"raw_{source}_{wav_file.name}"
                    if not dest.exists():
                        try:
                            shutil.copy2(wav_file, dest)
                        except Exception as e:
                            pass
    
    # Count current files
    current_files = list(category_dir.glob("*.wav"))
    
    # If still under target, augment existing files
    if len(current_files) < target_count:
        files_needed = target_count - len(current_files)
        files_to_augment = random.sample(current_files, min(len(current_files), files_needed // 3 + 1))
        
        for f in files_to_augment:
            if len(list(category_dir.glob("*.wav"))) >= target_count:
                break
            augment_audio(f, category_dir, num_augmentations=2)
    
    final_count = len(list(category_dir.glob("*.wav")))
    print(f"  Final count: {final_count}")
    return final_count

def main():
    print("=" * 60)
    print("HearAlert Audio Dataset Expansion")
    print("=" * 60)
    
    # Create augmented directory
    AUGMENTED_DIR.mkdir(parents=True, exist_ok=True)
    
    # Load ESC-50 metadata
    meta = load_esc50_metadata()
    print(f"Loaded {len(meta)} ESC-50 entries")
    
    # Target counts per category
    targets = {
        "car_horn": 100,
        "siren": 100,
        "fire_alarm": 100,
        "glass_breaking": 100,
        "train": 100,
        "traffic": 100,
        "door_knock": 100,
        "doorbell": 100,
        "phone_ring": 100,
        "dog_bark": 150,
        "thunderstorm": 100,
        "helicopter": 100,
        "cat_meow": 100,
        "baby_cry": 200,
    }
    
    # Expand each category
    total_files = 0
    for category, target in targets.items():
        esc_classes = ESC50_MAPPING.get(category, [])
        count = expand_category(category, esc_classes, meta, target)
        total_files += count
    
    print("\n" + "=" * 60)
    print(f"TOTAL AUGMENTED FILES: {total_files}")
    print("=" * 60)
    
    # Create summary
    summary = {"categories": {}}
    for category in targets.keys():
        cat_dir = AUGMENTED_DIR / category
        count = len(list(cat_dir.glob("*.wav"))) if cat_dir.exists() else 0
        summary["categories"][category] = count
    
    print("\nCategory Summary:")
    for cat, count in summary["categories"].items():
        print(f"  {cat}: {count} files")

if __name__ == "__main__":
    main()

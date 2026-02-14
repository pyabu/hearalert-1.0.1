#!/usr/bin/env python3
"""
Advanced Audio Dataset Expansion for HearAlert
Generates more audio samples through advanced augmentation for real-time deaf accessibility.
"""

import os
import numpy as np
from pathlib import Path
import wave
import struct
import random

BASE_DIR = Path("/Users/abu/hearalert_version_1.1/hearalertt")
COMBINED_DIR = BASE_DIR / "combined_audio"
EXPANDED_DIR = BASE_DIR / "expanded_audio"

# Target counts per category for better balance
TARGET_COUNTS = {
    "baby_cry": 400,
    "car_horn": 150,
    "traffic": 150,
    "train": 150,
    "siren": 150,
    "fire_alarm": 150,
    "glass_breaking": 150,
    "door_knock": 150,
    "doorbell": 150,
    "phone_ring": 150,
    "dog_bark": 200,
    "cat_meow": 150,
    "helicopter": 150,
    "thunderstorm": 150,
}

def read_wav(path):
    """Read WAV file and return samples."""
    try:
        with wave.open(str(path), 'r') as w:
            params = w.getparams()
            frames = w.readframes(w.getnframes())
            samples = np.frombuffer(frames, dtype=np.int16).astype(np.float32)
            return samples, params
    except:
        return None, None

def write_wav(path, samples, params):
    """Write samples to WAV file."""
    try:
        samples = np.clip(samples, -32768, 32767).astype(np.int16)
        with wave.open(str(path), 'w') as w:
            w.setparams(params)
            w.writeframes(samples.tobytes())
        return True
    except:
        return False

def augment_audio(samples, aug_type):
    """Apply augmentation to audio samples."""
    if aug_type == 'noise':
        noise = np.random.normal(0, 50, len(samples))
        return samples + noise.astype(np.float32)
    
    elif aug_type == 'loud_noise':
        noise = np.random.normal(0, 100, len(samples))
        return samples + noise.astype(np.float32)
    
    elif aug_type == 'volume_up':
        return samples * 1.3
    
    elif aug_type == 'volume_down':
        return samples * 0.7
    
    elif aug_type == 'shift_left':
        shift = int(len(samples) * 0.1)
        return np.roll(samples, -shift)
    
    elif aug_type == 'shift_right':
        shift = int(len(samples) * 0.1)
        return np.roll(samples, shift)
    
    elif aug_type == 'reverse':
        return samples[::-1].copy()
    
    elif aug_type == 'fade_in':
        fade = np.linspace(0, 1, len(samples) // 4)
        result = samples.copy()
        result[:len(fade)] *= fade
        return result
    
    elif aug_type == 'fade_out':
        fade = np.linspace(1, 0, len(samples) // 4)
        result = samples.copy()
        result[-len(fade):] *= fade
        return result
    
    elif aug_type == 'compress':
        # Dynamic range compression
        threshold = 10000
        ratio = 0.5
        result = samples.copy()
        mask = np.abs(result) > threshold
        result[mask] = np.sign(result[mask]) * (threshold + (np.abs(result[mask]) - threshold) * ratio)
        return result
    
    return samples

def expand_category(category, target_count):
    """Expand a category to target count."""
    category_files = list(COMBINED_DIR.glob(f"{category}_*.wav"))
    current_count = len(category_files)
    
    if current_count == 0:
        print(f"  {category}: No source files found!")
        return 0
    
    # Create output directory
    cat_dir = EXPANDED_DIR / category
    cat_dir.mkdir(parents=True, exist_ok=True)
    
    # Copy existing files
    for f in category_files:
        dest = cat_dir / f.name
        if not dest.exists():
            samples, params = read_wav(f)
            if samples is not None:
                write_wav(dest, samples, params)
    
    # Count current files
    current = len(list(cat_dir.glob("*.wav")))
    
    # Generate augmented versions if needed
    augmentations = ['noise', 'loud_noise', 'volume_up', 'volume_down', 
                     'shift_left', 'shift_right', 'fade_in', 'fade_out', 'compress']
    
    while current < target_count and category_files:
        # Pick random source file
        src_file = random.choice(category_files)
        samples, params = read_wav(src_file)
        
        if samples is None:
            continue
        
        # Apply random augmentation
        aug_type = random.choice(augmentations)
        aug_samples = augment_audio(samples, aug_type)
        
        # Generate unique filename
        idx = current
        output_path = cat_dir / f"{category}_aug_{idx:04d}_{aug_type}.wav"
        
        if write_wav(output_path, aug_samples, params):
            current += 1
        
        if current >= target_count:
            break
    
    final_count = len(list(cat_dir.glob("*.wav")))
    print(f"  {category}: {final_count} files (target: {target_count})")
    return final_count

def main():
    print("=" * 60)
    print("HearAlert Advanced Audio Dataset Expansion")
    print("=" * 60)
    
    EXPANDED_DIR.mkdir(parents=True, exist_ok=True)
    
    total_files = 0
    print("\nExpanding categories:")
    
    for category, target in TARGET_COUNTS.items():
        count = expand_category(category, target)
        total_files += count
    
    print("\n" + "=" * 60)
    print(f"TOTAL EXPANDED FILES: {total_files}")
    print("=" * 60)
    
    # Create summary
    print("\nCategory Summary:")
    for category in TARGET_COUNTS.keys():
        cat_dir = EXPANDED_DIR / category
        count = len(list(cat_dir.glob("*.wav"))) if cat_dir.exists() else 0
        print(f"  {category}: {count} files")

if __name__ == "__main__":
    main()

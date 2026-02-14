#!/usr/bin/env python3
"""
Download and Generate More Audio for HearAlert
Additional sound categories for deaf accessibility
"""

import os
import numpy as np
import wave
import struct
from pathlib import Path
import random

BASE_DIR = Path("/Users/abu/hearalert_version_1.1/hearalertt")
COMBINED_DIR = BASE_DIR / "combined_audio"
NEW_AUDIO_DIR = BASE_DIR / "new_audio"

# Additional categories to add
NEW_CATEGORIES = {
    "smoke_alarm": {"priority": 10, "alert_type": "critical"},
    "water_running": {"priority": 6, "alert_type": "medium"},
    "microwave_beep": {"priority": 7, "alert_type": "high"},
    "alarm_clock": {"priority": 8, "alert_type": "high"},
    "knock_knock": {"priority": 8, "alert_type": "high"},
    "car_alarm": {"priority": 9, "alert_type": "critical"},
}

def generate_synthetic_audio(frequency, duration_sec=5, sample_rate=44100, noise_level=0.1):
    """Generate synthetic audio with a base frequency and harmonics."""
    t = np.linspace(0, duration_sec, int(sample_rate * duration_sec))
    
    # Base signal
    signal = np.sin(2 * np.pi * frequency * t)
    
    # Add harmonics
    signal += 0.5 * np.sin(2 * np.pi * frequency * 2 * t)
    signal += 0.25 * np.sin(2 * np.pi * frequency * 3 * t)
    
    # Add some noise
    noise = np.random.normal(0, noise_level, len(signal))
    signal = signal + noise
    
    # Normalize
    signal = signal / np.max(np.abs(signal))
    
    # Convert to 16-bit PCM
    samples = (signal * 32767).astype(np.int16)
    
    return samples, sample_rate

def generate_alarm_pattern(base_freq, pattern_type, duration_sec=5, sample_rate=44100):
    """Generate alarm-like patterns."""
    t = np.linspace(0, duration_sec, int(sample_rate * duration_sec))
    samples_per_cycle = sample_rate // 4  # 250ms cycles
    
    signal = np.zeros_like(t)
    
    if pattern_type == "smoke_alarm":
        # High-pitched beeping pattern
        for i in range(len(t)):
            cycle_pos = (i % samples_per_cycle) / samples_per_cycle
            if cycle_pos < 0.5:
                signal[i] = np.sin(2 * np.pi * 3000 * t[i])
            else:
                signal[i] = 0
                
    elif pattern_type == "car_alarm":
        # Alternating frequencies
        for i in range(len(t)):
            cycle = (i // (sample_rate // 2)) % 4
            if cycle == 0:
                signal[i] = np.sin(2 * np.pi * 800 * t[i])
            elif cycle == 1:
                signal[i] = np.sin(2 * np.pi * 1200 * t[i])
            elif cycle == 2:
                signal[i] = np.sin(2 * np.pi * 600 * t[i])
            else:
                signal[i] = np.sin(2 * np.pi * 1000 * t[i])
                
    elif pattern_type == "microwave_beep":
        # Series of beeps
        for i in range(len(t)):
            cycle_pos = (i % (sample_rate // 2)) / (sample_rate // 2)
            if cycle_pos < 0.1:
                signal[i] = np.sin(2 * np.pi * 2500 * t[i])
            else:
                signal[i] = 0
                
    elif pattern_type == "alarm_clock":
        # Classic alarm clock ring
        for i in range(len(t)):
            cycle_pos = (i % (sample_rate // 3)) / (sample_rate // 3)
            if cycle_pos < 0.7:
                freq = 1500 + 500 * np.sin(2 * np.pi * 10 * t[i])
                signal[i] = np.sin(2 * np.pi * freq * t[i])
            else:
                signal[i] = 0
                
    elif pattern_type == "water_running":
        # White noise with filtering
        signal = np.random.normal(0, 1, len(t))
        # Simple low-pass approximation
        for i in range(1, len(signal)):
            signal[i] = 0.95 * signal[i-1] + 0.05 * signal[i]
            
    elif pattern_type == "knock_knock":
        # Impact sounds
        for knock in range(6):
            start = knock * sample_rate // 2
            if start < len(signal):
                for i in range(min(sample_rate // 10, len(signal) - start)):
                    decay = np.exp(-i / (sample_rate / 30))
                    signal[start + i] = decay * np.sin(2 * np.pi * 200 * i / sample_rate)
    
    # Add noise and normalize
    noise = np.random.normal(0, 0.05, len(signal))
    signal = signal + noise
    signal = signal / (np.max(np.abs(signal)) + 0.001)
    
    return (signal * 32767).astype(np.int16), sample_rate

def save_wav(samples, sample_rate, filepath):
    """Save samples as WAV file."""
    with wave.open(str(filepath), 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        w.writeframes(samples.tobytes())

def augment_samples(samples, aug_type):
    """Apply augmentation to samples."""
    if aug_type == "noise":
        noise = np.random.normal(0, 100, len(samples))
        return np.clip(samples.astype(float) + noise, -32768, 32767).astype(np.int16)
    elif aug_type == "volume_up":
        return np.clip(samples.astype(float) * 1.2, -32768, 32767).astype(np.int16)
    elif aug_type == "volume_down":
        return (samples.astype(float) * 0.8).astype(np.int16)
    elif aug_type == "shift":
        shift = len(samples) // 10
        return np.roll(samples, shift)
    return samples

def main():
    print("=" * 60)
    print("Generating New Audio Categories for HearAlert")
    print("=" * 60)
    
    NEW_AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    
    total_files = 0
    
    for category, config in NEW_CATEGORIES.items():
        cat_dir = NEW_AUDIO_DIR / category
        cat_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"\nGenerating {category}...")
        
        # Generate 50 variations
        for i in range(50):
            # Generate base pattern
            samples, sr = generate_alarm_pattern(800, category)
            
            # Save original
            save_wav(samples, sr, cat_dir / f"{category}_{i:03d}.wav")
            total_files += 1
            
            # Create augmented versions
            for aug_type in ["noise", "volume_up", "volume_down"]:
                aug_samples = augment_samples(samples, aug_type)
                save_wav(aug_samples, sr, cat_dir / f"{category}_{i:03d}_{aug_type}.wav")
                total_files += 1
        
        count = len(list(cat_dir.glob("*.wav")))
        print(f"  {category}: {count} files")
    
    # Also copy to combined_audio
    print("\nCopying to combined_audio...")
    COMBINED_DIR.mkdir(parents=True, exist_ok=True)
    
    import shutil
    for category in NEW_CATEGORIES.keys():
        cat_dir = NEW_AUDIO_DIR / category
        for f in cat_dir.glob("*.wav"):
            dest = COMBINED_DIR / f"{category}_{f.name}"
            if not dest.exists():
                shutil.copy2(f, dest)
    
    print("\n" + "=" * 60)
    print(f"TOTAL NEW FILES GENERATED: {total_files}")
    print("=" * 60)
    
    # Final summary
    print("\nNew Categories Added:")
    for cat, config in NEW_CATEGORIES.items():
        count = len(list((NEW_AUDIO_DIR / cat).glob("*.wav")))
        print(f"  {cat}: {count} files (Priority: {config['priority']})")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Advanced Audio Augmentation Pipeline for HearAlert
===================================================
Professional-grade audio augmentation for AI/ML training.
Implements multiple augmentation techniques for robust model training.
"""

import os
import numpy as np
import wave
import struct
from pathlib import Path
import random
import shutil
import csv
from concurrent.futures import ThreadPoolExecutor, as_completed

BASE_DIR = Path(__file__).parent
DATASETS_DIR = BASE_DIR / "datasets"
ESC50_DIR = DATASETS_DIR / "ESC-50"
TRAINING_DATA_DIR = BASE_DIR / "training_data"
AUGMENTED_DIR = BASE_DIR / "augmented_audio"

# ESC-50 classes used for training
ESC50_CLASSES = {
    "dog": 0, "rooster": 1, "pig": 2, "cow": 3, "frog": 4,
    "cat": 5, "hen": 6, "insects": 7, "sheep": 8, "crow": 9,
    "rain": 10, "sea_waves": 11, "crackling_fire": 12, "crickets": 13, "chirping_birds": 14,
    "water_drops": 15, "wind": 16, "pouring_water": 17, "toilet_flush": 18, "thunderstorm": 19,
    "crying_baby": 20, "sneezing": 21, "clapping": 22, "breathing": 23, "coughing": 24,
    "footsteps": 25, "laughing": 26, "brushing_teeth": 27, "snoring": 28, "drinking_sipping": 29,
    "door_wood_knock": 30, "mouse_click": 31, "keyboard_typing": 32, "door_wood_creaks": 33, "can_opening": 34,
    "washing_machine": 35, "vacuum_cleaner": 36, "clock_alarm": 37, "clock_tick": 38, "glass_breaking": 39,
    "helicopter": 40, "chainsaw": 41, "siren": 42, "car_horn": 43, "engine": 44,
    "train": 45, "church_bells": 46, "airplane": 47, "fireworks": 48, "hand_saw": 49
}


class AudioAugmenter:
    """Advanced audio augmentation class with multiple techniques."""
    
    def __init__(self, sample_rate=44100):
        self.sample_rate = sample_rate
    
    def load_wav(self, filepath):
        """Load WAV file and return samples."""
        try:
            with wave.open(str(filepath), 'rb') as wf:
                frames = wf.readframes(wf.getnframes())
                samples = np.frombuffer(frames, dtype=np.int16).astype(np.float32)
                sr = wf.getframerate()
                return samples, sr
        except Exception as e:
            return None, None
    
    def save_wav(self, samples, sample_rate, filepath):
        """Save samples as WAV file."""
        filepath.parent.mkdir(parents=True, exist_ok=True)
        samples = np.clip(samples, -32768, 32767).astype(np.int16)
        with wave.open(str(filepath), 'w') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(sample_rate)
            w.writeframes(samples.tobytes())
    
    def normalize(self, samples):
        """Normalize audio to -1 to 1 range."""
        max_val = np.max(np.abs(samples))
        if max_val > 0:
            return samples / max_val
        return samples
    
    def add_noise(self, samples, noise_level=0.02):
        """Add Gaussian noise."""
        noise = np.random.normal(0, noise_level, len(samples))
        return samples + noise * np.max(np.abs(samples))
    
    def add_background_noise(self, samples, bg_samples, snr_db=10):
        """Mix with background noise at specified SNR."""
        if bg_samples is None or len(bg_samples) == 0:
            return samples
        
        # Match lengths
        if len(bg_samples) < len(samples):
            bg_samples = np.tile(bg_samples, int(np.ceil(len(samples) / len(bg_samples))))
        bg_samples = bg_samples[:len(samples)]
        
        # Calculate SNR
        signal_power = np.mean(samples ** 2)
        noise_power = np.mean(bg_samples ** 2)
        
        if noise_power > 0:
            snr_linear = 10 ** (snr_db / 10)
            noise_scale = np.sqrt(signal_power / (snr_linear * noise_power))
            return samples + bg_samples * noise_scale
        return samples
    
    def time_stretch(self, samples, rate=1.0):
        """Simple time stretching using resampling."""
        if rate == 1.0:
            return samples
        indices = np.arange(0, len(samples), rate).astype(int)
        indices = indices[indices < len(samples)]
        return samples[indices]
    
    def pitch_shift(self, samples, semitones=0):
        """Simple pitch shift using resampling."""
        if semitones == 0:
            return samples
        rate = 2 ** (-semitones / 12)
        stretched = self.time_stretch(samples, rate)
        # Resample back to original length
        if len(stretched) != len(samples):
            indices = np.linspace(0, len(stretched) - 1, len(samples)).astype(int)
            return stretched[indices]
        return stretched
    
    def time_shift(self, samples, shift_max=0.2):
        """Shift audio in time."""
        shift = int(len(samples) * random.uniform(-shift_max, shift_max))
        return np.roll(samples, shift)
    
    def volume_change(self, samples, gain_db):
        """Change volume by dB amount."""
        gain = 10 ** (gain_db / 20)
        return samples * gain
    
    def add_reverb(self, samples, decay=0.3, delay_ms=30):
        """Simple reverb effect."""
        delay_samples = int(self.sample_rate * delay_ms / 1000)
        output = np.zeros(len(samples) + delay_samples)
        output[:len(samples)] = samples
        output[delay_samples:] += samples * decay
        return output[:len(samples)]
    
    def spectral_augment(self, samples, freq_mask_param=10):
        """Simple frequency masking using time-domain approximation."""
        # Apply random bandpass filtering effect
        mask_freq = random.randint(100, 2000)
        mask_width = random.randint(50, 200)
        
        # Simple low-pass approximation
        filtered = np.copy(samples)
        for i in range(1, len(filtered)):
            filtered[i] = 0.9 * filtered[i-1] + 0.1 * filtered[i]
        
        # Mix with original
        mix = random.uniform(0.3, 0.7)
        return samples * mix + filtered * (1 - mix)
    
    def random_augment(self, samples, num_augments=3):
        """Apply random combination of augmentations."""
        augmentations = [
            lambda x: self.add_noise(x, random.uniform(0.01, 0.05)),
            lambda x: self.pitch_shift(x, random.uniform(-2, 2)),
            lambda x: self.time_shift(x, random.uniform(0.1, 0.3)),
            lambda x: self.volume_change(x, random.uniform(-6, 6)),
            lambda x: self.add_reverb(x, random.uniform(0.1, 0.4)),
            lambda x: self.spectral_augment(x),
        ]
        
        selected = random.sample(augmentations, min(num_augments, len(augmentations)))
        result = samples.copy()
        for aug in selected:
            result = aug(result)
        return result


def collect_esc50_files():
    """Collect all ESC-50 files with metadata."""
    esc50_audio_dir = ESC50_DIR / "audio"
    meta_file = ESC50_DIR / "meta" / "esc50.csv"
    
    if not esc50_audio_dir.exists():
        print(f"ESC-50 not found at {esc50_audio_dir}")
        return {}
    
    file_to_class = {}
    if meta_file.exists():
        with open(meta_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                file_to_class[row['filename']] = row['category']
    
    files_by_class = {}
    for wav_file in esc50_audio_dir.glob("*.wav"):
        if wav_file.name in file_to_class:
            cls = file_to_class[wav_file.name]
            if cls not in files_by_class:
                files_by_class[cls] = []
            files_by_class[cls].append(wav_file)
    
    return files_by_class


# Mapping from HearAlert categories to ESC-50 classes
CATEGORY_MAPPING = {
    "baby_cry": ["crying_baby"],
    "car_horn": ["car_horn"],
    "traffic": ["engine", "car_horn"],
    "train": ["train"],
    "siren": ["siren"],
    "fire_alarm": ["fireworks", "crackling_fire"],
    "glass_breaking": ["glass_breaking"],
    "door_knock": ["door_wood_knock"],
    "doorbell": ["church_bells"],
    "phone_ring": ["clock_alarm"],
    "dog_bark": ["dog"],
    "cat_meow": ["cat"],
    "helicopter": ["helicopter"],
    "thunderstorm": ["thunderstorm"],
    "speech": ["laughing", "sneezing", "clapping"],
    "coughing": ["coughing"],
    "breathing": ["breathing", "snoring"],
    "footsteps": ["footsteps"],
    "door_creaking": ["door_wood_creaks"],
    "washing_machine": ["washing_machine"],
    "vacuum_cleaner": ["vacuum_cleaner"],
    "keyboard_typing": ["keyboard_typing", "mouse_click"],
    "clock_tick": ["clock_tick"],
    "chainsaw": ["chainsaw", "hand_saw"],
    "gunshot_firework": ["fireworks"],
    "airplane": ["airplane"],
}


def process_category(category, esc_classes, esc50_files, augmenter, augments_per_file=4):
    """Process a single category with augmentations."""
    cat_dir = AUGMENTED_DIR / category
    cat_dir.mkdir(parents=True, exist_ok=True)
    
    count = 0
    
    for esc_class in esc_classes:
        if esc_class not in esc50_files:
            continue
        
        for wav_file in esc50_files[esc_class]:
            samples, sr = augmenter.load_wav(wav_file)
            if samples is None:
                continue
            
            # Save original
            dest = cat_dir / f"{category}_{count:04d}_orig.wav"
            augmenter.save_wav(samples, sr, dest)
            count += 1
            
            # Generate augmented versions
            for i in range(augments_per_file):
                aug_samples = augmenter.random_augment(samples)
                aug_samples = augmenter.normalize(aug_samples) * 32767
                dest = cat_dir / f"{category}_{count:04d}_aug{i}.wav"
                augmenter.save_wav(aug_samples, sr, dest)
                count += 1
    
    return category, count


def main():
    print("=" * 70)
    print("HearAlert Advanced Audio Augmentation Pipeline")
    print("=" * 70)
    
    AUGMENTED_DIR.mkdir(parents=True, exist_ok=True)
    
    # Initialize augmenter
    augmenter = AudioAugmenter()
    
    # Collect ESC-50 files
    print("\n[1/3] Collecting ESC-50 dataset...")
    esc50_files = collect_esc50_files()
    
    total_esc50 = sum(len(files) for files in esc50_files.values())
    print(f"  Found {total_esc50} ESC-50 files across {len(esc50_files)} classes")
    
    # Process each category
    print("\n[2/3] Generating augmented audio...")
    
    category_counts = {}
    total_files = 0
    
    for category, esc_classes in CATEGORY_MAPPING.items():
        cat_name, count = process_category(
            category, esc_classes, esc50_files, augmenter, augments_per_file=5
        )
        category_counts[cat_name] = count
        total_files += count
        print(f"  {category}: {count} files")
    
    # Copy to training_data
    print("\n[3/3] Copying to training_data directory...")
    for category in CATEGORY_MAPPING.keys():
        src_dir = AUGMENTED_DIR / category
        dest_dir = TRAINING_DATA_DIR / category
        
        if src_dir.exists():
            dest_dir.mkdir(parents=True, exist_ok=True)
            for wav_file in src_dir.glob("*.wav"):
                dest_file = dest_dir / wav_file.name
                if not dest_file.exists():
                    shutil.copy2(wav_file, dest_file)
    
    print("\n" + "=" * 70)
    print("AUGMENTATION COMPLETE")
    print("=" * 70)
    print(f"Total augmented files: {total_files}")
    print(f"Output directory: {AUGMENTED_DIR}")
    
    print("\nCategory breakdown:")
    for cat, count in sorted(category_counts.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count} files")
    
    print("\n" + "=" * 70)
    print("Run 'python train_audio_model.py' to train with augmented data")
    print("=" * 70)


if __name__ == "__main__":
    main()

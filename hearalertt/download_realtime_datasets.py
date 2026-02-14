#!/usr/bin/env python3
"""
Download and Generate Real-Time Audio Datasets for HearAlert
============================================================
Expands the dataset with new categories and real-world audio variations.
"""

import os
import numpy as np
import wave
import struct
from pathlib import Path
import random
import shutil
import csv

BASE_DIR = Path(__file__).parent
DATASETS_DIR = BASE_DIR / "datasets"
ESC50_DIR = DATASETS_DIR / "ESC-50"
NEW_AUDIO_DIR = BASE_DIR / "realtime_audio"
TRAINING_DATA_DIR = BASE_DIR / "training_data"

# New categories to add for real-time use cases
NEW_REALTIME_CATEGORIES = {
    # Human Sounds - Critical for deaf accessibility
    "speech": {
        "esc50_classes": ["laughing", "sneezing", "clapping", "coughing", "breathing"],
        "display_name": "Human Voice/Speech",
        "priority": 8,
        "alert_type": "high",
        "color": "#6B5B95"
    },
    "coughing": {
        "esc50_classes": ["coughing"],
        "display_name": "Coughing",
        "priority": 7,
        "alert_type": "high",
        "color": "#FF7F50"
    },
    "breathing": {
        "esc50_classes": ["breathing", "snoring"],
        "display_name": "Heavy Breathing",
        "priority": 7,
        "alert_type": "high",
        "color": "#87CEEB"
    },
    "footsteps": {
        "esc50_classes": ["footsteps"],
        "display_name": "Footsteps",
        "priority": 6,
        "alert_type": "medium",
        "color": "#8B4513"
    },
    
    # Home Sounds - Daily life
    "door_creaking": {
        "esc50_classes": ["door_wood_creaks"],
        "display_name": "Door Opening",
        "priority": 8,
        "alert_type": "high",
        "color": "#A0522D"
    },
    "washing_machine": {
        "esc50_classes": ["washing_machine"],
        "display_name": "Washing Machine",
        "priority": 6,
        "alert_type": "medium",
        "color": "#4682B4"
    },
    "vacuum_cleaner": {
        "esc50_classes": ["vacuum_cleaner"],
        "display_name": "Vacuum Cleaner",
        "priority": 5,
        "alert_type": "low",
        "color": "#708090"
    },
    "keyboard_typing": {
        "esc50_classes": ["keyboard_typing", "mouse_click"],
        "display_name": "Keyboard/Mouse",
        "priority": 4,
        "alert_type": "low",
        "color": "#2F4F4F"
    },
    "clock_tick": {
        "esc50_classes": ["clock_tick"],
        "display_name": "Clock Ticking",
        "priority": 4,
        "alert_type": "low",
        "color": "#DAA520"
    },
    
    # Safety Sounds
    "chainsaw": {
        "esc50_classes": ["chainsaw", "hand_saw"],
        "display_name": "Power Tools",
        "priority": 8,
        "alert_type": "high",
        "color": "#FF4500"
    },
    "gunshot_firework": {
        "esc50_classes": ["fireworks"],
        "display_name": "Gunshot/Fireworks",
        "priority": 10,
        "alert_type": "critical",
        "color": "#DC143C"
    },
    "airplane": {
        "esc50_classes": ["airplane"],
        "display_name": "Airplane",
        "priority": 5,
        "alert_type": "low",
        "color": "#4169E1"
    },
    # Baby Sounds
    "baby_cry": {
        "esc50_classes": ["crying_baby"],
        "display_name": "Baby Crying",
        "priority": 10,
        "alert_type": "critical",
        "color": "#FF69B4"
    },

    # Traffic & Vehicle Sounds
    "car_horn": {
        "esc50_classes": ["car_horn"],
        "display_name": "Car Horn",
        "priority": 10,
        "alert_type": "critical",
        "color": "#CD5C5C"
    },
    "traffic": {
        "esc50_classes": ["engine", "car_horn"],
        "display_name": "Traffic/Vehicle",
        "priority": 8,
        "alert_type": "high",
        "color": "#808080"
    },
    "train": {
        "esc50_classes": ["train"],
        "display_name": "Train",
        "priority": 9,
        "alert_type": "critical",
        "color": "#2F4F4F"
    },

    # Emergency Sounds
    "siren": {
        "esc50_classes": ["siren"],
        "display_name": "Emergency Siren",
        "priority": 10,
        "alert_type": "critical",
        "color": "#FF0000"
    },
    "fire_alarm": {
        "esc50_classes": ["fireworks", "crackling_fire"],
        "display_name": "Fire/Alarm",
        "priority": 10,
        "alert_type": "critical",
        "color": "#FF4500"
    },
    "glass_breaking": {
        "esc50_classes": ["glass_breaking"],
        "display_name": "Glass Breaking",
        "priority": 9,
        "alert_type": "critical",
        "color": "#E0FFFF"
    },

    # Home Sounds - Expanded
    "door_knock": {
        "esc50_classes": ["door_wood_knock", "door_wood_creaks"],
        "display_name": "Door Knock",
        "priority": 8,
        "alert_type": "high",
        "color": "#8B4513"
    },
    "doorbell": {
        "esc50_classes": ["church_bells"],
        "display_name": "Doorbell",
        "priority": 8,
        "alert_type": "high",
        "color": "#FFD700"
    },
    "phone_ring": {
        "esc50_classes": ["clock_alarm"],
        "display_name": "Phone/Alarm Ring",
        "priority": 7,
        "alert_type": "high",
        "color": "#4B0082"
    },
    "smoke_alarm": {
        "display_name": "Smoke Alarm",
        "priority": 10,
        "alert_type": "critical",
        "color": "#A52A2A"
    },
    "car_alarm": {
        "display_name": "Car Alarm",
        "priority": 9,
        "alert_type": "critical",
        "color": "#DC143C"
    },
    "alarm_clock": {
        "display_name": "Alarm Clock",
        "priority": 8,
        "alert_type": "high",
        "color": "#00008B"
    },
    "microwave_beep": {
        "display_name": "Microwave Beep",
        "priority": 7,
        "alert_type": "high",
        "color": "#9370DB"
    },
    "knock_knock": {
        "display_name": "Knocking",
        "priority": 8,
        "alert_type": "high",
        "color": "#DEB887"
    },
    "water_running": {
        "display_name": "Water Running",
        "priority": 6,
        "alert_type": "medium",
        "color": "#00FFFF"
    },

    # Animal Sounds
    "dog_bark": {
        "esc50_classes": ["dog"],
        "display_name": "Dog Barking",
        "priority": 7,
        "alert_type": "high",
        "color": "#D2691E"
    },
    "cat_meow": {
        "esc50_classes": ["cat"],
        "display_name": "Cat Meowing",
        "priority": 5,
        "alert_type": "medium",
        "color": "#F0E68C"
    },

    # Outdoor Safety
    "helicopter": {
        "esc50_classes": ["helicopter"],
        "display_name": "Helicopter",
        "priority": 6,
        "alert_type": "medium",
        "color": "#778899"
    },
    "thunderstorm": {
        "esc50_classes": ["thunderstorm"],
        "display_name": "Thunderstorm",
        "priority": 7,
        "alert_type": "high",
        "color": "#483D8B"
    },
}

# ESC-50 class to filename mapping
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


def get_audio_info(wav_path):
    """Extract audio information from WAV file."""
    try:
        with wave.open(str(wav_path), 'rb') as wf:
            return {
                "channels": wf.getnchannels(),
                "sample_rate": wf.getframerate(),
                "sample_width": wf.getsampwidth(),
                "frames": wf.getnframes(),
                "duration_ms": int((wf.getnframes() / wf.getframerate()) * 1000)
            }
    except Exception as e:
        return None


def collect_esc50_for_category(category, esc_classes):
    """Collect ESC-50 files for a specific category."""
    esc50_audio_dir = ESC50_DIR / "audio"
    meta_file = ESC50_DIR / "meta" / "esc50.csv"
    
    if not esc50_audio_dir.exists():
        print(f"  ESC-50 audio directory not found: {esc50_audio_dir}")
        return []
    
    # Load metadata
    file_to_class = {}
    if meta_file.exists():
        with open(meta_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                file_to_class[row['filename']] = row['category']
    
    files = []
    for wav_file in esc50_audio_dir.glob("*.wav"):
        if wav_file.name in file_to_class:
            if file_to_class[wav_file.name] in esc_classes:
                info = get_audio_info(wav_file)
                if info:
                    files.append({
                        "path": wav_file,
                        "source": f"ESC-50/{file_to_class[wav_file.name]}",
                        **info
                    })
    
    return files


def generate_synthetic_variation(samples, variation_type, sample_rate=44100):
    """Generate synthetic variation of audio samples."""
    samples = samples.astype(np.float32)
    
    if variation_type == "pitch_up":
        # Simple resampling for pitch shift up
        indices = np.arange(0, len(samples), 1.1).astype(int)
        indices = indices[indices < len(samples)]
        samples = samples[indices]
        # Pad to original length
        if len(samples) < sample_rate * 5:
            samples = np.pad(samples, (0, sample_rate * 5 - len(samples)))
    
    elif variation_type == "pitch_down":
        # Simple resampling for pitch shift down
        indices = np.arange(0, len(samples), 0.9).astype(int)
        indices = indices[indices < len(samples)]
        samples = samples[indices][:sample_rate * 5]
    
    elif variation_type == "noise":
        noise = np.random.normal(0, 0.02, len(samples))
        samples = samples + noise * np.max(np.abs(samples))
    
    elif variation_type == "reverb":
        # Simple reverb simulation
        delay_samples = int(0.03 * sample_rate)
        reverb = np.zeros(len(samples) + delay_samples)
        reverb[:len(samples)] = samples
        reverb[delay_samples:] += 0.5 * samples
        samples = reverb[:len(samples)]
    
    elif variation_type == "volume_up":
        samples = samples * 1.3
    
    elif variation_type == "volume_down":
        samples = samples * 0.7
    
    elif variation_type == "time_shift":
        shift = len(samples) // 8
        samples = np.roll(samples, shift)
    
    # Normalize
    max_val = np.max(np.abs(samples))
    if max_val > 0:
        samples = samples / max_val
    
    return (samples * 32767).astype(np.int16)


def load_wav_samples(wav_path):
    """Load samples from WAV file."""
    try:
        with wave.open(str(wav_path), 'rb') as wf:
            frames = wf.readframes(wf.getnframes())
            samples = np.frombuffer(frames, dtype=np.int16)
            return samples, wf.getframerate()
    except Exception as e:
        return None, None


def save_wav(samples, sample_rate, filepath):
    """Save samples as WAV file."""
    filepath.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(filepath), 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        # Ensure mono
        if len(samples.shape) > 1:
            samples = samples.mean(axis=1).astype(np.int16)
        w.writeframes(samples.tobytes())


def generate_synthetic_audio_for_category(category, config, num_samples=50):
    """Generate synthetic audio for categories without enough ESC-50 data."""
    cat_dir = NEW_AUDIO_DIR / category
    cat_dir.mkdir(parents=True, exist_ok=True)
    
    generated = 0
    
    # Category-specific generation
    if category == "speech":
        # Generate varying tones simulating speech patterns
        for i in range(num_samples):
            duration = 5
            sr = 44100
            t = np.linspace(0, duration, sr * duration)
            
            # Random speech-like frequencies
            base_freq = random.uniform(100, 300)
            freq_mod = random.uniform(5, 20)
            
            signal = np.zeros_like(t)
            for _ in range(random.randint(5, 15)):
                start = random.uniform(0, duration - 0.5)
                end = start + random.uniform(0.1, 0.5)
                mask = (t >= start) & (t <= end)
                freq = base_freq + random.uniform(-50, 50)
                signal[mask] += np.sin(2 * np.pi * freq * t[mask])
            
            # Add formants
            signal += 0.3 * np.sin(2 * np.pi * base_freq * 2 * t)
            signal += 0.2 * np.sin(2 * np.pi * base_freq * 3 * t)
            
            # Normalize and add noise
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            signal += np.random.normal(0, 0.05, len(signal))
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            
            samples = (signal * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1
    
    elif category == "footsteps":
        for i in range(num_samples):
            duration = 5
            sr = 44100
            t = np.linspace(0, duration, sr * duration)
            signal = np.zeros_like(t)
            
            # Random footstep pattern
            step_interval = random.uniform(0.4, 0.8)
            for step_time in np.arange(0, duration, step_interval):
                step_idx = int(step_time * sr)
                if step_idx < len(signal):
                    impact_len = int(0.1 * sr)
                    for j in range(min(impact_len, len(signal) - step_idx)):
                        decay = np.exp(-j / (sr * 0.02))
                        freq = random.uniform(100, 200)
                        signal[step_idx + j] += decay * np.sin(2 * np.pi * freq * j / sr)
            
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            signal += np.random.normal(0, 0.02, len(signal))
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            
            samples = (signal * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1
    
    elif category == "door_creaking":
        for i in range(num_samples):
            duration = 5
            sr = 44100
            t = np.linspace(0, duration, sr * duration)
            signal = np.zeros_like(t)
            
            # Creaking sound - FM synthesis
            start = random.uniform(0.5, 1.5)
            end = start + random.uniform(1, 2)
            mask = (t >= start) & (t <= end)
            
            carrier_freq = random.uniform(200, 400)
            mod_freq = random.uniform(10, 50)
            mod_depth = random.uniform(50, 150)
            
            signal[mask] = np.sin(2 * np.pi * (carrier_freq + mod_depth * np.sin(2 * np.pi * mod_freq * t[mask])) * t[mask])
            
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            signal += np.random.normal(0, 0.03, len(signal))
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            
            samples = (signal * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1

    elif category in ["smoke_alarm", "car_alarm", "alarm_clock", "microwave_beep", "siren", "fire_alarm"]:
        # Beep/Alarm synthesis
        for i in range(num_samples):
            duration = 5
            sr = 44100
            t = np.linspace(0, duration, sr * duration)
            signal = np.zeros_like(t)

            if category == "smoke_alarm":
                # High pitched intermittent beeps: ~3000Hz
                beep_freq = 3000 + random.uniform(-100, 100)
                pattern_interval = 0.5 # 0.5s beep, 0.5s silence
                for start in np.arange(0, duration, 1.0):
                    end = start + 0.5
                    mask = (t >= start) & (t < end)
                    signal[mask] = np.sin(2 * np.pi * beep_freq * t[mask])

            elif category == "car_alarm":
                # Rising/Falling siren
                freq_start = 500
                freq_end = 1500
                period = 0.3
                freq = freq_start + (freq_end - freq_start) * (0.5 * (1 + np.sin(2 * np.pi * (1/period) * t)))
                signal = np.sin(2 * np.pi * freq * t)

            elif category == "alarm_clock":
                # Standard beep-beep-beep
                beep_freq = 1000 + random.uniform(-100, 100)
                for start in np.arange(0, duration, 1.0):
                   # Three beeps
                   for b in range(3):
                       b_start = start + b * 0.2
                       b_end = b_start + 0.1
                       mask = (t >= b_start) & (t < b_end)
                       signal[mask] = np.sin(2 * np.pi * beep_freq * t[mask])

            elif category == "microwave_beep":
                # Single long beep or few beeps
                beep_freq = 2000 + random.uniform(-100, 100)
                # Beep at end (simulate end of cooking)
                mask = (t >= 1.0) & (t < 2.0)
                signal[mask] = np.sin(2 * np.pi * beep_freq * t[mask])
                mask = (t >= 2.5) & (t < 3.5)
                signal[mask] = np.sin(2 * np.pi * beep_freq * t[mask])

            elif category == "siren":
                 # Classic wail
                freq = 600 + 500 * np.sin(2 * np.pi * 0.2 * t)
                signal = np.sin(2 * np.pi * freq * t)

            elif category == "fire_alarm":
                # Harsh bell or buzzer
                base_freq = 400
                # Add harmonics for harshness
                signal = np.sin(2 * np.pi * base_freq * t)
                signal += 0.5 * np.sin(2 * np.pi * (base_freq * 2.5) * t)
                signal += 0.3 * np.sin(2 * np.pi * (base_freq * 5.2) * t)
                # Pulse
                pulse = np.sign(np.sin(2 * np.pi * 2 * t))
                pulse[pulse < 0] = 0
                signal = signal * pulse

            signal = signal / (np.max(np.abs(signal)) + 0.001)
            signal += np.random.normal(0, 0.01, len(signal)) # Light noise
            signal = signal / (np.max(np.abs(signal)) + 0.001)

            samples = (signal * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1
    
    elif category == "water_running":
        for i in range(num_samples):
            duration = 5
            sr = 44100
            # Brown noise approximation for water
            samples = np.random.normal(0, 1, int(sr * duration))
            # Cumulative sum to get brown noise spectral characteristics (-6dB/octave)
            samples = np.cumsum(samples)
            # Filter to remove very low freq drift
            # Simple high pass if scipy not avail, or just differentiation
            # Let's do a simple differentiation to bring it back towards pink/whitemix which sounds like water
            samples = np.diff(samples, prepend=0)
            
            # Normalize
            samples = samples / (np.max(np.abs(samples)) + 0.001)
            
            samples = (samples * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1

    elif category == "knock_knock":
         # Similar to door creak but impacts
        for i in range(num_samples):
            duration = 5
            sr = 44100
            signal = np.zeros(int(sr * duration))
            
            # 2-3 knocks
            knocks = random.randint(2, 4)
            start_time = 1.0
            for k in range(knocks):
                k_time = start_time + k * random.uniform(0.2, 0.4)
                k_idx = int(k_time * sr)
                if k_idx < len(signal):
                    # Impact envelope
                    impact_len = int(0.05 * sr)
                    for j in range(min(impact_len, len(signal) - k_idx)):
                        amp = np.exp(-j/(sr*0.005))
                        freq = random.uniform(100, 300)
                        signal[k_idx+j] += amp * np.sin(2*np.pi*freq*j/sr)

            signal = signal / (np.max(np.abs(signal)) + 0.001)
            samples = (signal * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1

    else:

        # Generic synthetic generation
        for i in range(num_samples):
            duration = 5
            sr = 44100
            t = np.linspace(0, duration, sr * duration)
            
            freq = random.uniform(200, 2000)
            signal = np.sin(2 * np.pi * freq * t)
            signal += 0.3 * np.sin(2 * np.pi * freq * 2 * t)
            
            # Add envelope
            envelope = np.exp(-t / random.uniform(1, 3))
            signal = signal * envelope
            
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            signal += np.random.normal(0, 0.05, len(signal))
            signal = signal / (np.max(np.abs(signal)) + 0.001)
            
            samples = (signal * 32767).astype(np.int16)
            save_wav(samples, sr, cat_dir / f"{category}_synth_{i:03d}.wav")
            generated += 1
    
    return generated


def expand_with_augmentations(source_files, category, target_count=200):
    """Expand dataset with augmented versions."""
    cat_dir = NEW_AUDIO_DIR / category
    cat_dir.mkdir(parents=True, exist_ok=True)
    
    variations = ["noise", "volume_up", "volume_down", "time_shift", "pitch_up", "pitch_down"]
    
    copied = 0
    augmented = 0
    
    for i, file_info in enumerate(source_files):
        src_path = file_info["path"]
        
        # Copy original
        dest_path = cat_dir / f"{category}_{i:04d}.wav"
        try:
            shutil.copy2(src_path, dest_path)
            copied += 1
        except Exception as e:
            print(f"    Error copying {src_path}: {e}")
            continue
        
        # Generate augmentations if needed
        if copied + augmented < target_count:
            samples, sr = load_wav_samples(src_path)
            if samples is not None:
                for var in random.sample(variations, min(3, len(variations))):
                    if copied + augmented >= target_count:
                        break
                    
                    aug_samples = generate_synthetic_variation(samples, var, sr)
                    aug_path = cat_dir / f"{category}_{i:04d}_{var}.wav"
                    save_wav(aug_samples, sr, aug_path)
                    augmented += 1
    
    return copied, augmented


def main():
    print("=" * 60)
    print("HearAlert Real-Time Dataset Expansion")
    print("=" * 60)
    
    NEW_AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    
    total_files = 0
    category_stats = {}
    
    for category, config in NEW_REALTIME_CATEGORIES.items():
        print(f"\n[{category.upper()}] Processing {config['display_name']}...")
        
        esc_classes = config.get("esc50_classes", [])
        
        # Collect from ESC-50
        esc_files = collect_esc50_for_category(category, esc_classes)
        print(f"  Found {len(esc_files)} ESC-50 files")
        
        if len(esc_files) >= 20:
            # Use ESC-50 data + augmentations
            copied, augmented = expand_with_augmentations(esc_files, category, target_count=300)
            print(f"  Copied: {copied}, Augmented: {augmented}")
            total_in_cat = copied + augmented
        else:
            # Generate synthetic + any ESC-50 data
            copied = 0
            if esc_files:
                copied, _ = expand_with_augmentations(esc_files, category, target_count=50)
            
            # Generate synthetic to fill gap
            synth_needed = max(50, 300 - copied)
            synth_count = generate_synthetic_audio_for_category(category, config, synth_needed)
            print(f"  ESC-50: {copied}, Synthetic: {synth_count}")
            total_in_cat = copied + synth_count
        
        category_stats[category] = total_in_cat
        total_files += total_in_cat
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    for cat, count in category_stats.items():
        display = NEW_REALTIME_CATEGORIES[cat]["display_name"]
        priority = NEW_REALTIME_CATEGORIES[cat]["priority"]
        print(f"  {cat}: {count} files (Priority: {priority}) - {display}")
    
    print(f"\nTOTAL NEW FILES: {total_files}")
    print(f"Output directory: {NEW_AUDIO_DIR}")
    print("=" * 60)
    
    # Copy to training_data directory
    print("\nCopying to training_data directory...")
    for category in NEW_REALTIME_CATEGORIES.keys():
        src_dir = NEW_AUDIO_DIR / category
        dest_dir = TRAINING_DATA_DIR / category
        
        if src_dir.exists():
            dest_dir.mkdir(parents=True, exist_ok=True)
            for wav_file in src_dir.glob("*.wav"):
                dest_file = dest_dir / wav_file.name
                if not dest_file.exists():
                    shutil.copy2(wav_file, dest_file)
    
    print("Done! Run train_audio_model.py to retrain with new data.")


if __name__ == "__main__":
    main()

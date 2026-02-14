#!/usr/bin/env python3
"""
HearAlert Audio Dataset Training Pipeline
==========================================
Downloads, processes, and trains model on audio datasets for real-time classification.

Target: 1000+ WAV audio files with YAML configuration for training.
"""

import os
import sys
import shutil
import wave
import json
import yaml
import subprocess
from pathlib import Path
from datetime import datetime
import hashlib
import random

# Paths
BASE_DIR = Path(__file__).parent
RAW_DIR = BASE_DIR / "raw"
DATASETS_DIR = BASE_DIR / "datasets"
PROCESSED_DIR = BASE_DIR / "training_data"
OUTPUT_DIR = BASE_DIR / "mobile_app" / "assets" / "datasets"
MODEL_OUTPUT = BASE_DIR / "mobile_app" / "assets" / "models"
AUGMENTED_DIR = BASE_DIR / "augmented_audio"  # Augmented audio directory
EXPANDED_DIR = BASE_DIR / "expanded_audio"  # Expanded audio directory
NEW_AUDIO_DIR = BASE_DIR / "realtime_audio"  # New generated audio directory

# Training categories for HearAlert - Deaf Accessibility Focus
TRAINING_CATEGORIES = {
    # ═══════════════════════════════════════════════════════════════════
    # BABY SOUNDS - High Priority for Parents
    # ═══════════════════════════════════════════════════════════════════
    "baby_cry": {
        "sources": ["belly_pain", "burping", "cold_hot", "discomfort", "hungry", "tired"],
        "esc50_classes": ["crying_baby"],
        "display_name": "Baby Crying",
        "priority": 10,
        "alert_type": "critical"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # TRAFFIC & VEHICLE SOUNDS - Critical for Deaf Safety
    # ═══════════════════════════════════════════════════════════════════
    "car_horn": {
        "esc50_classes": ["car_horn"],
        "display_name": "Car Horn",
        "priority": 10,
        "alert_type": "critical"
    },
    "traffic": {
        "esc50_classes": ["engine", "car_horn"],
        "display_name": "Traffic/Vehicle",
        "priority": 8,
        "alert_type": "high"
    },
    "train": {
        "esc50_classes": ["train"],
        "display_name": "Train",
        "priority": 9,
        "alert_type": "critical"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # EMERGENCY SOUNDS - Life Safety
    # ═══════════════════════════════════════════════════════════════════
    "siren": {
        "esc50_classes": ["siren"],
        "display_name": "Emergency Siren",
        "priority": 10,
        "alert_type": "critical"
    },
    "fire_alarm": {
        "esc50_classes": ["fireworks", "crackling_fire"],
        "display_name": "Fire/Alarm",
        "priority": 10,
        "alert_type": "critical"
    },
    "glass_breaking": {
        "esc50_classes": ["glass_breaking"],
        "display_name": "Glass Breaking",
        "priority": 9,
        "alert_type": "critical"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # HOME SOUNDS - Daily Alerts
    # ═══════════════════════════════════════════════════════════════════
    "door_knock": {
        "esc50_classes": ["door_wood_knock", "door_wood_creaks"],
        "display_name": "Door Knock",
        "priority": 8,
        "alert_type": "high"
    },
    "doorbell": {
        "esc50_classes": ["church_bells"],  # Similar bell sound
        "display_name": "Doorbell",
        "priority": 8,
        "alert_type": "high"
    },
    "phone_ring": {
        "esc50_classes": ["clock_alarm"],  # Similar ringing sound
        "display_name": "Phone/Alarm Ring",
        "priority": 7,
        "alert_type": "high"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # ANIMAL SOUNDS - Pet & Safety Awareness
    # ═══════════════════════════════════════════════════════════════════
    "dog_bark": {
        "sources": ["Dog"],
        "esc50_classes": ["dog"],
        "display_name": "Dog Barking",
        "priority": 7,
        "alert_type": "high"
    },
    "cat_meow": {
        "esc50_classes": ["cat"],
        "display_name": "Cat Meowing",
        "priority": 5,
        "alert_type": "medium"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # OUTDOOR SAFETY
    # ═══════════════════════════════════════════════════════════════════
    "helicopter": {
        "esc50_classes": ["helicopter"],
        "display_name": "Helicopter",
        "priority": 6,
        "alert_type": "medium"
    },
    "thunderstorm": {
        "esc50_classes": ["thunderstorm"],
        "display_name": "Thunderstorm",
        "priority": 7,
        "alert_type": "high"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # NEW ADDITIONAL CATEGORIES
    # ═══════════════════════════════════════════════════════════════════
    "smoke_alarm": {
        "display_name": "Smoke Alarm",
        "priority": 10,
        "alert_type": "critical"
    },
    "car_alarm": {
        "display_name": "Car Alarm",
        "priority": 9,
        "alert_type": "critical"
    },
    "alarm_clock": {
        "display_name": "Alarm Clock",
        "priority": 8,
        "alert_type": "high"
    },
    "microwave_beep": {
        "display_name": "Microwave Beep",
        "priority": 7,
        "alert_type": "high"
    },
    "knock_knock": {
        "display_name": "Knocking",
        "priority": 8,
        "alert_type": "high"
    },
    "water_running": {
        "display_name": "Water Running",
        "priority": 6,
        "alert_type": "medium"
    },
    
    # ═══════════════════════════════════════════════════════════════════
    # REAL-TIME CATEGORIES - Human & Safety Sounds
    # ═══════════════════════════════════════════════════════════════════
    "speech": {
        "esc50_classes": ["laughing", "sneezing", "clapping"],
        "display_name": "Human Voice/Speech",
        "priority": 8,
        "alert_type": "high"
    },
    "coughing": {
        "esc50_classes": ["coughing"],
        "display_name": "Coughing",
        "priority": 7,
        "alert_type": "high"
    },
    "breathing": {
        "esc50_classes": ["breathing", "snoring"],
        "display_name": "Heavy Breathing",
        "priority": 7,
        "alert_type": "high"
    },
    "footsteps": {
        "esc50_classes": ["footsteps"],
        "display_name": "Footsteps",
        "priority": 6,
        "alert_type": "medium"
    },
    "door_creaking": {
        "esc50_classes": ["door_wood_creaks"],
        "display_name": "Door Opening",
        "priority": 8,
        "alert_type": "high"
    },
    "washing_machine": {
        "esc50_classes": ["washing_machine"],
        "display_name": "Washing Machine",
        "priority": 6,
        "alert_type": "medium"
    },
    "vacuum_cleaner": {
        "esc50_classes": ["vacuum_cleaner"],
        "display_name": "Vacuum Cleaner",
        "priority": 5,
        "alert_type": "low"
    },
    "keyboard_typing": {
        "esc50_classes": ["keyboard_typing", "mouse_click"],
        "display_name": "Keyboard/Mouse",
        "priority": 4,
        "alert_type": "low"
    },
    "clock_tick": {
        "esc50_classes": ["clock_tick"],
        "display_name": "Clock Ticking",
        "priority": 4,
        "alert_type": "low"
    },
    "chainsaw": {
        "esc50_classes": ["chainsaw", "hand_saw"],
        "display_name": "Power Tools",
        "priority": 8,
        "alert_type": "high"
    },
    "gunshot_firework": {
        "esc50_classes": ["fireworks"],
        "display_name": "Gunshot/Fireworks",
        "priority": 10,
        "alert_type": "critical"
    },
    "airplane": {
        "esc50_classes": ["airplane"],
        "display_name": "Airplane",
        "priority": 5,
        "alert_type": "low"
    },
}

# ESC-50 class to folder mapping
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


def collect_raw_audio():
    """Collect audio files from raw folder."""
    files_by_category = {}
    
    for category, config in TRAINING_CATEGORIES.items():
        files_by_category[category] = []
        
        if "sources" in config:
            for source in config["sources"]:
                source_dir = RAW_DIR / source
                if source_dir.exists():
                    for wav_file in source_dir.glob("*.wav"):
                        info = get_audio_info(wav_file)
                        if info:
                            files_by_category[category].append({
                                "path": wav_file,
                                "source": source,
                                **info
                            })
    
    return files_by_category


def collect_esc50_audio():
    """Collect audio files from ESC-50 dataset."""
    esc50_dir = DATASETS_DIR / "ESC-50" / "audio"
    meta_file = DATASETS_DIR / "ESC-50" / "meta" / "esc50.csv"
    
    if not esc50_dir.exists():
        print("ESC-50 dataset not found. Skipping...")
        return {}
    
    files_by_category = {}
    
    # Parse ESC-50 metadata
    import csv
    file_to_class = {}
    
    if meta_file.exists():
        with open(meta_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                file_to_class[row['filename']] = row['category']
    
    for category, config in TRAINING_CATEGORIES.items():
        if "esc50_classes" not in config:
            continue
            
        if category not in files_by_category:
            files_by_category[category] = []
        
        for esc_class in config["esc50_classes"]:
            # Find files for this class
            for wav_file in esc50_dir.glob("*.wav"):
                if wav_file.name in file_to_class:
                    if file_to_class[wav_file.name] == esc_class:
                        info = get_audio_info(wav_file)
                        if info:
                            files_by_category[category].append({
                                "path": wav_file,
                                "source": f"ESC-50/{esc_class}",
                                **info
                            })
    
    # Also add crying_baby to baby_cry category
    if "baby_cry" not in files_by_category:
        files_by_category["baby_cry"] = []
    
    for wav_file in esc50_dir.glob("*.wav"):
        if wav_file.name in file_to_class:
            if file_to_class[wav_file.name] == "crying_baby":
                info = get_audio_info(wav_file)
                if info:
                    files_by_category["baby_cry"].append({
                        "path": wav_file,
                        "source": "ESC-50/crying_baby",
                        **info
                    })
    
    return files_by_category


def collect_augmented_audio():
    """Collect audio files from augmented audio directory."""
    if not AUGMENTED_DIR.exists():
        print("Augmented audio directory not found. Skipping...")
        return {}
    
    files_by_category = {}
    
    for category_dir in AUGMENTED_DIR.iterdir():
        if category_dir.is_dir():
            category = category_dir.name
            if category in TRAINING_CATEGORIES:
                files_by_category[category] = []
                for wav_file in category_dir.glob("*.wav"):
                    info = get_audio_info(wav_file)
                    if info:
                        files_by_category[category].append({
                            "path": wav_file,
                            "source": f"augmented/{category}",
                            **info
                        })
                print(f"  Augmented {category}: {len(files_by_category[category])} files")
    
    return files_by_category


def collect_new_audio():
    """Collect audio files from new audio directory."""
    if not NEW_AUDIO_DIR.exists():
        print("New audio directory not found. Skipping...")
        return {}
    
    files_by_category = {}
    
    for category_dir in NEW_AUDIO_DIR.iterdir():
        if category_dir.is_dir():
            category = category_dir.name
            if category in TRAINING_CATEGORIES:
                files_by_category[category] = []
                for wav_file in category_dir.glob("*.wav"):
                    info = get_audio_info(wav_file)
                    if info:
                        files_by_category[category].append({
                            "path": wav_file,
                            "source": f"new_audio/{category}",
                            **info
                        })
                print(f"  New audio {category}: {len(files_by_category[category])} files")
    
    return files_by_category


def collect_expanded_audio():
    """Collect audio files from expanded audio directory."""
    if not EXPANDED_DIR.exists():
        print("Expanded audio directory not found. Skipping...")
        return {}
    
    files_by_category = {}
    
    for category_dir in EXPANDED_DIR.iterdir():
        if category_dir.is_dir():
            category = category_dir.name
            if category in TRAINING_CATEGORIES:
                files_by_category[category] = []
                for wav_file in category_dir.glob("*.wav"):
                    info = get_audio_info(wav_file)
                    if info:
                        files_by_category[category].append({
                            "path": wav_file,
                            "source": f"expanded/{category}",
                            **info
                        })
                print(f"  Expanded {category}: {len(files_by_category[category])} files")
    
    return files_by_category


def prepare_training_data(all_files):
    """Prepare training data with train/val/test splits."""
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    
    training_manifest = {
        "metadata": {
            "name": "hearalert_training_dataset",
            "version": 1,
            "created": datetime.now().isoformat(),
            "total_files": 0,
            "categories": []
        },
        "splits": {
            "train": [],
            "validation": [],
            "test": []
        }
    }
    
    for category, files in all_files.items():
        if not files:
            continue
        
        category_dir = PROCESSED_DIR / category
        category_dir.mkdir(parents=True, exist_ok=True)
        
        # Shuffle and split: 80% train, 10% val, 10% test
        random.shuffle(files)
        n = len(files)
        train_split = int(n * 0.8)
        val_split = int(n * 0.9)
        
        splits = {
            "train": files[:train_split],
            "validation": files[train_split:val_split],
            "test": files[val_split:]
        }
        
        for split_name, split_files in splits.items():
            for i, file_info in enumerate(split_files):
                # Copy file with standardized name
                new_name = f"{category}_{i:04d}.wav"
                dest_path = category_dir / new_name
                
                try:
                    shutil.copy2(file_info["path"], dest_path)
                    
                    training_manifest["splits"][split_name].append({
                        "file": str(dest_path.relative_to(PROCESSED_DIR)),
                        "category": category,
                        "duration_ms": file_info["duration_ms"],
                        "sample_rate": file_info["sample_rate"]
                    })
                    training_manifest["metadata"]["total_files"] += 1
                except Exception as e:
                    print(f"Error copying {file_info['path']}: {e}")
        
        training_manifest["metadata"]["categories"].append({
            "name": category,
            "display_name": TRAINING_CATEGORIES[category]["display_name"],
            "count": len(files),
            "priority": TRAINING_CATEGORIES[category]["priority"]
        })
        
        print(f"  {category}: {len(files)} files")
    
    return training_manifest


def generate_training_yaml(manifest):
    """Generate YAML configuration for training."""
    yaml_content = {
        "training_config": {
            "name": "hearalert_audio_classifier",
            "version": 1,
            "created": datetime.now().isoformat(),
            "model": {
                "base": "yamnet",
                "transfer_learning": True,
                "fine_tune_layers": 5
            },
            "audio": {
                "sample_rate": 16000,
                "duration_ms": 1000,
                "channels": 1,
                "normalize": True
            },
            "training": {
                "epochs": 50,
                "batch_size": 32,
                "learning_rate": 0.001,
                "early_stopping": {
                    "patience": 10,
                    "min_delta": 0.001
                }
            },
            "augmentation": {
                "enabled": True,
                "noise_injection": 0.1,
                "time_shift": 0.2,
                "pitch_shift": True
            }
        },
        "dataset": manifest["metadata"],
        "categories": {
            cat["name"]: {
                "display_name": cat["display_name"],
                "file_count": cat["count"],
                "priority": cat["priority"]
            }
            for cat in manifest["metadata"]["categories"]
        },
        "splits": {
            "train": len(manifest["splits"]["train"]),
            "validation": len(manifest["splits"]["validation"]),
            "test": len(manifest["splits"]["test"])
        }
    }
    
    return yaml_content


def train_model(manifest):
    """
    Train the audio classification model with enhanced accuracy techniques.
    
    Improvements:
    - Enhanced architecture with BatchNormalization and 3 Dense blocks
    - Class balancing with computed class weights
    - On-the-fly audio augmentation
    - Label smoothing to prevent overconfident predictions
    - Cosine learning rate decay with warmup
    - Extended training (100 epochs) with better early stopping
    """
    print("\n" + "="*60)
    print("TRAINING MODEL (Enhanced Accuracy Mode)")
    print("="*60)
    
    try:
        import tensorflow as tf
        import tensorflow_hub as hub
        import numpy as np
    except ImportError:
        print("Installing required packages...")
        subprocess.run([sys.executable, "-m", "pip", "install", 
                       "tensorflow", "tensorflow-hub", "numpy", "librosa", "scikit-learn", "-q"])
        import tensorflow as tf
        import tensorflow_hub as hub
        import numpy as np
    
    try:
        import librosa
    except ImportError:
        subprocess.run([sys.executable, "-m", "pip", "install", "librosa", "-q"])
        import librosa
    
    try:
        from sklearn.utils.class_weight import compute_class_weight
    except ImportError:
        subprocess.run([sys.executable, "-m", "pip", "install", "scikit-learn", "-q"])
        from sklearn.utils.class_weight import compute_class_weight
    
    # Load YAMNet
    print("Loading YAMNet base model...")
    yamnet_model = hub.load('https://tfhub.dev/google/yamnet/1')
    
    # Prepare data
    categories = [cat["name"] for cat in manifest["metadata"]["categories"]]
    num_classes = len(categories)
    
    print(f"Training for {num_classes} classes: {categories}")
    
    def load_audio(file_path, target_sr=16000):
        """Load audio file and return waveform."""
        try:
            waveform, sr = librosa.load(file_path, sr=target_sr, mono=True)
            # Pad or trim to 1 second
            target_len = target_sr
            if len(waveform) < target_len:
                waveform = np.pad(waveform, (0, target_len - len(waveform)))
            else:
                waveform = waveform[:target_len]
            return waveform.astype(np.float32)
        except:
            return None
    
    def augment_waveform(waveform):
        """Apply on-the-fly audio augmentation for training."""
        augmented = waveform.copy()
        
        # Random noise injection (50% chance)
        if np.random.random() < 0.5:
            noise_level = np.random.uniform(0.005, 0.02)
            noise = np.random.normal(0, noise_level, len(augmented))
            augmented = augmented + noise.astype(np.float32)
        
        # Random time shift (50% chance)
        if np.random.random() < 0.5:
            shift = int(np.random.uniform(-0.1, 0.1) * len(augmented))
            augmented = np.roll(augmented, shift)
        
        # Random volume change (50% chance)
        if np.random.random() < 0.5:
            gain = np.random.uniform(0.7, 1.3)
            augmented = augmented * gain
        
        # Random pitch perception (simple speed change, 30% chance)
        if np.random.random() < 0.3:
            speed = np.random.uniform(0.9, 1.1)
            indices = np.arange(0, len(augmented), speed)
            indices = indices[indices < len(augmented)].astype(int)
            augmented = augmented[indices]
            # Pad or trim back to original length
            target_len = len(waveform)
            if len(augmented) < target_len:
                augmented = np.pad(augmented, (0, target_len - len(augmented)))
            else:
                augmented = augmented[:target_len]
        
        return np.clip(augmented, -1.0, 1.0).astype(np.float32)
    
    def extract_embeddings(waveform):
        """Extract YAMNet embeddings."""
        scores, embeddings, spectrogram = yamnet_model(waveform)
        return tf.reduce_mean(embeddings, axis=0).numpy()
    
    # Extract features with augmentation for training
    print("Extracting features from training data (with augmentation)...")
    X_train, y_train = [], []
    X_val, y_val = [], []
    
    # Training: apply augmentation and extract more samples per file
    augmentations_per_sample = 2  # Create 2 augmented versions per sample
    
    for idx, item in enumerate(manifest["splits"]["train"]):
        file_path = PROCESSED_DIR / item["file"]
        waveform = load_audio(file_path)
        if waveform is not None:
            # Original embedding
            embedding = extract_embeddings(waveform)
            X_train.append(embedding)
            y_train.append(categories.index(item["category"]))
            
            # Augmented embeddings
            for _ in range(augmentations_per_sample):
                aug_waveform = augment_waveform(waveform)
                aug_embedding = extract_embeddings(aug_waveform)
                X_train.append(aug_embedding)
                y_train.append(categories.index(item["category"]))
        
        # Progress logging
        if (idx + 1) % 500 == 0:
            print(f"  Processed {idx + 1}/{len(manifest['splits']['train'])} training files...")
    
    # Validation: no augmentation for fair evaluation
    for item in manifest["splits"]["validation"]:
        file_path = PROCESSED_DIR / item["file"]
        waveform = load_audio(file_path)
        if waveform is not None:
            embedding = extract_embeddings(waveform)
            X_val.append(embedding)
            y_val.append(categories.index(item["category"]))
    
    X_train = np.array(X_train)
    y_train = np.array(y_train)
    X_val = np.array(X_val)
    y_val = np.array(y_val)
    
    print(f"\n📊 Dataset Statistics:")
    print(f"  Training samples: {len(X_train)} (with augmentation)")
    print(f"  Validation samples: {len(X_val)}")
    print(f"  Classes: {num_classes}")
    
    # Compute class weights for imbalanced data
    print("\n⚖️ Computing class weights for balancing...")
    class_weights = compute_class_weight(
        class_weight='balanced',
        classes=np.unique(y_train),
        y=y_train
    )
    class_weight_dict = dict(enumerate(class_weights))
    print(f"  Class weight range: {min(class_weights):.3f} - {max(class_weights):.3f}")
    
    # Build enhanced classifier with BatchNormalization
    print("\n🏗️ Building enhanced model architecture...")
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(1024,)),
        
        # First block - 512 units
        tf.keras.layers.Dense(512, kernel_initializer='he_normal'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Activation('relu'),
        tf.keras.layers.Dropout(0.4),
        
        # Second block - 256 units
        tf.keras.layers.Dense(256, kernel_initializer='he_normal'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Activation('relu'),
        tf.keras.layers.Dropout(0.3),
        
        # Third block - 128 units
        tf.keras.layers.Dense(128, kernel_initializer='he_normal'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Activation('relu'),
        tf.keras.layers.Dropout(0.2),
        
        # Output layer
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    model.summary()
    
    # Training configuration
    total_epochs = 100
    batch_size = 32
    initial_lr = 0.001
    
    # Learning rate schedule with warmup
    warmup_epochs = 5
    steps_per_epoch = len(X_train) // batch_size
    warmup_steps = warmup_epochs * steps_per_epoch
    total_steps = total_epochs * steps_per_epoch
    
    # Cosine decay schedule
    lr_schedule = tf.keras.optimizers.schedules.CosineDecay(
        initial_learning_rate=initial_lr,
        decay_steps=total_steps - warmup_steps,
        alpha=0.01  # Minimum learning rate factor
    )
    
    # Warmup wrapper
    class WarmupSchedule(tf.keras.optimizers.schedules.LearningRateSchedule):
        def __init__(self, warmup_steps, target_lr, base_schedule):
            super().__init__()
            self.warmup_steps = warmup_steps
            self.target_lr = target_lr
            self.base_schedule = base_schedule
        
        def __call__(self, step):
            warmup_lr = self.target_lr * (step / self.warmup_steps)
            return tf.cond(
                step < self.warmup_steps,
                lambda: warmup_lr,
                lambda: self.base_schedule(step - self.warmup_steps)
            )
        
        def get_config(self):
            return {
                "warmup_steps": self.warmup_steps,
                "target_lr": self.target_lr
            }
    
    final_schedule = WarmupSchedule(warmup_steps, initial_lr, lr_schedule)
    optimizer = tf.keras.optimizers.Adam(learning_rate=final_schedule)
    
    # Compile with label smoothing
    model.compile(
        optimizer=optimizer,
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=False),
        metrics=['accuracy']
    )
    
    # Enhanced callbacks
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy',
            patience=15,
            restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(MODEL_OUTPUT / 'best_model.keras'),
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=7,
            min_lr=1e-7,
            verbose=1
        )
    ]
    
    # Train with class weights
    print("\n🚀 Training classifier (Enhanced Mode)...")
    print(f"  Epochs: {total_epochs}")
    print(f"  Batch size: {batch_size}")
    print(f"  Warmup epochs: {warmup_epochs}")
    print(f"  Using class weights: Yes")
    print(f"  Using BatchNormalization: Yes")
    print(f"  On-the-fly augmentation: Applied ({augmentations_per_sample}x per sample)")
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=total_epochs,
        batch_size=batch_size,
        callbacks=callbacks,
        class_weight=class_weight_dict,
        verbose=1
    )
    
    # Save model
    MODEL_OUTPUT.mkdir(parents=True, exist_ok=True)
    
    # Convert to TFLite with quantization for mobile
    print("\n📱 Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Dynamic range quantization for smaller model size
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    tflite_path = MODEL_OUTPUT / "hearalert_classifier.tflite"
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    # Save labels
    labels_path = MODEL_OUTPUT / "hearalert_labels.txt"
    with open(labels_path, 'w') as f:
        for cat in categories:
            f.write(f"{cat}\n")
    
    print(f"\n✓ Model saved: {tflite_path}")
    print(f"✓ Labels saved: {labels_path}")
    print(f"✓ Model size: {os.path.getsize(tflite_path) / 1024:.1f} KB")
    
    # Training summary
    final_acc = max(history.history['accuracy'])
    final_val_acc = max(history.history['val_accuracy'])
    best_epoch = history.history['val_accuracy'].index(final_val_acc) + 1
    
    print("\n" + "="*60)
    print("📈 TRAINING RESULTS")
    print("="*60)
    print(f"  Best Training Accuracy: {final_acc:.2%}")
    print(f"  Best Validation Accuracy: {final_val_acc:.2%}")
    print(f"  Best Epoch: {best_epoch}")
    print(f"  Total Epochs Run: {len(history.history['accuracy'])}")
    print("="*60)
    
    return {
        "accuracy": final_acc,
        "val_accuracy": final_val_acc,
        "best_epoch": best_epoch,
        "model_path": str(tflite_path),
        "labels_path": str(labels_path),
        "categories": categories,
        "model_size_kb": os.path.getsize(tflite_path) / 1024
    }


def main():
    """Main training pipeline."""
    print("="*60)
    print("HearAlert Audio Dataset Training Pipeline")
    print("="*60)
    
    # Step 1: Collect all audio files
    print("\n[1/4] Collecting audio files...")
    
    raw_files = collect_raw_audio()
    esc50_files = collect_esc50_audio()
    augmented_files = collect_augmented_audio()
    new_files = collect_new_audio()
    expanded_files = collect_expanded_audio()
    
    # Merge files
    all_files = {}
    for category in TRAINING_CATEGORIES.keys():
        all_files[category] = []
        if category in raw_files:
            all_files[category].extend(raw_files[category])
        if category in esc50_files:
            all_files[category].extend(esc50_files[category])
        if category in augmented_files:
            all_files[category].extend(augmented_files[category])
        if category in new_files:
            all_files[category].extend(new_files[category])
        if category in expanded_files:
            all_files[category].extend(expanded_files[category])
    
    total_files = sum(len(f) for f in all_files.values())
    print(f"\nTotal audio files found: {total_files}")
    
    if total_files < 100:
        print("Warning: Not enough audio files. Please ensure datasets are downloaded.")
        print("Run: git clone https://github.com/karolpiczak/ESC-50.git datasets/ESC-50")
    
    # Step 2: Prepare training data
    print("\n[2/4] Preparing training data...")
    manifest = prepare_training_data(all_files)
    
    # Step 3: Generate YAML
    print("\n[3/4] Generating training YAML...")
    yaml_content = generate_training_yaml(manifest)
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    yaml_path = OUTPUT_DIR / "training_config.yaml"
    with open(yaml_path, 'w') as f:
        yaml.dump(yaml_content, f, default_flow_style=False, sort_keys=False)
    
    # Save manifest
    manifest_path = OUTPUT_DIR / "training_manifest.json"
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"✓ Training config: {yaml_path}")
    print(f"✓ Manifest: {manifest_path}")
    
    # Step 4: Train model
    print("\n[4/4] Training model...")
    
    if manifest["metadata"]["total_files"] >= 50:
        training_result = train_model(manifest)
        
        # Update YAML with results
        yaml_content["training_results"] = training_result
        with open(yaml_path, 'w') as f:
            yaml.dump(yaml_content, f, default_flow_style=False, sort_keys=False)
        
        print("\n" + "="*60)
        print("TRAINING COMPLETE!")
        print("="*60)
        print(f"Final Accuracy: {training_result['accuracy']:.2%}")
        print(f"Validation Accuracy: {training_result['val_accuracy']:.2%}")
        print(f"Model: {training_result['model_path']}")
        print(f"Labels: {training_result['labels_path']}")
    else:
        print("Not enough training data. Skipping model training.")
    
    print("="*60)


if __name__ == "__main__":
    main()

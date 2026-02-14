#!/usr/bin/env python3
"""
Convert RAW Audio to Dataset for Real-Time Use Cases
=====================================================

This script processes the raw WAV audio files and organizes them into a
structured dataset format suitable for real-time audio classification.

Categories:
- Baby sounds: belly_pain, burping, cold_hot, discomfort, hungry, tired, silence
- Animal sounds: Cow, Dog, Frog
"""

import os
import shutil
import wave
import json
import yaml
from pathlib import Path
from datetime import datetime
import hashlib

# Configuration
RAW_DIR = Path(__file__).parent / "raw"
OUTPUT_DIR = Path(__file__).parent / "mobile_app" / "assets" / "datasets"
PROCESSED_DIR = Path(__file__).parent / "processed_dataset"

# Category mappings for real-time scenarios
CATEGORIES = {
    # Baby sounds
    "belly_pain": {
        "display_name": "Baby Belly Pain",
        "icon": "baby",
        "color": "#FF6B6B",
        "priority": 9,
        "alert_type": "critical",
        "vibration_pattern": [0, 500, 200, 500, 200, 500],
        "confidence_threshold": 0.35
    },
    "burping": {
        "display_name": "Baby Burping",
        "icon": "baby",
        "color": "#4ECDC4",
        "priority": 4,
        "alert_type": "low",
        "vibration_pattern": [0, 100, 100, 100],
        "confidence_threshold": 0.45
    },
    "cold_hot": {
        "display_name": "Baby Cold/Hot Discomfort",
        "icon": "thermometer",
        "color": "#FFE66D",
        "priority": 8,
        "alert_type": "high",
        "vibration_pattern": [0, 400, 150, 400],
        "confidence_threshold": 0.40
    },
    "discomfort": {
        "display_name": "Baby Discomfort",
        "icon": "baby",
        "color": "#FF9F43",
        "priority": 7,
        "alert_type": "high",
        "vibration_pattern": [0, 300, 150, 300, 150, 300],
        "confidence_threshold": 0.40
    },
    "hungry": {
        "display_name": "Baby Hungry",
        "icon": "utensils",
        "color": "#FF6B9D",
        "priority": 9,
        "alert_type": "critical",
        "vibration_pattern": [0, 500, 200, 500],
        "confidence_threshold": 0.35
    },
    "tired": {
        "display_name": "Baby Tired",
        "icon": "moon",
        "color": "#A66DD4",
        "priority": 6,
        "alert_type": "medium",
        "vibration_pattern": [0, 250, 100, 250],
        "confidence_threshold": 0.42
    },
    "silence": {
        "display_name": "Silence/Background",
        "icon": "volume-off",
        "color": "#95A5A6",
        "priority": 1,
        "alert_type": "none",
        "vibration_pattern": [],
        "confidence_threshold": 0.50
    },
    # Animal sounds
    "Cow": {
        "display_name": "Cow Mooing",
        "icon": "cow",
        "color": "#8B4513",
        "priority": 5,
        "alert_type": "medium",
        "vibration_pattern": [0, 200, 100, 200],
        "confidence_threshold": 0.40
    },
    "Dog": {
        "display_name": "Dog Barking",
        "icon": "dog",
        "color": "#D4A373",
        "priority": 7,
        "alert_type": "high",
        "vibration_pattern": [0, 300, 100, 300, 100, 300],
        "confidence_threshold": 0.38
    },
    "Frog": {
        "display_name": "Frog Croaking",
        "icon": "frog",
        "color": "#228B22",
        "priority": 3,
        "alert_type": "low",
        "vibration_pattern": [0, 150, 100, 150],
        "confidence_threshold": 0.45
    }
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
                "duration_ms": int((wf.getnframes() / wf.getframerate()) * 1000),
                "file_size": os.path.getsize(wav_path)
            }
    except Exception as e:
        print(f"Error reading {wav_path}: {e}")
        return None


def get_file_hash(file_path):
    """Generate MD5 hash of file for deduplication."""
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def process_category(category_name, category_dir, output_category_dir):
    """Process all WAV files in a category directory."""
    files_info = []
    
    if not category_dir.exists():
        print(f"Category directory not found: {category_dir}")
        return files_info
    
    # Create output directory
    output_category_dir.mkdir(parents=True, exist_ok=True)
    
    wav_files = list(category_dir.glob("*.wav"))
    print(f"Processing {len(wav_files)} files in {category_name}...")
    
    for wav_file in wav_files:
        audio_info = get_audio_info(wav_file)
        if audio_info is None:
            continue
        
        # Copy file to processed directory
        new_filename = f"{category_name}_{wav_file.stem}.wav"
        dest_path = output_category_dir / new_filename
        shutil.copy2(wav_file, dest_path)
        
        files_info.append({
            "filename": new_filename,
            "original_filename": wav_file.name,
            "category": category_name,
            **audio_info,
            "hash": get_file_hash(wav_file)
        })
    
    return files_info


def generate_category_yaml(category_name, category_config, files_info):
    """Generate YAML configuration for a category."""
    total_duration = sum(f["duration_ms"] for f in files_info)
    total_size = sum(f["file_size"] for f in files_info)
    
    # Get sample rate distribution
    sample_rates = {}
    for f in files_info:
        sr = f["sample_rate"]
        sample_rates[sr] = sample_rates.get(sr, 0) + 1
    
    yaml_content = {
        "metadata": {
            "name": category_name.lower(),
            "display_name": category_config["display_name"],
            "source": "HearAlert Raw Dataset",
            "version": 1,
            "date_modified": datetime.now().isoformat() + "Z",
            "total_files": len(files_info),
            "total_duration_ms": total_duration,
            "total_size_bytes": total_size,
            "sample_rates": sample_rates
        },
        "description": f"Audio samples of {category_config['display_name']} for real-time detection in HearAlert app.",
        "simulation": {
            "enabled": True,
            "mode": "random",
            "scenarios": generate_scenarios(category_name, category_config)
        },
        "alerts": {
            category_name.lower(): {
                "icon": category_config["icon"],
                "color": category_config["color"],
                "vibration_pattern": category_config["vibration_pattern"],
                "flash_pattern": get_flash_pattern(category_config["alert_type"]),
                "message": f"{category_config['display_name']} Detected!",
                "urgent_message": f"⚠️ {category_config['display_name'].upper()} - NEEDS ATTENTION!" if category_config["priority"] >= 7 else None
            }
        },
        "detection": {
            "confidence_threshold": category_config["confidence_threshold"],
            "priority": category_config["priority"],
            "alert_type": category_config["alert_type"]
        },
        "files": [
            {
                "filename": f["filename"],
                "duration_ms": f["duration_ms"],
                "sample_rate": f["sample_rate"]
            }
            for f in files_info[:20]  # Include only first 20 for readability
        ],
        "integration": {
            "audio_classifier_service": {
                "enabled": True,
                "buffer_size": 15600
            },
            "alert_service": {
                "enabled": True,
                "priority_sound": category_config["priority"] >= 7
            },
            "notification_service": {
                "enabled": True,
                "sound_alert": False,
                "vibration": len(category_config["vibration_pattern"]) > 0,
                "visual_flash": category_config["alert_type"] != "none"
            }
        }
    }
    
    return yaml_content


def generate_scenarios(category_name, category_config):
    """Generate test scenarios for a category."""
    scenarios = []
    
    if category_config["alert_type"] == "critical":
        scenarios.append({
            "name": f"High Intensity {category_config['display_name']}",
            "description": f"Urgent {category_name} detection",
            "confidence_range": [0.75, 0.95],
            "duration_ms": 4000,
            "alert_priority": "critical"
        })
        scenarios.append({
            "name": f"Normal {category_config['display_name']}",
            "description": f"Standard {category_name} detection",
            "confidence_range": [0.50, 0.75],
            "duration_ms": 3000,
            "alert_priority": "high"
        })
    elif category_config["alert_type"] == "high":
        scenarios.append({
            "name": f"Strong {category_config['display_name']}",
            "description": f"Clear {category_name} detection",
            "confidence_range": [0.60, 0.85],
            "duration_ms": 3500,
            "alert_priority": "high"
        })
        scenarios.append({
            "name": f"Moderate {category_config['display_name']}",
            "description": f"Moderate {category_name} intensity",
            "confidence_range": [0.40, 0.60],
            "duration_ms": 2500,
            "alert_priority": "medium"
        })
    elif category_config["alert_type"] == "medium":
        scenarios.append({
            "name": f"Regular {category_config['display_name']}",
            "description": f"Normal {category_name} detection",
            "confidence_range": [0.45, 0.70],
            "duration_ms": 3000,
            "alert_priority": "medium"
        })
    elif category_config["alert_type"] == "low":
        scenarios.append({
            "name": f"Soft {category_config['display_name']}",
            "description": f"Low intensity {category_name}",
            "confidence_range": [0.40, 0.60],
            "duration_ms": 2000,
            "alert_priority": "low"
        })
    elif category_config["alert_type"] == "none":
        scenarios.append({
            "name": "Background Silence",
            "description": "No significant audio detected",
            "confidence_range": [0.50, 0.90],
            "duration_ms": 1000,
            "alert_priority": "none"
        })
    
    return scenarios


def get_flash_pattern(alert_type):
    """Get flash pattern based on alert type."""
    patterns = {
        "critical": "rapid",
        "high": "fast",
        "medium": "medium",
        "low": "slow",
        "none": "none"
    }
    return patterns.get(alert_type, "medium")


def generate_master_dataset_yaml(all_categories_info):
    """Generate master dataset configuration."""
    total_files = sum(len(info["files"]) for info in all_categories_info.values())
    total_size = sum(sum(f["file_size"] for f in info["files"]) for info in all_categories_info.values())
    
    yaml_content = {
        "metadata": {
            "name": "hearalert_complete_dataset",
            "display_name": "HearAlert Complete Audio Dataset",
            "description": "Complete audio dataset for real-time sound classification",
            "version": 1,
            "date_created": datetime.now().isoformat() + "Z",
            "total_categories": len(all_categories_info),
            "total_files": total_files,
            "total_size_bytes": total_size
        },
        "categories": {
            "baby_sounds": {
                "display_name": "Baby Sounds",
                "description": "Various baby cry types for parent alerts",
                "subcategories": ["belly_pain", "burping", "cold_hot", "discomfort", "hungry", "tired", "silence"]
            },
            "animal_sounds": {
                "display_name": "Animal Sounds",
                "description": "Animal sounds for environment awareness",
                "subcategories": ["cow", "dog", "frog"]
            }
        },
        "category_configs": {
            name.lower(): {
                "display_name": CATEGORIES[name]["display_name"],
                "file_count": len(info["files"]),
                "priority": CATEGORIES[name]["priority"],
                "alert_type": CATEGORIES[name]["alert_type"],
                "color": CATEGORIES[name]["color"]
            }
            for name, info in all_categories_info.items()
        },
        "real_time_config": {
            "audio_format": {
                "sample_rate": 16000,
                "channels": 1,
                "bit_depth": 16
            },
            "detection": {
                "buffer_size_ms": 1000,
                "overlap_ms": 500,
                "min_confidence": 0.35
            },
            "alerts": {
                "enabled": True,
                "vibration": True,
                "visual_flash": True,
                "sound": False
            }
        }
    }
    
    return yaml_content


def main():
    """Main processing function."""
    print("=" * 60)
    print("HearAlert Raw Audio to Dataset Converter")
    print("=" * 60)
    
    # Create output directories
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    all_categories_info = {}
    
    # Process each category
    for category_name, category_config in CATEGORIES.items():
        print(f"\n--- Processing: {category_name} ---")
        
        category_dir = RAW_DIR / category_name
        output_category_dir = PROCESSED_DIR / category_name.lower()
        
        files_info = process_category(category_name, category_dir, output_category_dir)
        
        if files_info:
            all_categories_info[category_name] = {"files": files_info, "config": category_config}
            
            # Generate individual category YAML
            yaml_content = generate_category_yaml(category_name, category_config, files_info)
            yaml_path = OUTPUT_DIR / f"{category_name.lower()}_dataset.yaml"
            
            with open(yaml_path, 'w') as f:
                yaml.dump(yaml_content, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
            
            print(f"  ✓ Generated: {yaml_path.name}")
            print(f"  ✓ Files processed: {len(files_info)}")
        else:
            print(f"  ⚠ No files found for {category_name}")
    
    # Generate master dataset YAML
    if all_categories_info:
        master_yaml = generate_master_dataset_yaml(all_categories_info)
        master_path = OUTPUT_DIR / "hearalert_dataset.yaml"
        
        with open(master_path, 'w') as f:
            yaml.dump(master_yaml, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        
        print(f"\n✓ Master dataset config: {master_path.name}")
    
    # Generate summary JSON for quick reference
    summary = {
        "generated_at": datetime.now().isoformat(),
        "categories": {
            name: {
                "file_count": len(info["files"]),
                "total_duration_ms": sum(f["duration_ms"] for f in info["files"]),
                "total_size_bytes": sum(f["file_size"] for f in info["files"]),
            }
            for name, info in all_categories_info.items()
        }
    }
    
    summary_path = OUTPUT_DIR / "dataset_summary.json"
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    
    print(f"\n✓ Summary: {summary_path.name}")
    
    # Print final summary
    print("\n" + "=" * 60)
    print("CONVERSION COMPLETE")
    print("=" * 60)
    print(f"Total categories: {len(all_categories_info)}")
    print(f"Total files: {sum(len(info['files']) for info in all_categories_info.values())}")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"Processed files: {PROCESSED_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    main()

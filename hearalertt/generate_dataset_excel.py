#!/usr/bin/env python3
import os
import glob
import yaml
import wave
import pandas as pd
from pathlib import Path
from datetime import datetime

# Configuration
BASE_DIR = Path(__file__).parent
DATASETS_DIR = BASE_DIR / "training_data"
YAML_CONFIG = BASE_DIR / "mobile_app/assets/datasets/hearalert_dataset.yaml"
OUTPUT_FILE = BASE_DIR / "dataset_report.xlsx"

def get_audio_info(file_path):
    """Get duration and sample rate of a wav file."""
    try:
        with wave.open(str(file_path), 'rb') as wf:
            frames = wf.getnframes()
            rate = wf.getframerate()
            duration = frames / float(rate)
            return duration, rate, wf.getnchannels(), wf.getsampwidth()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return 0, 0, 0, 0

def load_yaml_config(yaml_path):
    """Load the dataset configuration from YAML."""
    if not yaml_path.exists():
        print(f"Warning: YAML config not found at {yaml_path}")
        return {}
    
    with open(yaml_path, 'r') as f:
        try:
            return yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"Error parsing YAML: {e}")
            return {}

def main():
    print(f"Starting dataset report generation...")
    
    # 1. Load Categories Metadata
    config = load_yaml_config(YAML_CONFIG)
    categories_meta = {}
    if 'categories' in config:
        for cat in config['categories']:
            categories_meta[cat['id']] = cat

    # 2. Scan Files
    data = []
    
    if not DATASETS_DIR.exists():
        print(f"Error: Training data directory not found at {DATASETS_DIR}")
        return

    print(f"Scanning {DATASETS_DIR}...")
    
    # Walk through the directory
    for root, dirs, files in os.walk(DATASETS_DIR):
        # Exclude 'datasets copy' and hidden directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and 'copy' not in d.lower()]
        
        for file in files:
            if file.lower().endswith('.wav'):
                file_path = Path(root) / file
                category_name = file_path.parent.name
                
                # Basic file stats
                file_size_kb = os.path.getsize(file_path) / 1024
                
                # Audio stats
                duration, sample_rate, channels, sampwidth = get_audio_info(file_path)
                
                # Metadata from YAML
                cat_meta = categories_meta.get(category_name, {})
                
                # Fallback for display name
                display_name = cat_meta.get('display_name')
                if not display_name:
                    display_name = category_name.replace('_', ' ').title()

                row = {
                    "Filename": file,
                    "Category ID": category_name,
                    "Category Name": display_name,
                    "Priority": cat_meta.get('priority', 'N/A'),
                    "Alert Type": cat_meta.get('alert_type', 'N/A'),
                    "Duration (s)": round(duration, 2),
                    "Size (KB)": round(file_size_kb, 2),
                    "Sample Rate": sample_rate,
                    "Channels": channels,
                    "Bit Depth": sampwidth * 8,
                    "Path": str(file_path.relative_to(BASE_DIR))
                }
                data.append(row)

    # 3. Create DataFrame and Export
    if not data:
        print("No wav files found.")
        return

    df = pd.DataFrame(data)
    
    # Reorder columns if needed (optional, pandas preserves dict order mostly in recent versions)
    columns = [
        "Category Name", "Category ID", "Priority", "Alert Type", 
        "Filename", "Duration (s)", "Size (KB)", 
        "Sample Rate", "Channels", "Bit Depth", "Path"
    ]
    # Filter columns that exist in data
    columns = [c for c in columns if c in df.columns]
    df = df[columns]

    # Sort
    df = df.sort_values(by=["Priority", "Category Name", "Filename"], ascending=[False, True, True])

    # Summary Sheet
    summary = df.groupby('Category Name').agg({
        'Filename': 'count',
        'Duration (s)': 'sum',
        'Size (KB)': 'sum'
    }).rename(columns={'Filename': 'File Count', 'Duration (s)': 'Total Duration (s)', 'Size (KB)': 'Total Size (KB)'})
    
    # Save to Excel
    try:
        with pd.ExcelWriter(OUTPUT_FILE, engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name='All Files', index=False)
            summary.to_excel(writer, sheet_name='Summary')
        
        print(f"Successfully generated report at: {OUTPUT_FILE}")
        print(f"Total files: {len(df)}")
        print("Summary:")
        print(summary)
        
    except ImportError as e:
        print("Error: Pandas or openpyxl is not installed. Please install them to generate Excel files.")
        print("Run: pip install pandas openpyxl pyyaml")
        # Fallback to CSV
        csv_file = OUTPUT_FILE.with_suffix('.csv')
        df.to_csv(csv_file, index=False)
        print(f"Fallback: Generated CSV report at {csv_file}")
    except Exception as e:
        print(f"An error occurred during export: {e}")

if __name__ == "__main__":
    main()

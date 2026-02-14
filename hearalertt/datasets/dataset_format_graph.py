#!/usr/bin/env python3
"""
Audio Dataset Format Graph Generator for HearAlert
Creates a comprehensive visualization of all datasets and their audio formats
Exports as PDF
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np
from pathlib import Path
import yaml
import os

def load_dataset_info():
    """Load information about all datasets"""
    datasets = {}
    
    # ESC-50 Dataset
    datasets['ESC-50'] = {
        'name': 'ESC-50 (Environmental Sound Classification)',
        'format': 'WAV',
        'sample_rate': '44100 Hz',
        'bit_depth': '16-bit',
        'channels': 'Mono',
        'duration': '5 seconds',
        'file_count': 2000,
        'categories': 50,
        'source': 'GitHub karolpiczak/ESC-50'
    }
    
    # HearAlert Custom Datasets (from YAML files)
    yaml_dir = Path('/Users/abu/hearalert_version_1.1/hearalertt/mobile_app/assets/datasets')
    
    custom_datasets = {
        'Baby Crying': {'file_count': 80, 'priority': 10},
        'Car Horn': {'file_count': 40, 'priority': 10},
        'Emergency Siren': {'file_count': 40, 'priority': 10},
        'Fire Alarm': {'file_count': 80, 'priority': 10},
        'Smoke Alarm': {'file_count': 80, 'priority': 10},
        'Gunshot/Fireworks': {'file_count': 40, 'priority': 10},
        'Train': {'file_count': 40, 'priority': 9},
        'Glass Breaking': {'file_count': 40, 'priority': 9},
        'Traffic/Vehicle': {'file_count': 80, 'priority': 8},
        'Door Knock': {'file_count': 80, 'priority': 8},
        'Doorbell': {'file_count': 40, 'priority': 8},
        'Human Voice/Speech': {'file_count': 120, 'priority': 8},
        'Door Opening': {'file_count': 40, 'priority': 8},
        'Power Tools': {'file_count': 80, 'priority': 8},
        'Phone Ring': {'file_count': 40, 'priority': 7},
        'Dog Barking': {'file_count': 40, 'priority': 7},
        'Thunderstorm': {'file_count': 40, 'priority': 7},
        'Coughing': {'file_count': 40, 'priority': 7},
        'Heavy Breathing': {'file_count': 80, 'priority': 7},
        'Helicopter': {'file_count': 40, 'priority': 6},
        'Footsteps': {'file_count': 40, 'priority': 6},
        'Washing Machine': {'file_count': 40, 'priority': 6},
        'Cat Meowing': {'file_count': 40, 'priority': 5},
        'Vacuum Cleaner': {'file_count': 40, 'priority': 5},
        'Airplane': {'file_count': 40, 'priority': 5},
        'Keyboard/Mouse': {'file_count': 80, 'priority': 4},
        'Clock Ticking': {'file_count': 40, 'priority': 4},
    }
    
    datasets['HearAlert Custom'] = {
        'name': 'HearAlert Real-Time Classifier v3.0',
        'format': 'WAV',
        'sample_rate': '16000 Hz',
        'bit_depth': '16-bit',
        'channels': 'Mono',
        'duration': '5 seconds',
        'file_count': sum(d['file_count'] for d in custom_datasets.values()),
        'categories': len(custom_datasets),
        'source': 'Custom Generated + Downloaded',
        'custom_categories': custom_datasets
    }
    
    return datasets

def create_dataset_graph():
    """Create comprehensive visualization of all datasets"""
    datasets = load_dataset_info()
    
    # Create figure with subplots - Optimized size for better compression
    fig = plt.figure(figsize=(20, 14))
    fig.patch.set_facecolor('white')
    
    # Main title with professional styling
    fig.suptitle('HearAlert Audio Datasets - Complete Overview', \
                 fontsize=24, fontweight='bold', y=0.985, color='#2C3E50')
    
    # Create grid with improved spacing and alignment
    gs = fig.add_gridspec(3, 2, hspace=0.38, wspace=0.32, 
                         left=0.06, right=0.96, top=0.95, bottom=0.04)
    
    # ==================== SUBPLOT 1: Dataset Overview ====================
    ax1 = fig.add_subplot(gs[0, :])
    ax1.axis('off')
    
    # Improved positioning for better alignment
    y_top = 0.85
    box_height = 0.45
    x_left = 0.05
    x_right = 0.53
    box_width = 0.42
    
    # ESC-50 Dataset - Fixed alignment
    rect1 = FancyBboxPatch((x_left, y_top - box_height), box_width, box_height,
                          boxstyle="round,pad=0.02", 
                          edgecolor='#2E86AB', facecolor='#EBF5FB', 
                          linewidth=3)
    ax1.add_patch(rect1)
    
    # Title
    ax1.text(x_left + box_width/2, y_top - 0.06, 'ESC-50 Dataset', 
            ha='center', va='top', fontsize=16, fontweight='bold', color='#2E86AB')
    
    # Content with proper line spacing
    esc_info = datasets['ESC-50']
    esc_lines = [
        f"Format: {esc_info['format']}  |  Sample Rate: {esc_info['sample_rate']}",
        f"Bit Depth: {esc_info['bit_depth']}  |  Channels: {esc_info['channels']}",
        f"Duration: {esc_info['duration']}  |  Files: {esc_info['file_count']:,}",
        f"Categories: {esc_info['categories']}  |  Source: {esc_info['source']}"
    ]
    
    y_line = y_top - 0.15
    for line in esc_lines:
        ax1.text(x_left + box_width/2, y_line, line,
                ha='center', va='top', fontsize=10, 
                family='monospace', color='#34495E')
        y_line -= 0.08
    
    # HearAlert Custom Dataset - Fixed alignment
    rect2 = FancyBboxPatch((x_right, y_top - box_height), box_width, box_height,
                          boxstyle="round,pad=0.02", 
                          edgecolor='#A23B72', facecolor='#FDF2F8', 
                          linewidth=3)
    ax1.add_patch(rect2)
    
    # Title
    ax1.text(x_right + box_width/2, y_top - 0.06, 'HearAlert Custom Datasets', 
            ha='center', va='top', fontsize=16, fontweight='bold', color='#A23B72')
    
    # Content with proper line spacing
    custom_info = datasets['HearAlert Custom']
    custom_lines = [
        f"Format: {custom_info['format']}  |  Sample Rate: {custom_info['sample_rate']}",
        f"Bit Depth: {custom_info['bit_depth']}  |  Channels: {custom_info['channels']}",
        f"Duration: {custom_info['duration']}  |  Files: {custom_info['file_count']:,}",
        f"Categories: {custom_info['categories']}  |  Source: {custom_info['source']}"
    ]
    
    y_line = y_top - 0.15
    for line in custom_lines:
        ax1.text(x_right + box_width/2, y_line, line,
                ha='center', va='top', fontsize=10, 
                family='monospace', color='#34495E')
        y_line -= 0.08
    
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)
    
    # ==================== SUBPLOT 2: Audio Format Specs ====================
    ax2 = fig.add_subplot(gs[1, 0])
    ax2.axis('off')
    ax2.set_title('Audio Format Specifications', fontsize=16, fontweight='bold', pad=20, color='#2C3E50')
    
    format_data = [
        ['Dataset', 'Format', 'Sample Rate', 'Bit Depth', 'Channels'],
        ['ESC-50', 'WAV (PCM)', '44.1 kHz', '16-bit', 'Mono'],
        ['HearAlert Custom', 'WAV (PCM)', '16 kHz', '16-bit', 'Mono'],
    ]
    
    table1 = ax2.table(cellText=format_data, cellLoc='center', loc='center',
                      bbox=[0, 0.25, 1, 0.65])
    table1.auto_set_font_size(False)
    table1.set_fontsize(11)
    table1.scale(1, 2.8)
    
    # Style header row with professional colors
    for i in range(5):
        cell = table1[(0, i)]
        cell.set_facecolor('#2C3E50')
        cell.set_text_props(weight='bold', color='white', size=12)
        cell.set_edgecolor('#34495E')
        cell.set_linewidth(1.5)
    
    # Style data rows with better contrast
    for i in range(1, 3):
        for j in range(5):
            cell = table1[(i, j)]
            cell.set_facecolor('#EBF5FB' if i % 2 == 0 else '#FAFBFC')
            cell.set_edgecolor('#BDC3C7')
            cell.set_linewidth(1.2)
    
    # ==================== SUBPLOT 3: File Statistics ====================
    ax3 = fig.add_subplot(gs[1, 1])
    ax3.set_title('Dataset File Counts', fontsize=16, fontweight='bold', pad=20, color='#2C3E50')
    
    dataset_names = ['ESC-50\n(50 categories)', 'HearAlert Custom\n(27 categories)']
    file_counts = [datasets['ESC-50']['file_count'], datasets['HearAlert Custom']['file_count']]
    colors = ['#2E86AB', '#A23B72']
    
    bars = ax3.bar(dataset_names, file_counts, color=colors, alpha=0.85, 
                   edgecolor='#34495E', linewidth=2.5, width=0.6)
    
    # Add value labels on bars with better styling
    for bar, count in zip(bars, file_counts):
        height = bar.get_height()
        ax3.text(bar.get_x() + bar.get_width()/2., height,
                f'{count:,} files',
                ha='center', va='bottom', fontsize=13, fontweight='bold', color='#2C3E50')
    
    ax3.set_ylabel('Number of Audio Files', fontsize=13, fontweight='bold', color='#34495E', labelpad=10)
    ax3.grid(axis='y', alpha=0.25, linestyle='--', linewidth=0.8, color='#BDC3C7')
    ax3.set_axisbelow(True)
    
    # ==================== SUBPLOT 4: HearAlert Categories by Priority ====================
    ax4 = fig.add_subplot(gs[2, :])
    ax4.axis('off')
    ax4.set_title('HearAlert Custom Dataset Categories (by Priority Level)', 
                  fontsize=16, fontweight='bold', pad=20, color='#2C3E50')
    
    custom_cats = datasets['HearAlert Custom']['custom_categories']
    
    # Group by priority
    priority_groups = {
        'CRITICAL (P10)': [],
        'HIGH (P8-9)': [],
        'MEDIUM (P6-7)': [],
        'LOW (P4-5)': []
    }
    
    for cat_name, cat_info in custom_cats.items():
        priority = cat_info['priority']
        if priority == 10:
            priority_groups['CRITICAL (P10)'].append((cat_name, cat_info['file_count']))
        elif priority >= 8:
            priority_groups['HIGH (P8-9)'].append((cat_name, cat_info['file_count']))
        elif priority >= 6:
            priority_groups['MEDIUM (P6-7)'].append((cat_name, cat_info['file_count']))
        else:
            priority_groups['LOW (P4-5)'].append((cat_name, cat_info['file_count']))
    
    y_pos = 0.9
    x_start = 0.05
    colors_priority = {
        'CRITICAL (P10)': '#FF0000',
        'HIGH (P8-9)': '#FF8C00',
        'MEDIUM (P6-7)': '#4169E1',
        'LOW (P4-5)': '#808080'
    }
    
    for group_name, categories in priority_groups.items():
        if not categories:
            continue
            
        # Draw group box with enhanced styling
        color = colors_priority[group_name]
        
        ax4.text(x_start, y_pos, group_name, 
                fontsize=13, fontweight='bold', color=color,
                bbox=dict(boxstyle='round,pad=0.6', facecolor=color, alpha=0.2, edgecolor=color, linewidth=2.5))
        
        y_pos -= 0.09
        
        # List categories with better spacing
        for cat_name, file_count in sorted(categories, key=lambda x: x[1], reverse=True):
            ax4.text(x_start + 0.02, y_pos, f'• {cat_name}: {file_count} files',
                    fontsize=10, family='monospace', color='#34495E')
            y_pos -= 0.05
        
        y_pos -= 0.03
    
    ax4.set_xlim(0, 1)
    ax4.set_ylim(0, 1)
    
    # ==================== Add footer ====================
    total_files = sum(d['file_count'] for d in datasets.values())
    total_categories = sum(d['categories'] for d in datasets.values())
    
    fig.text(0.5, 0.01, 
            f'Total: {total_files:,} audio files across {total_categories} categories | All audio in WAV format | Generated: 2026-02-11',
            ha='center', fontsize=11, style='italic', color='#666666')
    
    return fig

def main():
    """Generate and save the dataset format graph"""
    print("🎵 Generating HearAlert Audio Dataset Format Graph...")
    
    # Create the visualization
    fig = create_dataset_graph()
    
    # Save paths
    output_dir = Path(__file__).parent
    png_path = output_dir / 'dataset_format_graph.png'
    pdf_path = output_dir / 'dataset_format_graph.pdf'
    
    # Save as PNG with optimized DPI for compression
    plt.savefig(png_path, dpi=100, bbox_inches='tight', facecolor='white', edgecolor='none')
    print(f"✅ Saved PNG: {png_path}")
    
    # Save as PDF with professional quality and compression
    plt.savefig(pdf_path, format='pdf', bbox_inches='tight', facecolor='white', edgecolor='none')
    print(f"✅ Saved PDF: {pdf_path}")
    
    print("\n📊 Dataset Summary:")
    print("=" * 60)
    
    datasets = load_dataset_info()
    for ds_key, ds_info in datasets.items():
        print(f"\n{ds_info['name']}:")
        print(f"  Format: {ds_info['format']}")
        print(f"  Sample Rate: {ds_info['sample_rate']}")
        print(f"  Bit Depth: {ds_info['bit_depth']}")
        print(f"  Channels: {ds_info['channels']}")
        print(f"  Duration: {ds_info['duration']}")
        print(f"  Files: {ds_info['file_count']:,}")
        print(f"  Categories: {ds_info['categories']}")
    
    total_files = sum(d['file_count'] for d in datasets.values())
    print(f"\n{'='*60}")
    print(f"TOTAL AUDIO FILES: {total_files:,}")
    print(f"{'='*60}\n")
    
    # Show the plot
    plt.show()

if __name__ == "__main__":
    main()

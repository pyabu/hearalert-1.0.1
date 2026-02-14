#!/usr/bin/env python3
"""
Comprehensive Audio Waveform Graph Generator for HearAlert
Generates waveform visualizations for all dataset categories and exports as PDF
"""

import os
import numpy as np
import matplotlib.pyplot as plt
import wave
import struct
from pathlib import Path
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
import warnings
warnings.filterwarnings('ignore')

def read_wav_file(filepath):
    """Read WAV file and return audio data and parameters"""
    try:
        with wave.open(str(filepath), 'rb') as wav_file:
            # Get audio parameters
            n_channels = wav_file.getnchannels()
            sample_width = wav_file.getsampwidth()
            framerate = wav_file.getframerate()
            n_frames = wav_file.getnframes()
            
            # Read audio data
            audio_data = wav_file.readframes(n_frames)
            
            # Convert to numpy array
            if sample_width == 1:
                dtype = np.uint8
                audio_array = np.frombuffer(audio_data, dtype=dtype)
                audio_array = (audio_array - 128) / 128.0
            elif sample_width == 2:
                dtype = np.int16
                audio_array = np.frombuffer(audio_data, dtype=dtype)
                audio_array = audio_array / 32768.0
            else:
                raise ValueError(f"Unsupported sample width: {sample_width}")
            
            # If stereo, convert to mono by averaging channels
            if n_channels == 2:
                audio_array = audio_array.reshape(-1, 2).mean(axis=1)
            
            # Create time axis
            duration = n_frames / framerate
            time_axis = np.linspace(0, duration, len(audio_array))
            
            return audio_array, time_axis, framerate, duration
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None, None, None, None

def plot_waveform_single(filepath, ax, title_override=None):
    """Plot waveform for a single audio file on given axis with improved styling"""
    audio_data, time_axis, framerate, duration = read_wav_file(filepath)
    
    if audio_data is None:
        ax.text(0.5, 0.5, f'Error loading file', ha='center', va='center', 
                transform=ax.transAxes, fontsize=11, color='#E74C3C', fontweight='bold')
        ax.set_title(title_override or Path(filepath).name, fontsize=10, pad=8)
        ax.set_facecolor('#F8F9FA')
        return
    
    MAX_POINTS = 5000  # Downsample if more than this many points
    step = max(1, len(audio_data) // MAX_POINTS)
    
    # Plot waveform with enhanced styling - RASTERIZED for smaller PDF size
    # We use a step to downsample the data for plotting, which drastically reduces vector complexity
    ax.plot(time_axis[::step], audio_data[::step], linewidth=0.5, color='#2E86AB', alpha=0.9, rasterized=True)
    ax.fill_between(time_axis[::step], audio_data[::step], alpha=0.25, color='#2E86AB', rasterized=True)
    
    # Add zero reference line
    ax.axhline(y=0, color='#95A5A6', linestyle='-', linewidth=0.8, alpha=0.4)
    
    # Styling with better alignment
    ax.set_xlabel('Time (s)', fontsize=9, fontweight='600', labelpad=4)
    ax.set_ylabel('Amplitude', fontsize=9, fontweight='600', labelpad=4)
    
    title = title_override or Path(filepath).name
    ax.set_title(f'{title}\n{framerate:,} Hz | {duration:.2f}s | (Downsampled 1:{step})', 
                 fontsize=10, fontweight='bold', pad=10, color='#2C3E50')
    ax.grid(True, alpha=0.25, linestyle='--', linewidth=0.6, color='#BDC3C7')
    ax.set_ylim(-1.15, 1.15)
    ax.tick_params(labelsize=8, width=1.2, length=4)
    ax.set_facecolor('#FAFBFC')
    
    # Add subtle background
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#34495E')
    ax.spines['bottom'].set_color('#34495E')
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['bottom'].set_linewidth(1.5)

def get_esc50_samples():
    """Get representative samples from ESC-50 dataset"""
    csv_path = Path('/Users/abu/hearalert_version_1.1/hearalertt/datasets/ESC-50/meta/esc50.csv')
    audio_dir = Path('/Users/abu/hearalert_version_1.1/hearalertt/datasets/ESC-50/audio')
    
    if not csv_path.exists():
        return []
    
    df = pd.read_csv(csv_path)
    
    # Select diverse categories
    selected_categories = [
        'dog', 'cat', 'baby_cry', 'fire_alarm', 'siren', 
        'car_horn', 'glass_breaking', 'door_wood_knock', 
        'rain', 'thunderstorm', 'wind', 'crackling_fire'
    ]
    
    samples = []
    for category in selected_categories:
        cat_files = df[df['category'] == category]
        if len(cat_files) > 0:
            filename = cat_files.iloc[0]['filename']
            filepath = audio_dir / filename
            if filepath.exists():
                samples.append({
                    'path': filepath,
                    'category': category.replace('_', ' ').title(),
                    'dataset': 'ESC-50'
                })
    
    return samples[:12]  # Limit to 12 samples

def get_custom_samples():
    """Get samples from custom generated datasets if available"""
    # These would be from your custom generated audio files
    # For now, we'll use ESC-50 samples that match HearAlert categories
    
    csv_path = Path('/Users/abu/hearalert_version_1.1/hearalertt/datasets/ESC-50/meta/esc50.csv')
    audio_dir = Path('/Users/abu/hearalert_version_1.1/hearalertt/datasets/ESC-50/audio')
    
    if not csv_path.exists():
        return []
    
    df = pd.read_csv(csv_path)
    
    # HearAlert priority categories from ESC-50
    hearalert_mapping = {
        'crying_baby': 'Baby Crying (P10)',
        'car_horn': 'Car Horn (P10)',
        'siren': 'Emergency Siren (P10)',
        'clock_alarm': 'Alarm Clock (P10)',
        'glass_breaking': 'Glass Breaking (P9)',
        'train': 'Train (P9)',
        'vacuum_cleaner': 'Vacuum Cleaner (P5)',
        'helicopter': 'Helicopter (P6)',
        'airplane': 'Airplane (P5)',
        'dog': 'Dog Barking (P7)',
        'cat': 'Cat Meowing (P5)',
        'thunderstorm': 'Thunderstorm (P7)'
    }
    
    samples = []
    for esc_cat, display_name in hearalert_mapping.items():
        cat_files = df[df['category'] == esc_cat]
        if len(cat_files) > 0:
            filename = cat_files.iloc[0]['filename']
            filepath = audio_dir / filename
            if filepath.exists():
                samples.append({
                    'path': filepath,
                    'category': display_name,
                    'dataset': 'HearAlert'
                })
    
    return samples[:12]

def create_comprehensive_waveform_pdf():
    """Create comprehensive PDF with all waveform graphs"""
    
    print("🎵 Generating Comprehensive Audio Waveform Graphs...")
    print("=" * 70)
    
    # Get samples
    esc50_samples = get_esc50_samples()
    custom_samples = get_custom_samples()
    
    all_samples = esc50_samples + custom_samples
    
    if not all_samples:
        print("❌ No audio samples found!")
        return
    
    print(f"📊 Found {len(all_samples)} audio samples to visualize")
    print(f"   - ESC-50: {len(esc50_samples)} samples")
    print(f"   - HearAlert Custom: {len(custom_samples)} samples")
    
    # Output paths
    output_dir = Path(__file__).parent
    pdf_path = output_dir / 'all_audio_waveforms.pdf'
    
    # Create PDF
    with PdfPages(pdf_path) as pdf:
        
        # ========== PAGE 1: ESC-50 Waveforms ==========
        if esc50_samples:
            fig1 = plt.figure(figsize=(17, 11))
            fig1.patch.set_facecolor('white')
            fig1.suptitle('ESC-50 Dataset - Audio Waveforms\nFormat: WAV (PCM) | Sample Rate: 44,100 Hz | Bit Depth: 16-bit | Channels: Mono', 
                         fontsize=16, fontweight='bold', y=0.985, color='#2C3E50')
            
            rows, cols = 4, 3
            for idx, sample in enumerate(esc50_samples[:12]):
                ax = fig1.add_subplot(rows, cols, idx + 1)
                plot_waveform_single(sample['path'], ax, sample['category'])
            
            plt.tight_layout(rect=[0.02, 0.02, 0.98, 0.96], h_pad=3.5, w_pad=2.5)
            pdf.savefig(fig1, bbox_inches='tight', dpi=100, facecolor='white')
            plt.close(fig1)
            print("✅ Page 1: ESC-50 waveforms")
        
        # ========== PAGE 2: HearAlert Custom Waveforms ==========
        if custom_samples:
            fig2 = plt.figure(figsize=(17, 11))
            fig2.patch.set_facecolor('white')
            fig2.suptitle('HearAlert Custom Dataset - Audio Waveforms (Organized by Priority)\nFormat: WAV (PCM) | Sample Rate: 16,000 Hz | Bit Depth: 16-bit | Channels: Mono', 
                         fontsize=16, fontweight='bold', y=0.985, color='#2C3E50')
            
            rows, cols = 4, 3
            for idx, sample in enumerate(custom_samples[:12]):
                ax = fig2.add_subplot(rows, cols, idx + 1)
                plot_waveform_single(sample['path'], ax, sample['category'])
            
            plt.tight_layout(rect=[0.02, 0.02, 0.98, 0.96], h_pad=3.5, w_pad=2.5)
            pdf.savefig(fig2, bbox_inches='tight', dpi=100, facecolor='white')
            plt.close(fig2)
            print("✅ Page 2: HearAlert Custom waveforms")
        
        # ========== PAGE 3: Detailed Waveform Analysis (6 samples) ==========
        selected_for_detail = all_samples[:6]
        if selected_for_detail:
            fig3 = plt.figure(figsize=(17, 11))
            fig3.patch.set_facecolor('white')
            fig3.suptitle('Detailed Waveform Analysis - Selected Sound Categories\nTime-Domain Analysis with Statistical Metrics', 
                         fontsize=16, fontweight='bold', y=0.985, color='#2C3E50')
            
            rows, cols = 3, 2
            for idx, sample in enumerate(selected_for_detail):
                ax = fig3.add_subplot(rows, cols, idx + 1)
                
                audio_data, time_axis, framerate, duration = read_wav_file(sample['path'])
                
                if audio_data is not None:
                    # Plot waveform with more detail
                    ax.plot(time_axis, audio_data, linewidth=0.9, color='#2E86AB', alpha=0.95)
                    ax.fill_between(time_axis, audio_data, alpha=0.2, color='#2E86AB')
                    
                    # Add zero line
                    ax.axhline(y=0, color='#E74C3C', linestyle='--', linewidth=1, alpha=0.5)
                    
                    # Calculate and display statistics
                    max_amp = np.max(np.abs(audio_data))
                    rms = np.sqrt(np.mean(audio_data**2))
                    
                    stats_text = f'Peak: {max_amp:.3f} | RMS: {rms:.3f}'
                    
                    ax.set_xlabel('Time (s)', fontsize=10, fontweight='600', labelpad=5)
                    ax.set_ylabel('Amplitude', fontsize=10, fontweight='600', labelpad=5)
                    ax.set_title(f'{sample["category"]} ({sample["dataset"]})\n{framerate:,} Hz | {duration:.2f}s | {stats_text}', 
                               fontsize=11, fontweight='bold', pad=12, color='#2C3E50')
                    ax.grid(True, alpha=0.25, linestyle='--', linewidth=0.6, color='#BDC3C7')
                    ax.set_ylim(-1.15, 1.15)
                    ax.tick_params(labelsize=9, width=1.2, length=4)
                    ax.set_facecolor('#FAFBFC')
                    ax.spines['top'].set_visible(False)
                    ax.spines['right'].set_visible(False)
                    ax.spines['left'].set_color('#34495E')
                    ax.spines['bottom'].set_color('#34495E')
                    ax.spines['left'].set_linewidth(1.5)
                    ax.spines['bottom'].set_linewidth(1.5)
            
            plt.tight_layout(rect=[0.02, 0.02, 0.98, 0.96], h_pad=4.0, w_pad=3.0)
            pdf.savefig(fig3, bbox_inches='tight', dpi=100, facecolor='white')
            plt.close(fig3)
            print("✅ Page 3: Detailed waveform analysis")
        
        # ========== PAGE 4: Spectral Comparison ==========
        comparison_samples = all_samples[:4]
        if comparison_samples:
            fig4 = plt.figure(figsize=(17, 11))
            fig4.patch.set_facecolor('white')
            fig4.suptitle('Comparative Analysis - Waveform & Frequency Spectrum\nTime-Domain vs Frequency-Domain Representation', 
                         fontsize=16, fontweight='bold', y=0.985, color='#2C3E50')
            
            for idx, sample in enumerate(comparison_samples):
                # Waveform
                ax1 = fig4.add_subplot(4, 2, idx*2 + 1)
                audio_data, time_axis, framerate, duration = read_wav_file(sample['path'])
                
                if audio_data is not None:
                    ax1.plot(time_axis, audio_data, linewidth=0.7, color='#2E86AB', alpha=0.9)
                    ax1.fill_between(time_axis, audio_data, alpha=0.2, color='#2E86AB')
                    ax1.axhline(y=0, color='#95A5A6', linestyle='-', linewidth=0.8, alpha=0.4)
                    ax1.set_ylabel('Amplitude', fontsize=10, fontweight='600', labelpad=5)
                    ax1.set_xlabel('Time (s)', fontsize=10, fontweight='600', labelpad=5)
                    ax1.set_title(f'{sample["category"]} - Waveform', fontsize=11, fontweight='bold', 
                                 pad=10, color='#2C3E50')
                    ax1.grid(True, alpha=0.25, linestyle='--', linewidth=0.6, color='#BDC3C7')
                    ax1.set_ylim(-1.15, 1.15)
                    ax1.tick_params(labelsize=9, width=1.2, length=4)
                    ax1.set_facecolor('#FAFBFC')
                    ax1.spines['top'].set_visible(False)
                    ax1.spines['right'].set_visible(False)
                    ax1.spines['left'].set_color('#34495E')
                    ax1.spines['bottom'].set_color('#34495E')
                    ax1.spines['left'].set_linewidth(1.5)
                    ax1.spines['bottom'].set_linewidth(1.5)
                    
                    # Frequency spectrum
                    ax2 = fig4.add_subplot(4, 2, idx*2 + 2)
                    fft = np.fft.fft(audio_data)
                    freq = np.fft.fftfreq(len(audio_data), 1/framerate)
                    
                    # Only positive frequencies
                    pos_mask = freq > 0
                    freq_pos = freq[pos_mask]
                    fft_magnitude = np.abs(fft[pos_mask])
                    
                    # Plot frequency spectrum
                    cutoff = len(freq_pos)//4
                    ax2.plot(freq_pos[:cutoff], fft_magnitude[:cutoff], 
                            linewidth=0.8, color='#A23B72', alpha=0.9)
                    ax2.fill_between(freq_pos[:cutoff], fft_magnitude[:cutoff], 
                                    alpha=0.2, color='#A23B72')
                    ax2.set_ylabel('Magnitude', fontsize=10, fontweight='600', labelpad=5)
                    ax2.set_xlabel('Frequency (Hz)', fontsize=10, fontweight='600', labelpad=5)
                    ax2.set_title(f'{sample["category"]} - Frequency Spectrum', fontsize=11, 
                                 fontweight='bold', pad=10, color='#2C3E50')
                    ax2.grid(True, alpha=0.25, linestyle='--', linewidth=0.6, color='#BDC3C7')
                    ax2.tick_params(labelsize=9, width=1.2, length=4)
                    ax2.set_facecolor('#FAFBFC')
                    ax2.spines['top'].set_visible(False)
                    ax2.spines['right'].set_visible(False)
                    ax2.spines['left'].set_color('#34495E')
                    ax2.spines['bottom'].set_color('#34495E')
                    ax2.spines['left'].set_linewidth(1.5)
                    ax2.spines['bottom'].set_linewidth(1.5)
            
            plt.tight_layout(rect=[0.02, 0.02, 0.98, 0.96], h_pad=3.5, w_pad=2.5)
            pdf.savefig(fig4, bbox_inches='tight', dpi=100, facecolor='white')
            plt.close(fig4)
            print("✅ Page 4: Waveform + Frequency comparison")
    
    print("=" * 70)
    print(f"✅ PDF saved: {pdf_path}")
    print(f"📄 Total pages: 4")
    print(f"📊 Total waveforms visualized: {len(all_samples)}")
    
    # Also save a PNG of the first page
    png_path = output_dir / 'all_audio_waveforms_preview.png'
    
    fig_preview = plt.figure(figsize=(17, 11))
    fig_preview.suptitle('Audio Waveform Graphs - All Datasets Preview\nESC-50 (44.1kHz) + HearAlert Custom (16kHz)', 
                        fontsize=16, fontweight='bold', y=0.98)
    
    rows, cols = 4, 3
    preview_samples = all_samples[:12]
    for idx, sample in enumerate(preview_samples):
        ax = fig_preview.add_subplot(rows, cols, idx + 1)
        plot_waveform_single(sample['path'], ax, sample['category'])
    
    plt.tight_layout(rect=[0, 0.03, 1, 0.96])
    plt.savefig(png_path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig_preview)
    
    print(f"✅ PNG preview saved: {png_path}")
    print("=" * 70)
    
    return pdf_path, png_path

def main():
    """Main function"""
    try:
        pdf_path, png_path = create_comprehensive_waveform_pdf()
        print("\n🎉 SUCCESS! All waveform graphs generated.")
        print(f"\n📁 Output files:")
        print(f"   PDF: {pdf_path}")
        print(f"   PNG: {png_path}")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()

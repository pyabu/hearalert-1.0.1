#!/usr/bin/env python3
"""
Audio Waveform Visualizer for ESC-50 Dataset
Displays waveform graphs for WAV audio files
"""

import os
import numpy as np
import matplotlib.pyplot as plt
import wave
import struct
from pathlib import Path

def read_wav_file(filepath):
    """Read WAV file and return audio data and parameters"""
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

def plot_waveform(filepath, ax=None, show_plot=True):
    """Plot waveform for a single audio file"""
    audio_data, time_axis, framerate, duration = read_wav_file(filepath)
    
    if ax is None:
        fig, ax = plt.subplots(figsize=(12, 4))
    
    # Plot waveform
    ax.plot(time_axis, audio_data, linewidth=0.5, color='#2E86AB')
    ax.fill_between(time_axis, audio_data, alpha=0.3, color='#2E86AB')
    
    # Styling
    ax.set_xlabel('Time (seconds)', fontsize=10)
    ax.set_ylabel('Amplitude', fontsize=10)
    ax.set_title(f'{Path(filepath).name}\nSample Rate: {framerate} Hz | Duration: {duration:.2f}s', 
                 fontsize=11, fontweight='bold')
    ax.grid(True, alpha=0.3, linestyle='--')
    ax.set_ylim(-1.1, 1.1)
    
    if show_plot:
        plt.tight_layout()
        plt.show()
    
    return ax

def plot_multiple_waveforms(filepaths, rows=3, cols=3, save_path=None):
    """Plot multiple waveforms in a grid"""
    n_plots = min(len(filepaths), rows * cols)
    fig, axes = plt.subplots(rows, cols, figsize=(16, 10))
    axes = axes.flatten() if isinstance(axes, np.ndarray) else [axes]
    
    for i, filepath in enumerate(filepaths[:n_plots]):
        try:
            plot_waveform(filepath, ax=axes[i], show_plot=False)
        except Exception as e:
            axes[i].text(0.5, 0.5, f'Error loading:\n{Path(filepath).name}\n{str(e)}',
                        ha='center', va='center', transform=axes[i].transAxes)
            axes[i].set_title(Path(filepath).name, fontsize=9)
    
    # Hide unused subplots
    for i in range(n_plots, len(axes)):
        axes[i].axis('off')
    
    plt.suptitle('ESC-50 Audio Waveforms', fontsize=16, fontweight='bold', y=0.995)
    plt.tight_layout()
    
    if save_path:
        # Save as PNG
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"✅ Saved PNG to: {save_path}")
        
        # Also save as PDF
        pdf_path = save_path.with_suffix('.pdf')
        plt.savefig(pdf_path, format='pdf', bbox_inches='tight')
        print(f"✅ Saved PDF to: {pdf_path}")
    
    plt.show()
    return fig

def main():
    """Main function to visualize audio files"""
    # Get audio directory
    script_dir = Path(__file__).parent
    audio_dir = script_dir / "ESC-50" / "audio"
    
    if not audio_dir.exists():
        print(f"❌ Audio directory not found: {audio_dir}")
        return
    
    # Get all WAV files
    wav_files = sorted(list(audio_dir.glob("*.wav")))
    
    if not wav_files:
        print(f"❌ No WAV files found in: {audio_dir}")
        return
    
    print(f"📊 Found {len(wav_files)} WAV files")
    print(f"📁 Directory: {audio_dir}")
    print("\n" + "="*60)
    
    # Ask user what to visualize
    print("\nOptions:")
    print("1. View first 9 files")
    print("2. View random 9 files")
    print("3. View specific file (enter filename)")
    print("4. View all files (grid view)")
    
    choice = input("\nEnter choice (1-4): ").strip()
    
    if choice == "1":
        # First 9 files
        plot_multiple_waveforms(wav_files[:9], save_path=script_dir / "waveforms_first9.png")
    
    elif choice == "2":
        # Random 9 files
        import random
        random_files = random.sample(wav_files, min(9, len(wav_files)))
        plot_multiple_waveforms(random_files, save_path=script_dir / "waveforms_random9.png")
    
    elif choice == "3":
        # Specific file
        filename = input("Enter filename: ").strip()
        matching_files = [f for f in wav_files if filename in f.name]
        
        if matching_files:
            plot_waveform(matching_files[0])
        else:
            print(f"❌ No file found matching: {filename}")
    
    elif choice == "4":
        # All files in grid
        n_files = len(wav_files)
        rows = int(np.ceil(np.sqrt(n_files)))
        cols = int(np.ceil(n_files / rows))
        plot_multiple_waveforms(wav_files, rows=rows, cols=cols, 
                               save_path=script_dir / "waveforms_all.png")
    
    else:
        print("❌ Invalid choice")

if __name__ == "__main__":
    main()

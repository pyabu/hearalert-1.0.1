#!/usr/bin/env python3
"""
Quick script to generate PDF waveform visualization
"""

import os
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import wave
from pathlib import Path

def read_wav_file(filepath):
    """Read WAV file and return audio data and parameters"""
    with wave.open(str(filepath), 'rb') as wav_file:
        n_channels = wav_file.getnchannels()
        sample_width = wav_file.getsampwidth()
        framerate = wav_file.getframerate()
        n_frames = wav_file.getnframes()
        audio_data = wav_file.readframes(n_frames)
        
        if sample_width == 2:
            audio_array = np.frombuffer(audio_data, dtype=np.int16) / 32768.0
        else:
            audio_array = np.frombuffer(audio_data, dtype=np.uint8)
            audio_array = (audio_array - 128) / 128.0
        
        if n_channels == 2:
            audio_array = audio_array.reshape(-1, 2).mean(axis=1)
        
        duration = n_frames / framerate
        time_axis = np.linspace(0, duration, len(audio_array))
        
        return audio_array, time_axis, framerate, duration

# Get audio files
audio_dir = Path(__file__).parent / "ESC-50" / "audio"
wav_files = sorted(list(audio_dir.glob("*.wav")))[:9]

print(f"📊 Generating waveforms for {len(wav_files)} files...")

# Create figure
fig, axes = plt.subplots(3, 3, figsize=(16, 10))
axes = axes.flatten()

for i, filepath in enumerate(wav_files):
    try:
        audio_data, time_axis, framerate, duration = read_wav_file(filepath)
        
        # Plot waveform
        axes[i].plot(time_axis, audio_data, linewidth=0.5, color='#2E86AB')
        axes[i].fill_between(time_axis, audio_data, alpha=0.3, color='#2E86AB')
        
        # Styling
        axes[i].set_xlabel('Time (seconds)', fontsize=10)
        axes[i].set_ylabel('Amplitude', fontsize=10)
        axes[i].set_title(f'{filepath.name}\nSample Rate: {framerate} Hz | Duration: {duration:.2f}s', 
                         fontsize=11, fontweight='bold')
        axes[i].grid(True, alpha=0.3, linestyle='--')
        axes[i].set_ylim(-1.1, 1.1)
        
        print(f"  ✓ {filepath.name}")
    except Exception as e:
        print(f"  ✗ Error with {filepath.name}: {e}")

plt.suptitle('ESC-50 Audio Waveforms', fontsize=16, fontweight='bold', y=0.995)
plt.tight_layout()

# Save as PDF
output_dir = Path(__file__).parent
pdf_path = output_dir / "waveforms_first9.pdf"
png_path = output_dir / "waveforms_first9.png"

plt.savefig(pdf_path, format='pdf', bbox_inches='tight')
print(f"\n✅ Saved PDF to: {pdf_path}")

plt.savefig(png_path, dpi=150, bbox_inches='tight')
print(f"✅ Saved PNG to: {png_path}")

print("\n🎉 Done!")

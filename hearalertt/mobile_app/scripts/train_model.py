import os
import tensorflow as tf
from tflite_model_maker import audio_classifier

# Define paths relative to this script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR)) # Up two levels from mobile_app/scripts
DATASET_NAME = 'raw'
DATASET_PATH = os.path.join(PROJECT_ROOT, DATASET_NAME)
EXPORT_DIR = os.path.join(SCRIPT_DIR, '../assets/models')
MODEL_FILENAME = 'baby_cry_model.tflite'

def train_baby_cry_model():
    print(f"🚀 Starting Baby Cry Model Training")
    print(f"📂 Dataset Path: {DATASET_PATH}")
    
    if not os.path.exists(DATASET_PATH):
        print(f"❌ Error: Dataset directory not found at {DATASET_PATH}")
        return

    # 1. Load Data
    print("📊 Loading audio data...")
    # DataLoader infers labels from subdirectories
    data = audio_classifier.DataLoader.from_folder(DATASET_PATH)
    
    # 2. Split Data (80% train, 10% val, 10% test)
    train_data, rest_data = data.split(0.8)
    val_data, test_data = rest_data.split(0.5)
    
    print(f"✅ Data loaded: {len(data)} total samples")
    print(f"   Training: {len(train_data)}")
    print(f"   Validation: {len(val_data)}")
    print(f"   Test: {len(test_data)}")

    # 3. Create & Train Model
    # Uses YAMNet transfer learning by default suitable for environmental sounds
    print("🧠 Training model (YAMNet backbone)...")
    model = audio_classifier.create(
        train_data, 
        model_spec=audio_classifier.YamNetSpec(
            keep_yamnet_outputs=False, 
            frame_step=3 * audio_classifier.YamNetSpec.EXPECTED_WAVEFORM_LENGTH, # 3 seconds inference window
            frame_length=audio_classifier.YamNetSpec.EXPECTED_WAVEFORM_LENGTH
        ),
        validation_data=val_data,
        batch_size=16,
        epochs=50 # Adjust based on performance
    )
    
    # 4. Evaluate
    print("📉 Evaluating model...")
    loss, acc = model.evaluate(test_data)
    print(f"🏆 Test Accuracy: {acc:.4f}")

    # 5. Export
    print(f"💾 Exporting to {EXPORT_DIR}...")
    if not os.path.exists(EXPORT_DIR):
        os.makedirs(EXPORT_DIR)
        
    model.export(
        export_dir=EXPORT_DIR, 
        tflite_filename=MODEL_FILENAME, 
        export_format=[audio_classifier.ExportFormat.TFLITE, audio_classifier.ExportFormat.LABEL]
    )
    
    # Rename labels.txt to match app expectation
    default_label_path = os.path.join(EXPORT_DIR, 'labels.txt')
    target_label_path = os.path.join(EXPORT_DIR, 'baby_cry_labels.txt')
    if os.path.exists(default_label_path):
        if os.path.exists(target_label_path):
            os.remove(target_label_path)
        os.rename(default_label_path, target_label_path)
        print(f"✅ Labels renamed to {target_label_path}")
    
    print(f"✅ Model saved to {os.path.join(EXPORT_DIR, MODEL_FILENAME)}")
    print("⚠️  IMPORTANT: Verify labels.txt matches your app's expected category map.")

if __name__ == '__main__':
    train_baby_cry_model()

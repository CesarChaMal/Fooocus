# CLAUDE.md - Fooocus Codebase Guide for AI Assistants

## Project Overview

**Fooocus** is an open-source image generation software built on Stable Diffusion XL (SDXL) with a focus on simplicity and user experience. The project aims to make AI image generation as simple as Midjourney while remaining completely offline and free.

- **Version**: 2.5.5
- **Status**: Limited Long-Term Support (LTS) - Bug fixes only
- **Architecture**: Built entirely on Stable Diffusion XL
- **UI Framework**: Gradio 3.41.2
- **Primary Language**: Python 3.10
- **License**: See LICENSE file

### Key Philosophy
- Minimal user tweaking required (focus on prompts, not parameters)
- Offline-first design
- Installation complexity strictly limited to < 3 mouse clicks
- GPT-2 based prompt processing for enhanced quality
- Custom inpainting and image prompt algorithms

### Project Status
The project is in LTS mode focusing exclusively on bug fixes. There are no plans to migrate to newer model architectures (e.g., Flux) unless the community converges on a dominant standard.

---

## Repository Structure

```
Fooocus/
├── modules/              # Core application modules (30+ Python files)
│   ├── async_worker.py   # Task processing and async job management
│   ├── config.py         # Configuration management system
│   ├── flags.py          # Constants, enums, and UI options
│   ├── patch.py          # Model patching and modifications
│   ├── sample_hijack.py  # Sampling process customizations
│   ├── default_pipeline.py # Main image generation pipeline
│   ├── core.py           # Core stable diffusion operations
│   ├── gradio_hijack.py  # Gradio UI customizations
│   ├── meta_parser.py    # Metadata parsing for images
│   ├── lora.py           # LoRA model handling
│   ├── upscaler.py       # Image upscaling functionality
│   ├── inpaint_worker.py # Inpainting operations
│   └── ...               # Additional modules
│
├── ldm_patched/          # Patched latent diffusion model code
│   ├── modules/          # Core LDM modules
│   ├── controlnet/       # ControlNet implementations
│   ├── k_diffusion/      # K-diffusion samplers
│   ├── ldm/              # Latent diffusion model core
│   └── ...               # Additional LDM components
│
├── extras/               # Additional features and utilities
│   ├── expansion.py      # Prompt expansion (GPT-2 based)
│   ├── ip_adapter.py     # Image prompt adapter
│   ├── inpaint_mask.py   # Mask generation (SAM, U2Net, etc.)
│   ├── interrogate.py    # Image captioning/description
│   ├── face_crop.py      # Face detection and cropping
│   └── ...               # Additional utilities
│
├── presets/              # Model and configuration presets
│   ├── default.json      # Default preset (Juggernaut XL)
│   ├── anime.json        # Anime preset
│   ├── realistic.json    # Realistic photo preset
│   ├── lightning.json    # Fast generation preset
│   └── ...               # Additional presets
│
├── models/               # Model storage directories (git-ignored)
│   ├── checkpoints/      # Main SDXL model checkpoints
│   ├── loras/            # LoRA adaptation models
│   ├── controlnet/       # ControlNet models
│   ├── inpaint/          # Inpainting models
│   ├── clip_vision/      # CLIP vision models
│   ├── vae/              # VAE models
│   ├── upscale_models/   # Upscaling models
│   ├── embeddings/       # Text embeddings
│   └── ...               # Additional model directories
│
├── sdxl_styles/          # Style definitions (JSON)
│   ├── sdxl_styles_sai.json
│   ├── sdxl_styles_twri.json
│   └── ...
│
├── wildcards/            # Wildcard text files for prompt randomization
├── language/             # Internationalization JSON files
├── css/                  # Custom CSS for UI
├── javascript/           # Custom JavaScript for UI
├── tests/                # Unit tests
│
├── webui.py              # Main Gradio UI definition
├── launch.py             # Environment setup and launcher
├── entry_with_update.py  # Main entry point with update checks
├── args_manager.py       # Command-line argument parsing
├── config.txt            # User configuration file (auto-generated)
├── fooocus_version.py    # Version information
└── requirements_versions.txt  # Python dependencies with versions
```

---

## Key Technologies & Dependencies

### Core Dependencies
- **PyTorch 2.1.0** - Deep learning framework
- **Gradio 3.41.2** - Web UI framework
- **Transformers 4.42.4** - Hugging Face transformers (CLIP, GPT-2)
- **Safetensors 0.4.3** - Safe model format
- **Accelerate 0.32.1** - PyTorch acceleration utilities

### Image Processing
- **Pillow 10.4.0** - Image manipulation
- **OpenCV 4.10.0** - Computer vision operations
- **Rembg 2.0.57** - Background removal
- **Segment Anything 1.0** - SAM for mask generation

### Additional Features
- **ONNX Runtime 1.18.1** - Optimized inference
- **GroundingDINO** - Object detection
- **Einops 0.8.0** - Tensor operations
- **SciPy 1.14.0** - Scientific computing

### Model Architecture Support
- SDXL Base and Refiner models
- LoRA (Low-Rank Adaptation)
- ControlNet
- IP-Adapter
- VAE variants

---

## Architecture & Core Concepts

### Image Generation Pipeline

1. **Entry Point** (`entry_with_update.py` → `launch.py` → `webui.py`)
   - Sets up environment and dependencies
   - Launches Gradio web interface
   - Initializes model management

2. **Task Creation** (`modules/async_worker.py`)
   - User inputs captured from Gradio UI
   - `AsyncTask` object created with all parameters
   - Task queued for processing

3. **Pipeline Execution** (`modules/default_pipeline.py`)
   - Model loading and caching
   - ControlNet and LoRA application
   - Prompt processing and expansion
   - Sampling with custom hijacks
   - Post-processing (upscaling, enhancement)

4. **Sampling** (`modules/sample_hijack.py`, `ldm_patched/`)
   - Custom k-diffusion samplers
   - Native refiner swap in single k-sampler
   - SAG (Self-Attention Guidance) integration
   - Negative ADM guidance

### Key Patterns

#### Configuration System
- Preset-based configuration (`presets/*.json`)
- User config overlay (`config.txt`)
- Environment variable support
- Dynamic model path resolution

#### Model Management
- Lazy loading with caching
- VRAM optimization strategies
- Automatic model downloading
- Hash-based model verification

#### Prompt Processing
- GPT-2 based expansion (offline)
- Style template application
- Wildcard substitution
- Array processing for batch variations
- Inline LoRA syntax support

#### Performance Modes
```python
class Performance(Enum):
    QUALITY = 'Quality'          # 60 steps
    SPEED = 'Speed'              # 30 steps
    EXTREME_SPEED = 'Extreme Speed'  # 8 steps + LCM LoRA
    LIGHTNING = 'Lightning'      # 4 steps + Lightning LoRA
    HYPER_SD = 'Hyper-SD'       # 4 steps + Hyper-SD LoRA
```

---

## Entry Points & Main Files

### Launch Sequence
1. **`entry_with_update.py`** - Initial entry, checks for updates
2. **`launch.py`** - Environment preparation
   - Installs dependencies if missing
   - Configures PyTorch settings
   - Downloads required models
3. **`webui.py`** - Main application
   - Builds Gradio interface
   - Registers event handlers
   - Starts web server

### Important Files

#### `webui.py`
- Defines entire Gradio UI layout
- Handles user interactions
- Manages image generation workflow
- ~2000+ lines, core UI logic

#### `modules/async_worker.py`
- `AsyncTask` class: Encapsulates all generation parameters
- `worker_thread`: Main processing loop
- Async task queue management
- Progress reporting via yields

#### `modules/config.py`
- Loads default presets
- Merges user configuration
- Manages model paths
- Handles deprecated configs

#### `modules/default_pipeline.py`
- `refresh_everything()`: Main pipeline orchestration
- Model loading and caching
- ControlNet management
- Generation execution

#### `modules/flags.py`
- All UI constants and enums
- Sampler/scheduler definitions
- Aspect ratio presets
- Feature flags

---

## Configuration Management

### Configuration Hierarchy
1. **Preset defaults** (`presets/default.json`)
2. **Selected preset** (`presets/anime.json`, etc.)
3. **User config** (`config.txt`) - Auto-generated after first run
4. **Command-line args** - Highest priority

### config.txt Structure
```json
{
    "path_checkpoints": ["D:\\Fooocus\\models\\checkpoints"],
    "path_loras": ["D:\\Fooocus\\models\\loras"],
    "path_outputs": "D:\\Fooocus\\outputs",
    "default_model": "model_name.safetensors",
    "default_loras": [["lora_name.safetensors", 0.5]],
    "default_cfg_scale": 4.0,
    "default_sampler": "dpmpp_2m_sde_gpu",
    "default_scheduler": "karras",
    "default_styles": ["Fooocus V2", "Fooocus Enhance"]
}
```

### Command-Line Arguments
See `args_manager.py` for complete list. Key arguments:
- `--preset [default|anime|realistic]` - Load preset
- `--listen` - Expose on network
- `--port PORT` - Custom port
- `--share` - Create Gradio share link
- `--always-high-vram` - Force high VRAM mode
- `--disable-preset-selection` - Lock preset
- `--language LANG` - UI translation

---

## Development Workflow

### Environment Setup

#### Using Conda (Recommended)
```bash
git clone https://github.com/lllyasviel/Fooocus.git
cd Fooocus
conda env create -f environment.yaml
conda activate fooocus
pip install -r requirements_versions.txt
```

#### Using Python venv
```bash
git clone https://github.com/lllyasviel/Fooocus.git
cd Fooocus
python3 -m venv fooocus_env
source fooocus_env/bin/activate  # Windows: fooocus_env\Scripts\activate
pip install -r requirements_versions.txt
```

### Running the Application

```bash
# Standard launch
python entry_with_update.py

# With preset
python entry_with_update.py --preset anime

# Listen on network
python entry_with_update.py --listen --port 8888

# Debug mode
python entry_with_update.py --debug-mode
```

### Project Guidelines

#### Code Style
- Python 3.10+ syntax
- Follow existing patterns in the codebase
- Use type hints where practical (not strict)
- Keep functions focused and modular

#### Module Organization
- Core logic in `modules/`
- Model-specific code in `ldm_patched/`
- Additional features in `extras/`
- UI code in `webui.py`

#### Model Management
- Never commit model files (`.safetensors`, `.ckpt`, `.pth`)
- Use download URLs in presets
- Respect `.gitignore` patterns

---

## Testing

### Running Tests
```bash
# All tests
python -m unittest tests/

# Specific test
python -m unittest tests/test_utils.py

# Windows embedded Python
..\python_embeded\python.exe -m unittest
```

### Test Coverage
Current tests (limited):
- `tests/test_utils.py` - Utility function tests
- `tests/test_extra_utils.py` - Extra utilities tests

**Note**: Test coverage is minimal. Focus on manual testing via UI.

---

## Code Conventions & Patterns

### Import Organization
```python
# Standard library
import os
import json

# Third-party
import torch
import gradio as gr

# Local modules
import modules.config
from modules.util import function_name
```

### Error Handling
- Try-catch around file operations
- Graceful degradation for missing models
- User-friendly error messages in UI
- Console logging for debugging

### Async Processing Pattern
```python
# In webui.py
def generate_clicked(task):
    # Yield progress updates
    yield gr.update(visible=True, value="Processing...")

    # Add to task queue
    worker.async_tasks.append(task)

    # Poll for results
    while not finished:
        if len(task.yields) > 0:
            flag, product = task.yields.pop(0)
            if flag == 'preview':
                yield gr.update(value=product)
            elif flag == 'finish':
                yield gr.update(value=product)
                finished = True
```

### Model Loading Pattern
```python
# Lazy loading with caching
if model_name != current_model:
    # Unload old model
    if current_model is not None:
        del current_model
        torch.cuda.empty_cache()

    # Load new model
    current_model = load_model(model_name)
```

---

## Common Development Tasks

### Adding a New Preset
1. Create `presets/my_preset.json`
2. Define model, LoRA, and default settings
3. Include download URLs in `checkpoint_downloads` and `lora_downloads`
4. Test with `--preset my_preset`

### Adding a New Style
1. Add entries to appropriate file in `sdxl_styles/`
2. Format: `{"name": "Style Name", "prompt": "{prompt}, style keywords", "negative_prompt": "negatives"}`
3. Restart application to load new styles

### Modifying the UI
1. Edit `webui.py`
2. Use Gradio components (gr.Textbox, gr.Slider, etc.)
3. Wire up event handlers with `.click()`, `.change()`, etc.
4. Update `get_task()` to include new parameters
5. Update `AsyncTask.__init__()` to parse new parameters

### Adding Custom Samplers
1. Add sampler definition to `modules/flags.py` (KSAMPLER or SAMPLER_EXTRA)
2. Implement sampler logic in `ldm_patched/k_diffusion/` if needed
3. Update `modules/sample_hijack.py` for custom behavior

### Modifying the Pipeline
1. Main pipeline logic in `modules/default_pipeline.py`
2. Model patching in `modules/patch.py`
3. Sampling modifications in `modules/sample_hijack.py`
4. Post-processing in `modules/upscaler.py` or `extras/`

---

## Important Notes for AI Assistants

### Critical Constraints

#### DO NOT Modify Without Understanding
- `modules/patch.py` - Complex model patching logic
- `modules/sample_hijack.py` - Delicate sampling modifications
- `ldm_patched/` - Modified third-party code, changes may break functionality

#### Always Preserve
- Existing configuration structure
- Model download URLs (users depend on them)
- Backward compatibility with saved configs
- UI state management patterns

### Common Pitfalls

1. **VRAM Management**
   - Never load multiple large models simultaneously
   - Always call `torch.cuda.empty_cache()` after unloading
   - Respect performance mode memory constraints

2. **Gradio State**
   - UI updates must use `gr.update()`
   - Be careful with component visibility logic
   - Maintain consistent component order

3. **File Paths**
   - Use `os.path.join()` for cross-platform compatibility
   - Respect user-configured model paths
   - Never hard-code absolute paths

4. **Model Loading**
   - Check if model is already loaded before loading again
   - Handle missing model files gracefully
   - Use hash cache for model verification

### When Making Changes

#### For Bug Fixes
1. Identify the specific module responsible
2. Check if issue is already in troubleshoot.md
3. Test across different performance modes
4. Verify VRAM usage doesn't increase

#### For New Features
1. **Check project status first** - Feature development is discouraged
2. If absolutely necessary, follow existing patterns
3. Add configuration options to presets
4. Document in comments
5. Keep UI changes minimal and consistent

#### For Performance Improvements
1. Profile before optimizing
2. Focus on model loading/unloading
3. Improve caching strategies
4. Optimize VRAM usage

### Testing Checklist
- [ ] Test with default preset
- [ ] Test with anime preset
- [ ] Test with realistic preset
- [ ] Test text-to-image
- [ ] Test image variations (Vary Subtle/Strong)
- [ ] Test upscaling
- [ ] Test inpainting
- [ ] Test with different performance modes
- [ ] Check VRAM usage
- [ ] Verify no regression in image quality

### Code Quality Standards
- Follow existing code style (consistency over convention)
- Add comments for non-obvious logic
- Use descriptive variable names
- Keep functions under 100 lines when possible
- Avoid deep nesting (max 4 levels)

### Documentation
- Update this file when architecture changes
- Keep troubleshoot.md updated with solutions
- Document breaking changes in update_log.md
- Add comments for complex algorithms

---

## Key File Reference

### Must-Read Files (Priority Order)
1. `webui.py` - Understand the UI and workflow
2. `modules/async_worker.py` - Understand task processing
3. `modules/default_pipeline.py` - Understand image generation
4. `modules/config.py` - Understand configuration system
5. `modules/flags.py` - Understand constants and options

### Frequently Modified Files
- `webui.py` - UI changes
- `modules/config.py` - Configuration changes
- `presets/*.json` - Preset modifications
- `modules/flags.py` - Adding options/constants

### Rarely Modified Files (Be Careful)
- `modules/patch.py` - Core model patching
- `modules/sample_hijack.py` - Sampling logic
- `ldm_patched/**` - Modified third-party code
- `modules/core.py` - Core diffusion operations

---

## Additional Resources

### Documentation Files
- `readme.md` - User-facing documentation
- `development.md` - Development guidelines (minimal)
- `troubleshoot.md` - Common issues and solutions
- `docker.md` - Docker deployment
- `update_log.md` - Version history and changes
- `config_modification_tutorial.txt` - Config examples

### External References
- [Gradio Documentation](https://www.gradio.app/docs)
- [Stable Diffusion XL Paper](https://arxiv.org/abs/2307.01952)
- [Civitai](https://civitai.com) - Model repository
- [Hugging Face](https://huggingface.co) - Model hosting

### Community
- GitHub Issues - Bug reports and feature requests
- GitHub Discussions - Community support
- Forks - See related projects in readme.md

---

## Version Information

- **Document Version**: 1.0
- **Last Updated**: 2025-11-13
- **Fooocus Version**: 2.5.5
- **Maintainer**: Auto-generated for AI assistants

---

## Quick Reference Commands

```bash
# Development
python entry_with_update.py --debug-mode --listen

# Testing
python -m unittest tests/

# Different presets
python entry_with_update.py --preset anime
python entry_with_update.py --preset realistic

# High VRAM mode (better performance)
python entry_with_update.py --always-high-vram

# Low VRAM mode (4GB GPU)
python entry_with_update.py --always-low-vram

# Disable features for troubleshooting
python entry_with_update.py --disable-xformers
python entry_with_update.py --always-cpu
```

---

**Remember**: This is an LTS project focused on stability. Prioritize bug fixes and compatibility over new features. When in doubt, preserve existing behavior.

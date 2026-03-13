# NUERA ComfyUI Docker Image — All models baked in
# No network volume needed — enables all RunPod datacenters
FROM runpod/worker-comfyui:5.5.1-base

# Install IP-Adapter custom node
RUN comfy-node-install comfyui_ipadapter_plus

# Install InsightFace and ONNX runtime for face detection
RUN pip install insightface onnxruntime-gpu

# Download JuggernautXL v11 checkpoint (~6.5GB)
RUN comfy model download \
  --url https://huggingface.co/RunDiffusion/Juggernaut-XI-v11/resolve/main/juggernautXL_v11.safetensors \
  --relative-path models/checkpoints \
  --filename juggernautXL_v11.safetensors

# Download IP-Adapter FaceID SDXL model (~1GB)
RUN comfy model download \
  --url https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl.bin \
  --relative-path models/ipadapter \
  --filename ip-adapter-faceid_sdxl.bin

# Download IP-Adapter FaceID SDXL LoRA (~355MB)
RUN comfy model download \
  --url https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl_lora.safetensors \
  --relative-path models/loras \
  --filename ip-adapter-faceid_sdxl_lora.safetensors

# Download InsightFace antelopev2 models (~360MB)
RUN mkdir -p /comfyui/models/insightface/models/antelopev2 && \
  wget -O /tmp/antelopev2.zip "https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip" && \
  unzip -o /tmp/antelopev2.zip -d /comfyui/models/insightface/models/antelopev2/ && \
  mv /comfyui/models/insightface/models/antelopev2/antelopev2/* /comfyui/models/insightface/models/antelopev2/ 2>/dev/null || true && \
  rmdir /comfyui/models/insightface/models/antelopev2/antelopev2 2>/dev/null || true && \
  rm /tmp/antelopev2.zip

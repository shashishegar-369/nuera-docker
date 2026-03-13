# NUERA ComfyUI Docker Image v2
# Based on official RunPod customization guide:
# https://github.com/runpod-workers/worker-comfyui/blob/main/docs/customization.md

FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes using comfy-node-install (RunPod's own CLI tool)
RUN comfy-node-install comfyui_ipadapter_plus

# JuggernautXL v11 checkpoint (~6.5GB)
RUN comfy model download \
  --url https://huggingface.co/RunDiffusion/Juggernaut-XI-v11/resolve/main/juggernautXL_v11.safetensors \
  --relative-path models/checkpoints \
  --filename juggernautXL_v11.safetensors

# IP-Adapter FaceID SDXL model (~1GB)
RUN comfy model download \
  --url https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl.bin \
  --relative-path models/ipadapter \
  --filename ip-adapter-faceid_sdxl.bin

# IP-Adapter FaceID SDXL LoRA (~355MB)
RUN comfy model download \
  --url https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl_lora.safetensors \
  --relative-path models/loras \
  --filename ip-adapter-faceid_sdxl_lora.safetensors

# InsightFace antelopev2 models (~360MB)
RUN mkdir -p /comfyui/models/insightface/models/antelopev2 && \
  wget -q -O /tmp/antelopev2.zip \
    "https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip" && \
  unzip -o /tmp/antelopev2.zip -d /tmp/antelopev2_extract/ && \
  find /tmp/antelopev2_extract -name "*.onnx" -exec cp {} /comfyui/models/insightface/models/antelopev2/ \; && \
  rm -rf /tmp/antelopev2.zip /tmp/antelopev2_extract

# Verify all files installed correctly
RUN echo "=== Custom Nodes ===" && \
  ls -la /comfyui/custom_nodes/ && \
  echo "=== Checkpoints ===" && \
  ls -lh /comfyui/models/checkpoints/ && \
  echo "=== IP-Adapter Models ===" && \
  ls -lh /comfyui/models/ipadapter/ && \
  echo "=== LoRAs ===" && \
  ls -lh /comfyui/models/loras/ && \
  echo "=== InsightFace ===" && \
  ls -lh /comfyui/models/insightface/models/antelopev2/ && \
  echo "=== BUILD COMPLETE ==="

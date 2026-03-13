FROM runpod/worker-comfyui:5.7.1-base

# Step 1: Install IP-Adapter custom node (VERIFIED WORKING)
RUN comfy-node-install comfyui_ipadapter_plus

# Step 2: Set HF token THEN download JuggernautXL
ARG HF_TOKEN
RUN comfy model download --set-hf-api-token ${HF_TOKEN} \
  --url https://huggingface.co/RunDiffusion/Juggernaut-XI-v11/resolve/main/juggernautXL_v11.safetensors \
  --relative-path models/checkpoints \
  --filename juggernautXL_v11.safetensors

# Step 3: IP-Adapter FaceID model (no auth needed)
RUN comfy model download \
  --url https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl.bin \
  --relative-path models/ipadapter \
  --filename ip-adapter-faceid_sdxl.bin

# Step 4: IP-Adapter FaceID LoRA (no auth needed)
RUN comfy model download \
  --url https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl_lora.safetensors \
  --relative-path models/loras \
  --filename ip-adapter-faceid_sdxl_lora.safetensors

# Step 5: InsightFace antelopev2 (use python since curl/wget unavailable)
RUN mkdir -p /comfyui/models/insightface/models/antelopev2 && \
  python3 -c "import urllib.request; urllib.request.urlretrieve('https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip', '/tmp/antelopev2.zip')" && \
  python3 -c "import zipfile; z=zipfile.ZipFile('/tmp/antelopev2.zip'); [z.extract(f,'/tmp/av2') for f in z.namelist() if f.endswith('.onnx')]; z.close()" && \
  find /tmp/av2 -name "*.onnx" -exec cp {} /comfyui/models/insightface/models/antelopev2/ \; && \
  rm -rf /tmp/antelopev2.zip /tmp/av2

# Verify
RUN echo "=== Custom Nodes ===" && \
  ls -la /comfyui/custom_nodes/ && \
  echo "=== Checkpoints ===" && \
  ls -lh /comfyui/models/checkpoints/ && \
  echo "=== IP-Adapter ===" && \
  ls -lh /comfyui/models/ipadapter/ && \
  echo "=== LoRAs ===" && \
  ls -lh /comfyui/models/loras/ && \
  echo "=== InsightFace ===" && \
  ls -lh /comfyui/models/insightface/models/antelopev2/ && \
  echo "=== BUILD COMPLETE ==="

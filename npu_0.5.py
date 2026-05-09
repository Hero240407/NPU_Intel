from fastapi import FastAPI
from pydantic import BaseModel
import openvino_genai as ov_genai
import uvicorn
import time

app = FastAPI()

# 1. Point to your NEW symmetric OpenVINO model folder
MODEL_PATH = "./qwen2.5-coder-0.5b-npu-ov"

print(f"Loading model to Intel NPU from {MODEL_PATH}...")

# 2. Configure memory bounds for the NPU (Crucial for stability)
pipeline_config = {
    "MAX_PROMPT_LEN": 1024,
    "MIN_RESPONSE_LEN": 512
}

# 3. Load directly to the NPU
try:
    pipe = ov_genai.LLMPipeline(MODEL_PATH, "NPU", **pipeline_config)
    print("Model successfully loaded on NPU!")
except RuntimeError as e:
    print(f"FATAL NPU Error: {e}")
    exit(1)

# 4. Define the payload structure Continue sends
class CompletionRequest(BaseModel):
    prompt: str
    max_tokens: int = 60
    temperature: float = 0.1
    model: str = "qwen2.5-coder:0.5b"

# 5. Create the OpenAI-compatible endpoint
@app.post("/v1/completions")
async def completions(req: CompletionRequest):
    config = ov_genai.GenerationConfig()
    config.max_new_tokens = req.max_tokens
    config.temperature = req.temperature
    
    result = pipe.generate(req.prompt, config)
    
    return {
        "id": f"cmpl-{int(time.time())}",
        "object": "text_completion",
        "created": int(time.time()),
        "model": req.model,
        "choices": [
            {
                "text": result,
                "index": 0,
                "finish_reason": "stop"
            }
        ]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8005)
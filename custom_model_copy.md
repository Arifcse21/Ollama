**Option A: Using a Modelfile (Recommended)**

Create a `Modelfile` with your desired configuration:

```dockerfile
# Example Modelfile for reduced context
FROM qwen2.5-coder:32b
   
# Set context window to 32K tokens (reduced from default)
PARAMETER num_ctx 32768
   
# Optional: Adjust temperature for more consistent output
PARAMETER temperature 0.7

# Optional: Set repeat penalty
PARAMETER repeat_penalty 1.1
```
Then create your custom model:
```bash
ollama create qwen-32k -f Modelfile
```

**Option B: Interactive Configuration**
Load the model (we will use `qwen2.5-coder:32b` as an example):
```bash
ollama run qwen2.5-coder:32b
```
Change context size parameter:
```bash
/set parameter num_ctx 32768
```
Save the model with a new name:
```bash
/save your_model_name
```


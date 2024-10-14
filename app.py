import gradio as gr
import requests
import os
import json

API_URL = os.getenv("API_URL", "http://0.0.0.0:1234/v1/chat/completions")

def send_message(message, history):
    headers = {
        "Content-Type": "application/json"
    }

    data = {
        "model": "mistral",
        "messages": [{"role": "user", "content": message}],
        "max_tokens": 12000,
        "presence_penalty": 1.0,
        "top_p": 0.1,
        "temperature": 0.1,
        "stream": True  # Enable streaming
    }

    with requests.post(API_URL, json=data, headers=headers, stream=True) as response:
        if response.status_code == 200:
            full_response = ""
            for line in response.iter_lines():
                if line:
                    line = line.decode('utf-8')
                    if line.startswith('data: '):
                        try:
                            json_data = json.loads(line[6:])  # Remove 'data: ' prefix
                            if 'choices' in json_data and len(json_data['choices']) > 0:
                                delta = json_data['choices'][0].get('delta', {})
                                if 'content' in delta:
                                    content = delta['content']
                                    full_response += content
                                    yield full_response
                        except json.JSONDecodeError:
                            continue
            return full_response
        else:
            return f"Error: {response.status_code}, {response.text}"

iface = gr.ChatInterface(
    fn=send_message,
    title="Mistral.rs Streaming Chat Interface",
    description="Chat with the Mistral.rs model using this Gradio interface with streaming responses.",
)

if __name__ == "__main__":
    iface.launch(server_name="0.0.0.0", server_port=7860)
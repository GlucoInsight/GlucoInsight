from openai import OpenAI

client = OpenAI(api_key="sk-71c255367b384591b29d2007ddd479f2", base_url="https://api.deepseek.com/v1")

def gpt_call(prompt: str) -> str:
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": "You are a helpful assistant"},
            {"role": "user", "content": prompt},
        ],
        stream=False
    )
    return response.choices[0].message.content

print(gpt_call('hello'))
"""
Configuration management for JSAIAgent
"""
import os
from dotenv import load_dotenv

load_dotenv()

# OpenAI Configuration
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
OPENAI_MODEL = os.getenv('OPENAI_MODEL', 'gpt-4o-mini')
OPENAI_TEMPERATURE = float(os.getenv('OPENAI_TEMPERATURE', '0.7'))
OPENAI_MAX_TOKENS = int(os.getenv('OPENAI_MAX_TOKENS', '300'))

# Coqui TTS Configuration
COQUI_TTS_URL = os.getenv('COQUI_TTS_URL', 'http://localhost:5002')

# Audio Configuration
AUDIO_DIR = os.getenv('AUDIO_DIR', '/tmp/jsaiagent_audio')
SILENCE_DURATION = int(os.getenv('SILENCE_DURATION', '2'))
MAX_RECORDING_DURATION = int(os.getenv('MAX_RECORDING_DURATION', '10'))

# Logging
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
LOG_FILE = os.getenv('LOG_FILE', 'logs/jsaiagent.log')

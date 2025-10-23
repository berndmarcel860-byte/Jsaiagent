"""
Text-to-Speech service using Coqui TTS
"""
import logging
import requests
from config import COQUI_TTS_URL

logger = logging.getLogger(__name__)


class TTSService:
    """Handles text-to-speech conversion"""
    
    def __init__(self):
        self.base_url = COQUI_TTS_URL
    
    async def synthesize(self, text: str) -> bytes:
        """
        Convert text to speech audio
        
        Args:
            text: Text to convert to speech
            
        Returns:
            Audio data as bytes
        """
        try:
            logger.info(f"Synthesizing: {text[:50]}...")
            
            response = requests.post(
                f"{self.base_url}/api/tts",
                json={
                    'text': text,
                    'speaker_id': 'thorsten',
                    'language_id': 'de'
                },
                timeout=30
            )
            
            response.raise_for_status()
            
            logger.info(f"Speech synthesized: {len(response.content)} bytes")
            return response.content
            
        except Exception as e:
            logger.error(f"Error synthesizing speech: {e}")
            # Return empty bytes on error
            return b''

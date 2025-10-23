#!/usr/bin/env python3
"""
AGI Handler for Asterisk integration
Fast Python implementation for better performance
"""
import os
import sys
import logging
import asyncio
from pathlib import Path
from asterisk.agi import AGI
from ai_service import AIService
from tts_service import TTSService
from config import AUDIO_DIR, SILENCE_DURATION, MAX_RECORDING_DURATION

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class AGIHandler:
    """Handles AGI calls from Asterisk"""
    
    def __init__(self):
        self.ai_service = AIService()
        self.tts_service = TTSService()
        self.audio_dir = Path(AUDIO_DIR)
        self.audio_dir.mkdir(parents=True, exist_ok=True)
    
    async def handle_call(self, agi: AGI):
        """
        Handle incoming call through AGI
        
        Args:
            agi: AGI instance from Asterisk
        """
        try:
            # Get call information
            caller_id = agi.env.get('agi_callerid', 'unknown')
            extension = agi.env.get('agi_extension', 'unknown')
            
            logger.info(f"Call started: {caller_id} -> {extension}")
            
            # Answer the call
            agi.answer()
            logger.info("Call answered")
            
            # Welcome message
            welcome_msg = self.ai_service.get_welcome_message()
            await self._speak(agi, welcome_msg)
            
            # Conversation loop
            silence_count = 0
            max_silence = 2
            
            while silence_count < max_silence:
                # Record user input
                audio_file = await self._record_audio(agi)
                
                if not audio_file or not os.path.exists(audio_file):
                    silence_count += 1
                    logger.info(f"No audio recorded, silence count: {silence_count}")
                    
                    if silence_count < max_silence:
                        await self._speak(agi, "Sind Sie noch da? Wie kann ich Ihnen weiterhelfen?")
                    continue
                
                # Reset silence counter
                silence_count = 0
                
                # Transcribe audio
                try:
                    user_text = await self.ai_service.transcribe_audio(audio_file)
                    logger.info(f"User said: {user_text}")
                    
                    # Clean up audio file
                    os.remove(audio_file)
                    
                    # Check for goodbye
                    if self.ai_service.is_goodbye(user_text):
                        await self._speak(agi, "Vielen Dank für Ihr Interesse. Auf Wiederhören!")
                        break
                    
                    # Get AI response
                    ai_response = await self.ai_service.chat(user_text)
                    logger.info(f"AI response: {ai_response}")
                    
                    # Speak response
                    await self._speak(agi, ai_response)
                    
                except Exception as e:
                    logger.error(f"Error processing audio: {e}")
                    # Continue to next iteration
                    continue
            
            # Timeout or goodbye
            if silence_count >= max_silence:
                await self._speak(agi, "Auf Wiederhören!")
            
            # Hangup
            agi.hangup()
            logger.info("Call ended")
            
        except Exception as e:
            logger.error(f"Error handling call: {e}", exc_info=True)
            try:
                agi.hangup()
            except:
                pass
        finally:
            # Reset conversation for next call
            self.ai_service.reset_conversation()
    
    async def _speak(self, agi: AGI, text: str):
        """
        Convert text to speech and play to caller
        
        Args:
            agi: AGI instance
            text: Text to speak
        """
        try:
            # Generate TTS audio
            audio_data = await self.tts_service.synthesize(text)
            
            if not audio_data:
                logger.warning("Empty audio data, using fallback")
                # Fallback: use Asterisk's Festival or just continue
                return
            
            # Save audio to file
            audio_file = self.audio_dir / f"tts_{os.getpid()}_{id(text)}.wav"
            with open(audio_file, 'wb') as f:
                f.write(audio_data)
            
            # Play audio (remove .wav extension for Asterisk)
            audio_file_no_ext = str(audio_file).replace('.wav', '')
            agi.stream_file(audio_file_no_ext)
            
            # Clean up
            if audio_file.exists():
                os.remove(audio_file)
                
        except Exception as e:
            logger.error(f"Error speaking: {e}")
    
    async def _record_audio(self, agi: AGI) -> str:
        """
        Record audio from caller
        
        Args:
            agi: AGI instance
            
        Returns:
            Path to recorded audio file, or None if no audio
        """
        try:
            filename = self.audio_dir / f"recording_{os.getpid()}_{id(agi)}"
            
            # Record with silence detection
            # format: wav, silence duration, max duration
            agi.record_file(
                str(filename),
                'wav',
                '#',  # escape digit
                MAX_RECORDING_DURATION * 1000,  # milliseconds
                silence=SILENCE_DURATION
            )
            
            audio_file = f"{filename}.wav"
            
            # Check if file exists and has content
            if os.path.exists(audio_file) and os.path.getsize(audio_file) > 1000:
                return audio_file
            else:
                # Clean up empty file
                if os.path.exists(audio_file):
                    os.remove(audio_file)
                return None
                
        except Exception as e:
            logger.error(f"Error recording audio: {e}")
            return None


def main():
    """Main entry point for AGI script"""
    try:
        # Create AGI instance
        agi = AGI()
        
        # Create handler
        handler = AGIHandler()
        
        # Handle the call
        asyncio.run(handler.handle_call(agi))
        
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()

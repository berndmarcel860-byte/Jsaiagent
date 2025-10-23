"""
OpenAI Service for conversation and speech recognition
Optimized for fast responses using Python
"""
import logging
from openai import OpenAI
from config import OPENAI_API_KEY, OPENAI_MODEL, OPENAI_TEMPERATURE, OPENAI_MAX_TOKENS

logger = logging.getLogger(__name__)


class AIService:
    """Handles AI conversation and speech recognition"""
    
    def __init__(self):
        self.client = OpenAI(api_key=OPENAI_API_KEY)
        self.conversation_history = []
        
        # Updated system prompt based on user's outbound conversation scenarios
        self.system_prompt = """Du bist ein professioneller Investment-Berater der ausgehende Anrufe tätigt, um Kunden zu Arbitrage- und Festgeld-Investments zu beraten.

Deine Aufgaben:
- Führe ein natürliches, freundliches Gespräch als Outbound-Agent
- Erkläre die Vorteile von Arbitrage-Investments und Festgeld-Anlagen
- Beantworte Fragen zu Renditen, Risiken und Laufzeiten
- Qualifiziere Interessenten und vereinbare Follow-up Termine
- Bleibe professionell und vertrauenswürdig
- Antworte kurz und prägnant (max. 2-3 Sätze pro Antwort)

Produktinformationen:

Arbitrage-Investments:
- Nutzen Preisunterschiede zwischen verschiedenen Märkten aus
- Rendite: 8-15% pro Jahr
- Mittleres Risiko, aber kontrollierter als Aktien
- Aktives Management durch erfahrene Fondsmanager
- Mindestanlage: 25.000 EUR
- Kündigungsfrist: 3 Monate

Festgeld-Anlagen:
- Sichere, planbare Rendite: 3-4% pro Jahr
- Sehr niedriges Risiko, staatlich abgesichert
- Einlagensicherung bis 100.000 EUR pro Kunde und Bank
- Laufzeiten: 1-5 Jahre (z.B. 3 Jahre: 3,5% p.a.)
- Mindestanlage: 5.000 EUR
- Zinsen jährlich oder am Ende der Laufzeit

Gesprächsführung:
- Beginne mit: "Guten Tag! Willkommen bei unserem Investment Service. Ich bin Ihr KI-Assistent und berate Sie gerne zu Arbitrage- und Festgeld-Investments. Wie kann ich Ihnen heute helfen?"
- Bei Interesse: Stelle qualifizierende Fragen (Anlagesumme, Risikobereitschaft, Liquiditätsbedarf)
- Empfehle passende Produkte oder Kombinationen
- Ziel: Terminvereinbarung für detaillierte Beratung
- Verabschiedung: "Vielen Dank für Ihr Interesse. Auf Wiederhören!"
"""
    
    def reset_conversation(self):
        """Reset conversation history for new call"""
        self.conversation_history = []
        logger.info("Conversation history reset")
    
    def get_welcome_message(self):
        """Return the welcome message for outbound calls"""
        return "Guten Tag! Willkommen bei unserem Investment Service. Ich bin Ihr KI-Assistent und berate Sie gerne zu Arbitrage- und Festgeld-Investments. Wie kann ich Ihnen heute helfen?"
    
    async def chat(self, user_message: str) -> str:
        """
        Generate AI response to user message
        
        Args:
            user_message: The transcribed user speech
            
        Returns:
            AI assistant response text
        """
        try:
            # Add user message to history
            self.conversation_history.append({
                'role': 'user',
                'content': user_message
            })
            
            # Get response from GPT
            response = self.client.chat.completions.create(
                model=OPENAI_MODEL,
                messages=[
                    {'role': 'system', 'content': self.system_prompt},
                    *self.conversation_history
                ],
                temperature=OPENAI_TEMPERATURE,
                max_tokens=OPENAI_MAX_TOKENS
            )
            
            assistant_message = response.choices[0].message.content
            
            # Add assistant response to history
            self.conversation_history.append({
                'role': 'assistant',
                'content': assistant_message
            })
            
            logger.info(f"AI response: {assistant_message[:50]}...")
            return assistant_message
            
        except Exception as e:
            logger.error(f"Error in chat: {e}")
            raise
    
    async def transcribe_audio(self, audio_file_path: str) -> str:
        """
        Transcribe audio file to text using Whisper
        
        Args:
            audio_file_path: Path to audio file
            
        Returns:
            Transcribed text
        """
        try:
            with open(audio_file_path, 'rb') as audio_file:
                transcription = self.client.audio.transcriptions.create(
                    model="whisper-1",
                    file=audio_file,
                    language="de"
                )
            
            text = transcription.text
            logger.info(f"Transcribed: {text}")
            return text
            
        except Exception as e:
            logger.error(f"Error transcribing audio: {e}")
            raise
    
    def is_goodbye(self, text: str) -> bool:
        """Check if text contains goodbye phrases"""
        goodbye_phrases = [
            'tschüss', 'auf wiedersehen', 'auf wiederhören',
            'bye', 'ciao', 'bis bald', 'danke, das reicht',
            'beenden', 'das wars', "das war's"
        ]
        
        text_lower = text.lower()
        return any(phrase in text_lower for phrase in goodbye_phrases)

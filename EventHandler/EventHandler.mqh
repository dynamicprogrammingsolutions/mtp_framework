//
enum ENUM_HANDLING_TYPE {
   EH_PRINT = 1,
   EH_ALERT = 2,
   EH_SOUND = 4,
};

enum ENUM_EVENT_TYPE {
   E_VERBOSE = 1,
   E_INFO = 2,
   E_NOTICE = 4,
   E_WARNING = 8, 
   E_ERROR = 16,
   E_DEBUG = 32,
};

class CEventHandler : private CEventHandlerBase
{
public:
   virtual int Type() const { return classEventHandler; }
private:
   ushort defeventhandling;
   ushort eventhandling[];
   
   ushort loglevel;
   
   string soundfiles[];
   string defsoundfile;
   
   public:
   
   void CEventHandler()
   {
      defeventhandling = EH_PRINT;
      defsoundfile = "alert.wav";
      SetEventHandling(E_DEBUG,EH_PRINT);
      SetEventHandling(E_VERBOSE,EH_PRINT);
      SetEventHandling(E_INFO,EH_PRINT);
      SetEventHandling(E_NOTICE,EH_PRINT);
      SetEventHandling(E_WARNING,EH_PRINT|EH_SOUND);
      SetEventHandling(E_ERROR,EH_PRINT|EH_ALERT);
      SetLogLevel(E_NOTICE|E_WARNING|E_ERROR);
   } 
   
   virtual void Initalize()
   {
   
   }

   void SetLogLevel(ushort _loglevel)
   {
      loglevel = _loglevel;
   }

   ushort GetLogLevel()
   {
      return(loglevel);
   }
   
   void SetSound(const ENUM_EVENT_TYPE eventtype, const string soundfile)
   {
      int event_idx = (int)MathRound(MathLog(eventtype)/MathLog(2));
      if (ArraySize(soundfiles) < event_idx+1) ArrayResize(soundfiles,event_idx+1);
      soundfiles[event_idx] = soundfile;
   }

   void SetEventHandling(const ENUM_EVENT_TYPE eventtype, ushort handling) 
   {
      int event_idx = (int)MathRound(MathLog(eventtype)/MathLog(2));
      if (ArraySize(eventhandling) < event_idx+1) ArrayResize(eventhandling,event_idx+1);
      eventhandling[event_idx] = handling;
   }
   
   void Event(const ENUM_EVENT_TYPE event_type, const string message, const string function = "")
   {
      int event_idx = (int)MathRound(MathLog(event_type)/MathLog(2));
      ushort _eventhandling;
      if ((event_type & loglevel) == 0) return;

      if (ArraySize(eventhandling) < event_idx+1) {
         _eventhandling = defeventhandling;
      } else {
         _eventhandling = eventhandling[event_idx];
      }
      string _message = message;
      if (function != "") _message = function+":"+_message;
      if ((_eventhandling & EH_PRINT) > 0) Print(_message);
      if ((_eventhandling & EH_ALERT) > 0) Alert(_message);
      if ((_eventhandling & EH_SOUND) > 0) {
         string _soundfile;
         if (ArraySize(soundfiles) < event_idx+1) _soundfile = defsoundfile;
         else _soundfile = soundfiles[event_idx];
         if (_soundfile == "") _soundfile = defsoundfile;
         PlaySound(_soundfile);
      }
   }
   
   bool CheckEvent(const ENUM_EVENT_TYPE event_type)
   {
      if ((event_type & loglevel) == 0) return(false);
      else return(true);
   }

   void Debug(const string message, const string function = "")
   {
      Event(E_DEBUG, message, function);
   }

   void Verbose(const string message, const string function = "")
   {
      Event(E_VERBOSE, message, function);
   }
   
   void Info(const string message, const string function = "")
   {
      Event(E_INFO, message, function);
   }

   void Notice(const string message, const string function = "")
   {
      Event(E_NOTICE, message, function);
   }
   
   void Warning(const string message, const string function = "")
   {
      Event(E_WARNING, message, function);
   }

   void Error(const string message, const string function = "")
   {
      Event(E_ERROR, message, function);
   }
   
   bool Debug()
   {
      return(CheckEvent(E_DEBUG));
   }
   
   bool Verbose()
   {
      return(CheckEvent(E_VERBOSE));
   }
   
   bool Info()
   {
      return(CheckEvent(E_INFO));
   }

   bool Notice()
   {
      return(CheckEvent(E_NOTICE));
   }
   
   bool Warning()
   {
      return(CheckEvent(E_WARNING));
   }

   bool Error()
   {
      return(CheckEvent(E_ERROR));
   }   
   
};

CEventHandler* globaleventhandler;
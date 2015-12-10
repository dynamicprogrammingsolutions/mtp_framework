class CSignalEventListener : public CAppObject
{
   virtual bool callback(const int i, CObject*& o)
   {
      CSignal* signal = o;
      Print("Signal changed: ",signaltext(signal.signal),", ",signaltext_close(signal.closesignal));
      return false;
   }
};

/*

Registering:
application.SetEventListener(srvEntryMethod,new CSignalEventListener());

*/
class CSignalReport : public CServiceProvider
{
public:
   TraitAppAccess
   TraitGetType(classSignalReport)
 
   virtual void OnInit() {
      ((CSignalServiceProviderBase*)App().GetService(srvSignalServiceProvider)).AddObserver(GetPointer(this));   
   }
   
   virtual void EventCallback(const int event_id, CObject* event) {
      if (event_id == CSignalServiceProviderBase::OpenSignal) OpenSignal(event);
      if (event_id == CSignalServiceProviderBase::CloseSignal) CloseSignal(event);
   }
   
   void OpenSignal(CSignal* signal)
   {
      Print("Open Signal: "+signaltext(signal.signal));
   }
   void CloseSignal(CSignal* signal)
   {
      Print("Close Signal: "+signaltext(signal.closesignal));
   }
};
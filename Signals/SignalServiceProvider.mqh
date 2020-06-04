class CSignalServiceProviderBase : public CObservableServiceProvider
{
public:
   TraitGetType(classSignalServiceProvider)
   static int OpenSignal;
   static int CloseSignal;

protected:
   int bar;
   shared_ptr<CSignal> mainsignal;
      
   CSignalValidator validateopen;
   CSignalValidator validateclose;
public:
   virtual void OnTick()
   {
      mainsignal.get().Run(bar);
      
      validateopen.OnSignal(mainsignal.get());
      validateclose.OnSignal(mainsignal.get());
      
      if (mainsignal.get().valid) {
         if (validateopen.Validate(mainsignal.get())) {
            validateopen.OnValidSignal(mainsignal.get());
            Dispatch(OpenSignal,mainsignal.get());
         }
         if (validateclose.Validate(mainsignal.get())) {
            validateclose.OnValidSignal(mainsignal.get());
            Dispatch(CloseSignal,mainsignal.get());
         }
      }
      
      mainsignal.get().OnTick();
   }
};

static int CSignalServiceProviderBase::OpenSignal = 1;
static int CSignalServiceProviderBase::CloseSignal = 2;
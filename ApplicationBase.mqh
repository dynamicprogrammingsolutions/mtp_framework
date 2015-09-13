//
class CApplicationBase : private CObject
{
public:
   CApplicationBase()
   {
      global_application_base_object = GetPointer(this);
   }

   virtual CObject* GetService(string name) { return NULL; }
   virtual CObject* GetService(ENUM_APPLICATION_SERVICE srv) { return NULL; }
};

CApplicationBase* global_application_base_object;

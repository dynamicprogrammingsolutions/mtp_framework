//
class CApplicationInterface : public CObject
{
public:
   virtual void Command(CObject* command, bool disable_delete = false) {  }
   virtual void Event(CObject* event, bool disable_delete = false) {  }
   virtual CObject* GetService(string name) { return NULL; }
   virtual CObject* GetService(ENUM_APPLICATION_SERVICE srv) { return NULL; }
};
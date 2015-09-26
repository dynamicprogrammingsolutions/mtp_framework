//
class CApplicationInterface : public CObject
{
public:
   virtual CObject* GetService(string name) { return NULL; }
   virtual CObject* GetService(ENUM_APPLICATION_SERVICE srv) { return NULL; }
};